# Actrace UseCases 层现状分析报告

- 分析日期：2026-07-21
- 分析依据：`skill/clean-arch-app/SKILL.md`、仓库根目录 `AGENTS.md`
- 分析范围：`entry/src/main/ets/usecases/`、`entry/src/main/ets/domain/ports/`、相关 ViewModel 和 Composition Root
- 分析方式：静态源码审查；本次仅输出文档，未修改业务代码，未执行构建或设备交互测试

---

## 1. 结论摘要

当前 UseCases 层的**依赖方向和接口隔离做得不错**，但存在**职责偏移**——UseCases 更像"数据获取服务"而非"业务编排层"。

核心问题：

1. **业务编排错位**：签到流程（验证→记录→彩蛋检测→音效→刷新）全在 `HeatmapVM.doCheckIn()` 中，UseCase 只做数据搬运，这是职责倒置。
2. **展示逻辑混入 UseCase**：`LoadHeatmap` 将 `CheckIn[]` 转换为 `HeatmapCell[]`（含 level 映射、日期格式化），这是 UI 格式化而非业务规则。
3. **贫血 UseCase**：`RecordCheckIn` 仅 `timestamp: Date.now()` + 透传 `repo.save()`，无验证规则。
4. **孤立 Port**：`StreakCalculator` 已定义接口但无实现、无调用。

| 维度 | 评分 | 说明 |
|---|---|---|
| 依赖方向 | ✅ 良好 | 全部依赖 ports，无框架耦合 |
| 接口隔离 | ✅ 良好 | 每个 UseCase 实现独立 Port |
| 业务编排 | ❌ 不足 | ViewModel 承担了本应属于 UseCase 的流程编排 |
| 职责纯粹 | ⚠️ 一般 | LoadHeatmap 混入展示逻辑；RecordCheckIn 过于贫血 |
| 覆盖完整 | ⚠️ 一般 | StreakCalculator 孤立；部分业务规则分散在 ViewModel |

总体评级：**B**——架构骨架正确，但 UseCase 职责定位需要从"数据获取"向"业务编排"校正。

---

## 2. UseCases 全景

### 2.1 文件清单

| 文件 | 行数 | 实现 Port | 依赖的 Port(s) |
|---|---|---|---|
| `LoadHeatmap.ets` | 33 | `ILoadHeatmap` | `CheckInRepository` |
| `RecordCheckIn.ets` | 24 | `IRecordCheckIn` | `CheckInRepository` |
| `LoadActivity.ets` | 21 | `ILoadActivity` | `CheckInRepository` + `UsagePatternEngine` |
| `DetectEasterEgg.ets` | 27 | `IDetectEasterEgg` | `CheckInRepository` + `UsagePatternEngine` |

### 2.2 Port 接口清单

| 文件 | 接口 | 方法签名 |
|---|---|---|
| `HeatmapUseCases.ets` | `ILoadHeatmap` | `execute(year, month): Promise<HeatmapCell[]>` |
| `HeatmapUseCases.ets` | `IRecordCheckIn` | `execute(date, content): Promise<void>` |
| `ActivityUseCases.ets` | `ILoadActivity` | `execute(): Promise<ActivitySnapshot>` |
| `ActivityUseCases.ets` | `IDetectEasterEgg` | `execute(date, content): Promise<EasterEgg \| null>` |

此外还有 5 个**底层 Port**被 UseCase 依赖但不属于 UseCase 层：

| Port | 用途 | 实现位置 |
|---|---|---|
| `CheckInRepository` | 签到持久化 | `adapters/PreferencesCheckInRepo.ets` |
| `UsagePatternEngine` | 使用模式分析 | `domain/FrequencyPatternEngine.ets`（纯领域类，非 adapter） |
| `SkinProvider` | 主题令牌提供 | `adapters/SkinProviderImpl.ets` |
| `SoundPlayer` | 音效播放 | `adapters/SoundPlayerImpl.ets` |
| `ThemePreferenceRepository` | 主题偏好持久化 | `adapters/PreferencesThemeRepository.ets` |

以及 1 个**孤立 Port**：

| Port | 用途 | 状态 |
|---|---|---|
| `StreakCalculator` | 连续签到计算 | ⚠️ 已定义接口，无 UseCase/Adapter 实现，无调用方 |

### 2.3 Composition Root 装配图

`EntryAbility.ets:31-45` 创建并装配：

```
PreferencesCheckInRepo ──┐
                         ├── LoadHeatmap ────────┐
                         ├── RecordCheckIn ──────┤
                         ├── LoadActivity ───────┤
FrequencyPatternEngine ──┤                       ├── HeatmapVM ── AppStorage
                         ├── DetectEasterEgg ────┤
SkinProviderImpl ────────┤                       │
PreferencesThemeRepo ────┤                       │
SoundPlayerImpl ─────────┘                       │
```

所有具体实现仅在 `EntryAbility` 中创建，符合 Composition Root 模式。

---

## 3. 合规性评估

### 3.1 ✅ 做得好的方面

#### 依赖方向正确

所有 UseCase 只依赖 `domain/ports/` 中的接口，不导入任何 `@kit.*`、adapter 或框架模块。静态检查确认：

```
usecases/ → domain/ports/  ✓
usecases/ → domain/entities ✓
usecases/ → @kit.*         ✗ (无)
usecases/ → adapters/      ✗ (无)
```

主要依赖链保持为：

```text
pages → viewmodels → usecases → domain/ports
                                ← adapters implement ports
```

#### 显式实现 Port 接口

每个 UseCase 显式 `implements` 对应的 Port 接口，ViewModel 通过接口类型注入依赖。这使得：

- `HeatmapVM` 构造器参数类型全是接口（`ILoadHeatmap`, `IRecordCheckIn`, ...）
- 测试可以使用 `MockLoadHeatmap` 等实现类替换真实 UseCase
- Mock 类位于 `entry/src/test/mocks/MockUseCases.ets`，实现同样的 Port 接口

#### 构造器注入 + 集中装配

所有依赖通过构造器传入，Composition Root（`EntryAbility`）集中创建和装配。没有使用 Service Locator 或运行时查找。

#### 单一 `execute()` 方法

每个 UseCase 只暴露一个 `execute` 方法，符合 Command 模式的简洁风格，调用语义清晰。

#### 完整单元测试覆盖

| UseCase | 测试文件 |
|---|---|
| `LoadHeatmap` | `LoadHeatmap.test.ets` |
| `RecordCheckIn` | `RecordCheckIn.test.ets` |
| `LoadActivity` | `LoadActivity.test.ets` |
| `DetectEasterEgg` | `DetectEasterEgg.test.ets` |

Mock 基础设施齐全：`MockCheckInRepo` 实现 `CheckInRepository`，`MockUseCases` 实现全部 4 个 UseCase Port。

#### Port 接口按领域分组

`HeatmapUseCases.ets` 和 `ActivityUseCases.ets` 按业务领域（而非技术层）分组，每个文件 2-3 个接口，保持紧凑。

---

## 4. 问题详解

### P1：业务编排错位——ViewModel 承担了本应属于 UseCase 的流程编排

**证据**：`HeatmapVM.doCheckIn()` (`HeatmapVM.ets:71-79`)

```typescript
async doCheckIn(content: string): Promise<void> {
  const egg = await this.detectEasterEgg.execute(this.selectedDate, content);
  await this.recordCheckIn.execute(this.selectedDate, content);
  await Promise.all([this.loadMonth(this.currentYear, this.currentMonth), this.refreshActivity()]);

  if (egg !== null) {
    this.triggerEasterEgg(egg);
  }
}
```

**问题分析**：

这段代码编排了 5 个步骤：彩蛋检测 → 签到写入 → 月历刷新 → 活动刷新 → 彩蛋触发。这是一个**完整的业务流程**，应该由 UseCase 封装。

当前架构导致：

1. **业务规则散落在 ViewModel**：如果签到流程需要增加"同日不可重复签到"的校验，修改点在 ViewModel 而非 UseCase。
2. **测试编排逻辑需要通过 ViewModel**：要测试"签到后自动刷新月历"这个业务约束，必须测试 ViewModel，而非独立的 UseCase。
3. **无法复用**：如果未来有其他入口（如 Widget、通知点击）触发签到，需要重复编写相同的编排逻辑。

**对比**：`DetectEasterEgg` 是正确的 UseCase 设计——它封装了"排除当日历史 → 调用引擎评估"这个业务规则，ViewModel 不需要知道过滤逻辑。

### P1：`LoadHeatmap` 混入展示逻辑

**证据**：`LoadHeatmap.ets:16-31`

```typescript
async execute(year: number, month: number): Promise<HeatmapCell[]> {
  const checkins = await this.repo.loadByMonth(year, month);
  const daysInMonth = new Date(year, month, 0).getDate();
  const cells: HeatmapCell[] = [];

  for (let day = 1; day <= daysInMonth; day++) {
    const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    const match = checkins.find((c) => c.date === dateStr);
    cells.push({
      date: dateStr,
      level: match ? 1 : 0,           // ← 展示逻辑
      checkIn: match ? match : undefined,
    });
  }

  return cells;
}
```

**问题分解**：

| 逻辑 | 性质 | 应归属层 |
|---|---|---|
| `repo.loadByMonth(year, month)` | 数据获取 | UseCase ✓ |
| `new Date(year, month, 0).getDate()` | 日历计算 | ViewModel/Presenter |
| `padStart(2, '0')` 日期格式化 | 展示格式化 | ViewModel/Presenter |
| `match ? 1 : 0` level 映射 | 展示逻辑 | ViewModel/Presenter |
| `HeatmapCell` 数据结构 | UI 模型 | ViewModel/Presenter |

`HeatmapCell` 的定义注释写着 `level: number // Intensity level 0-4`，暗示未来需要多级 intensity。但当前硬编码为二元映射 `0/1`，这个映射规则是**展示需求**，会随 UI 演化而变化，不应固定在 UseCase 中。

**影响**：如果未来需要按签到次数区分 level（0-4 五级），需要修改 UseCase 层，而非仅调整展示层。

### P2：`RecordCheckIn` 过于贫血

**证据**：`RecordCheckIn.ets:16-23`

```typescript
async execute(date: string, content: string): Promise<void> {
  const checkIn: CheckIn = {
    date: date,
    content: content,
    timestamp: Date.now(),
  };
  await this.repo.save(checkIn);
}
```

**分析**：

这个 UseCase 的唯一"业务逻辑"是 `timestamp: Date.now()`——生成时间戳。其余就是组装对象并透传给 repo。

当前缺少但应当存在的业务规则：

| 规则 | 当前状态 | 应归属 |
|---|---|---|
| 同一日期不可重复签到 | ❌ 未实现 | UseCase |
| 内容不得为空 | ❌ 未实现（DetectEasterEgg 有空内容检查，但 RecordCheckIn 没有） | UseCase |
| 日期格式/合法性校验 | ❌ 未实现 | UseCase |
| 签到成功后的副作用触发 | ❌ 在 ViewModel 中手动编排 | UseCase |

`DetectEasterEgg.ets:20-22` 有空内容检查：

```typescript
if (content.trim().length === 0) {
  return null;
}
```

但这是彩蛋检测的前置条件，不是签到业务规则。空内容签到仍然会被 `RecordCheckIn` 成功保存。

**判断**：贫血 UseCase 本身不是反模式——它作为扩展点存在是合理的。但结合业务编排错位问题（P1），它加剧了"业务规则分散在 ViewModel"的倾向。

### P2：`LoadActivity` 包含展示排序

**证据**：`LoadActivity.ets:17-18`

```typescript
const checkIns = await this.repo.loadAll();
checkIns.sort((left: CheckIn, right: CheckIn) => right.timestamp - left.timestamp);
```

**分析**：

"按时间倒序排列"是**展示需求**（最近的活动排在前面），不是业务规则。如果活动页面未来需要按日期正序、按内容分组等不同视图，当前 UseCase 的硬编码排序就成了阻碍。

此外，`ActivitySnapshot` 类只是把 `CheckIn[]` + `UsagePattern[]` 捆绑在一起，没有额外业务逻辑。这个"捆绑"可以在 ViewModel 中完成。

### P2：`StreakCalculator` Port 孤立

**证据**：

- `domain/ports/StreakCalculator.ets` 定义了接口
- 无 UseCase 实现它
- 无 Adapter 实现它
- `HeatmapVM.longestMonthStreak` getter (`HeatmapVM.ets:162-174`) 内联计算了连续天数，未使用该 Port

```typescript
// HeatmapVM.ets:162-174 — 内联计算，绕过 StreakCalculator Port
get longestMonthStreak(): number {
  let longest = 0;
  let current = 0;
  this.cells.forEach((cell: HeatmapCell) => {
    if (cell.level > 0) {
      current++;
      longest = Math.max(longest, current);
    } else {
      current = 0;
    }
  });
  return longest;
}
```

**影响**：

1. 孤立 Port 增加维护者认知负担——不清楚这是未完成功能还是废弃设计。
2. ViewModel 自行计算连续天数，绕过了 Clean Architecture 的 Port 抽象。
3. `StreakInfo.level`（`StreakLevel` 枚举：NONE/L1_GLOW/L2_ATFIELD/L3_AWAKENED）也未在任何地方被使用，暗示连续签到的视觉进化功能尚未完成。

### P3：Port 接口按页面分组而非业务聚合

**当前分组**：

- `HeatmapUseCases.ets` → `ILoadHeatmap` + `IRecordCheckIn`
- `ActivityUseCases.ets` → `ILoadActivity` + `IDetectEasterEgg`

**问题**：

`IRecordCheckIn`（签到写入）并不是"热力图专用"的业务概念——它是通用的签到操作。将它放在 `HeatmapUseCases.ets` 中，是因为当前只有热力图页面消费它，而非因为业务上属于同一聚合。

按 Clean Architecture 的聚合根原则，Port 应按业务边界分组：

- **签到聚合**：写入签到、加载月份签到
- **活动分析聚合**：加载活动摘要、检测彩蛋

当前按页面消费方分组会导致：新增页面复用签到功能时，Port 文件名与实际语义不匹配。

### P3：UseCase 层缺少"跨 Port 编排"的完整案例

当前 4 个 UseCase 都有以下模式：

| 模式 | UseCase | 说明 |
|---|---|---|
| 单 Port 透传 | `RecordCheckIn` | 仅调用 `repo.save()` |
| 单 Port + 格式化 | `LoadHeatmap` | 调用 `repo.loadByMonth()` + 构建 UI 模型 |
| 双 Port 聚合 | `LoadActivity` | 调用 `repo.loadAll()` + `engine.summarize()` |
| 双 Port + 过滤 | `DetectEasterEgg` | 调用 `repo.loadAll()` + `engine.evaluate()` + 业务过滤 |

缺少的模式：**跨 Port 编排 + 业务规则验证 + 副作用协调**，这正是签到流程需要的。当前这个职责由 ViewModel 承担。

---

## 5. ViewModel 与 UseCase 交互现状

### 5.1 HeatmapVM 的 7 个依赖

```typescript
// HeatmapVM 构造器参数
constructor(
  loadHeatmap: ILoadHeatmap,      // UseCase Port
  recordCheckIn: IRecordCheckIn,   // UseCase Port
  loadActivity: ILoadActivity,     // UseCase Port
  detectEasterEgg: IDetectEasterEgg, // UseCase Port
  skinProvider: SkinProvider,       // 底层 Port
  themePreferences: ThemePreferenceRepository, // 底层 Port
  soundPlayer: SoundPlayer,         // 底层 Port
)
```

**问题**：ViewModel 直接依赖 4 个 UseCase Port + 3 个底层 Port，共 7 个依赖。其中 `skinProvider`、`themePreferences`、`soundPlayer` 可以被 UseCase 封装，ViewModel 不需要直接知道它们。

### 5.2 ViewModel 中的业务编排

| 方法 | 编排内容 | 应归属 |
|---|---|---|
| `doCheckIn()` | 彩蛋检测→签到→刷新月历→刷新活动→触发彩蛋 | **CheckInFlow UseCase** |
| `loadMonth()` | 调用 UseCase → 赋值 cells | ViewModel ✓ |
| `refreshActivity()` | 调用 UseCase → 赋值 checkIns/patterns | ViewModel ✓ |
| `switchSkin()` | 应用主题 → 持久化 | **UseCase 或保持现状** |
| `triggerEasterEgg()` | 设置状态 + 播放音效 + setTimeout | **UseCase 或保持现状** |

### 5.3 ViewModel 中的展示计算

| Getter | 内容 | 应归属 |
|---|---|---|
| `monthLabel` | "2026年 7月" | ViewModel ✓ |
| `monthCode` | "2026.07" | ViewModel ✓ |
| `monthCommitCount` | 当月签到天数 | ViewModel ✓ |
| `totalCommitCount` | 总签到数 | ViewModel ✓ |
| `longestMonthStreak` | 月内最长连续天数 | **StreakCalculator UseCase** 或 ViewModel |
| `isToday()` / `todayString` | 日期判断 | ViewModel ✓ |

---

## 6. 理想 UseCase 层设计

### 6.1 核心原则

| 原则 | 说明 |
|---|---|
| **业务编排** | UseCase 封装跨 Port 的业务流程，而非单 Port 透传 |
| **不感知 UI** | UseCase 输入输出都是领域实体/值对象，不产出 UI 模型 |
| **不可省略的规则** | 如果 UseCase 没有业务规则，考虑是否真的需要它（但保留作为扩展点是合理的） |
| **按业务聚合分组** | Port/UseCase 按业务边界分组，而非按页面分组 |

### 6.2 建议的目录结构

```
usecases/
├── CheckInFlow.ets            # 签到完整流程：验证 → 记录 → 彩蛋检测 → 返回结果
├── LoadMonthCheckIns.ets      # 加载月份签到（纯数据，返回 CheckIn[]）
├── LoadActivitySummary.ets    # 加载活动摘要（纯数据 + 模式分析）
└── DetectEasterEgg.ets        # 彩蛋检测（已有，保留但简化）

domain/ports/
├── CheckInUseCases.ets        # ICheckInFlow, ILoadMonthCheckIns
├── ActivityUseCases.ets       # ILoadActivitySummary, IDetectEasterEgg
├── CheckInRepository.ets      # （不变）
├── UsagePatternEngine.ets     # （不变）
├── StreakCalculator.ets       # → 决定：实现或删除
├── SkinProvider.ets           # （不变）
├── SoundPlayer.ets            # （不变）
└── ThemePreferenceRepository.ets  # （不变）
```

### 6.3 关键变更详解

#### 变更 1：新增 `CheckInFlow` UseCase

取代当前 `RecordCheckIn` + ViewModel 手动编排的签到流程。

```typescript
// 建议的 CheckInFlow
export class CheckInFlow implements ICheckInFlow {
  private repo: CheckInRepository;
  private eggDetector: UsagePatternEngine;
  private soundPlayer: SoundPlayer;

  constructor(repo: CheckInRepository, engine: UsagePatternEngine, sound: SoundPlayer) {
    this.repo = repo;
    this.eggDetector = engine;
    this.soundPlayer = sound;
  }

  async execute(date: string, content: string): Promise<CheckInResult> {
    // 1. 业务验证
    if (content.trim().length === 0) {
      return { status: CheckInStatus.REJECTED_EMPTY };
    }
    const existing = await this.repo.loadByMonth(/* parse year/month from date */);
    if (existing.some(c => c.date === date)) {
      return { status: CheckInStatus.REJECTED_DUPLICATE };
    }

    // 2. 签到写入
    const checkIn: CheckIn = { date, content, timestamp: Date.now() };
    await this.repo.save(checkIn);

    // 3. 彩蛋检测
    const history = existing.filter(c => c.date !== date);
    const egg = this.eggDetector.evaluate(content, history);

    return { status: CheckInStatus.SUCCESS, checkIn, easterEgg: egg };
  }
}
```

**效果**：

- ViewModel 的 `doCheckIn()` 简化为：调用 `CheckInFlow` → 根据 `CheckInResult` 更新 UI 状态
- 业务规则集中在 UseCase，可独立测试
- `SoundPlayer` 从 ViewModel 依赖中移除（由 UseCase 或 ViewModel 根据结果决定是否播放）

#### 变更 2：`LoadHeatmap` → `LoadMonthCheckIns`

将展示逻辑移回 ViewModel。

```typescript
// UseCase：只返回原始数据
export class LoadMonthCheckIns implements ILoadMonthCheckIns {
  private repo: CheckInRepository;

  async execute(year: number, month: number): Promise<CheckIn[]> {
    return await this.repo.loadByMonth(year, month);
  }
}

// ViewModel：负责转换为 UI 模型
async loadMonth(year: number, month: number): Promise<void> {
  this.currentYear = year;
  this.currentMonth = month;
  const checkins = await this.loadMonthCheckIns.execute(year, month);
  this.cells = this.buildHeatmapCells(year, month, checkins);
}

private buildHeatmapCells(year: number, month: number, checkins: CheckIn[]): HeatmapCell[] {
  const daysInMonth = new Date(year, month, 0).getDate();
  const cells: HeatmapCell[] = [];
  for (let day = 1; day <= daysInMonth; day++) {
    const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    const match = checkins.find(c => c.date === dateStr);
    cells.push({
      date: dateStr,
      level: match ? 1 : 0,
      checkIn: match ? match : undefined,
    });
  }
  return cells;
}
```

**效果**：

- UseCase 只返回业务数据，不产出 UI 模型
- `HeatmapCell[]` 构建逻辑在 ViewModel，可随 UI 需求自由调整
- 未来支持多级 level 只需修改 ViewModel，不动 UseCase

#### 变更 3：`LoadActivity` 简化

移除排序，返回原始数据 + 模式摘要。

```typescript
export class LoadActivitySummary implements ILoadActivitySummary {
  async execute(): Promise<ActivitySnapshot> {
    const checkIns = await this.repo.loadAll();
    return new ActivitySnapshot(checkIns, this.engine.summarize(checkIns));
  }
}

// ViewModel 自行排序
async refreshActivity(): Promise<void> {
  const snapshot = await this.loadActivity.execute();
  snapshot.checkIns.sort((a, b) => b.timestamp - a.timestamp);
  this.checkIns = snapshot.checkIns;
  this.usagePatterns = snapshot.patterns;
}
```

#### 变更 4：处理 `StreakCalculator` Port

两个选项：

- **选项 A：实现** — 创建 `CalculateStreak` UseCase，将 `HeatmapVM.longestMonthStreak` 中的内联计算迁移过去，并实现 `StreakInfo.level` 的视觉进化逻辑
- **选项 B：删除** — 如果连续签到视觉进化功能当前不计划实现，删除孤立 Port 以减少认知负担，待需求明确时再添加

**建议**：选项 A，因为 `StreakLevel` 枚举（NONE/L1_GLOW/L2_ATFIELD/L3_AWAKENED）已在 `Streak.ets` 中定义，暗示这是一个计划中的功能。

#### 变更 5：Port 文件重命名

按业务聚合重新分组：

| 现状 | 建议 |
|---|---|
| `HeatmapUseCases.ets` → `ILoadHeatmap` + `IRecordCheckIn` | `CheckInUseCases.ets` → `ICheckInFlow` + `ILoadMonthCheckIns` |
| `ActivityUseCases.ets` → `ILoadActivity` + `IDetectEasterEgg` | `ActivityUseCases.ets` → `ILoadActivitySummary` + `IDetectEasterEgg` |

### 6.4 重构后的 ViewModel 依赖

```typescript
// 重构前：7 个依赖
constructor(
  loadHeatmap: ILoadHeatmap,
  recordCheckIn: IRecordCheckIn,
  loadActivity: ILoadActivity,
  detectEasterEgg: IDetectEasterEgg,
  skinProvider: SkinProvider,
  themePreferences: ThemePreferenceRepository,
  soundPlayer: SoundPlayer,
)

// 重构后：5 个依赖
constructor(
  checkInFlow: ICheckInFlow,          // 合并了 recordCheckIn + detectEasterEgg + soundPlayer
  loadMonthCheckIns: ILoadMonthCheckIns,
  loadActivity: ILoadActivitySummary,
  skinProvider: SkinProvider,
  themePreferences: ThemePreferenceRepository,
)
```

`SoundPlayer` 从 ViewModel 直接依赖中移除，改为由 `CheckInFlow` 内部协调（或 ViewModel 根据 `CheckInResult.easterEgg` 决定是否播放，取决于对音效播放职责的认定）。

---

## 7. 风险与实施建议

### 7.1 分阶段实施

| 阶段 | 工作 | 风险 | 前置条件 |
|---|---|---|---|
| 1 | 将 `HeatmapCell[]` 构建从 `LoadHeatmap` 移至 ViewModel | 低 | 无 |
| 2 | 将排序从 `LoadActivity` 移至 ViewModel | 低 | 无 |
| 3 | 决定并处理 `StreakCalculator` Port（实现或删除） | 低 | 需确认产品需求 |
| 4 | 新增 `CheckInFlow` UseCase，将 `doCheckIn` 编排移入 | 中 | 需定义 `CheckInResult` 领域类型 |
| 5 | 重命名 Port 文件按业务聚合分组 | 低 | 阶段 4 完成后 |
| 6 | 在 ViewModel 拆分稳定后，按 Section 消费边界进一步优化 | 中至高 | 与页面 Section 组件化协调 |

### 7.2 不建议做的事

1. **不要在没有业务规则的情况下强行创建 UseCase** — 贫血 UseCase 作为扩展点存在是合理的，不必为了"模式正确"强行加逻辑
2. **不要一次性重构所有 UseCase + ViewModel + 测试** — 应逐步迁移，每次只改一个 UseCase
3. **不要在拆 Section 的同一次变更中同步大改 UseCase** — 两个维度的变更应该解耦
4. **不要将 `SoundPlayer` 从 ViewModel 移除后又以另一种方式泄漏** — 如果 `CheckInFlow` 持有 `SoundPlayer`，UseCase 就知道"音效"这个 UI 概念；更纯粹的方案是 `CheckInFlow` 只返回 `easterEgg`，由 ViewModel 决定是否播放

### 7.3 关于 `SoundPlayer` 职属的权衡

| 方案 | 优点 | 缺点 |
|---|---|---|
| `CheckInFlow` 内部播放 | ViewModel 更精简 | UseCase 感知 UI 副作用 |
| `CheckInFlow` 返回 `easterEgg`，ViewModel 播放 | UseCase 保持纯粹 | ViewModel 仍需持有 `SoundPlayer` |
| 新增 `EasterEggPresenter` 负责播放 | ViewModel 和 UseCase 都纯粹 | 增加一层抽象 |

**建议**：当前阶段选择方案 B（`CheckInFlow` 返回 `easterEgg`，ViewModel 播放），理由是音效播放本身是 UI 反馈，不应是业务流程的一部分。

---

## 8. 与已有架构审计报告的关联

本分析与 `.agent/reports/clean-architecture-navigation-componentization-audit-2026-07-21.md` 的发现互补：

| 审计报告问题 | 本报告关联 |
|---|---|
| P1：四个 Section 未独立组件化 | Section 拆分后，每个 Section 只需部分 UseCase Port，可进一步优化依赖 |
| P1：页面直接执行主题持久化 | `ThemePreferenceRepository` 已作为 Port 存在，UseCase 层无此问题 |
| P2：HeatmapVM 职责集中 | 本报告指出 VM 承担了本应属于 UseCase 的业务编排，与 VM 职责集中互为因果 |
| P2：展示层概念放入 domain | `HeatmapCell`（含 level）是展示模型却从 UseCase 返回，加重了此问题 |

**建议实施顺序**：先做 Section 组件化（审计报告建议的优先级 1），再调整 UseCase 职责，最后按 Section 消费边界拆 ViewModel。两个维度的变更解耦，避免扩大回归面。

---

## 9. 总结

当前 UseCases 层的**依赖方向和接口隔离质量良好**，但在**职责定位**上存在系统性的偏移：

| 现状 | 理想 |
|---|---|
| UseCase = 数据获取服务 | UseCase = 业务编排层 |
| ViewModel 编排跨 Port 流程 | UseCase 编排，ViewModel 只触发+渲染 |
| UseCase 返回 UI 模型 | UseCase 返回领域实体/值对象 |
| 贫血 UseCase（无业务规则） | UseCase 封装不可省略的业务规则 |
| Port 按页面消费方分组 | Port 按业务聚合分组 |

核心结论：**UseCase 层需要从"数据获取服务"向"业务编排层"校正**。最关键的改动是将签到流程编排从 ViewModel 移入 `CheckInFlow` UseCase，并将 `LoadHeatmap` 中的展示格式化逻辑归还 ViewModel。
