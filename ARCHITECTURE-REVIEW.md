# Actrace 架构审查报告

> **审查日期**：2026-07-23  
> **审查范围**：`entry/src/main/ets/` + `entry/src/test/`  
> **审查方法**：逐文件完整阅读，对照 AGENTS.md 定义的架构规则与依赖方向

---

## 架构合规性总览

| 维度 | 状态 | 说明 |
|------|------|------|
| 依赖方向 `pages → viewmodels → usecases → domain/ports` | ⚠️ 部分违规 | Page 层存在 2 处绕过 adapter 直接调用 `@kit.*` 的情况 |
| Composition Root 单一职责 | ✅ 合规 | EntryAbility 是唯一创建具体实例的地方 |
| Domain 层零 `@kit.*` 依赖 | ✅ 合规 | domain/ 目录无任何平台 API 引入 |
| Ports 纯接口定义 | ✅ 合规 | 所有 port 均为 interface，无实现代码 |
| ArkTS 严格模式合规 | ⚠️ 部分违规 | DebugRuntime 使用 object literal 创建 domain 实体 |
| `@Provide/@Consume` 主题传递 | ⚠️ 偏差 | 存在 ThemeProvider 与 HeatmapPage 两套 @Provide 源，主题持久化 3 处重复 |
| 测试覆盖 | ✅ 基本合规 | 所有 port 均有 named class mock，usecase/VM/policy 均有测试 |
| 设计系统一致性 | ⚠️ 偏差 | ParticleOverlay 硬编码颜色，CELL_SIZE 重复定义，TypographyStyles 未使用 |

---

## 🔴 严重问题（5 项）

> 违反核心架构规则，可能导致维护困难、状态不一致或编译风险。

---

### R-1. HeatmapPage 直接调用 `@kit.ArkData`，绕过 Adapter 层

**文件**：`pages/HeatmapPage.ets:2` `pages/HeatmapPage.ets:175-206`

**现状**：
```typescript
import { preferences } from '@kit.ArkData';  // ← Page 层不应直接依赖平台 API

private loadPersistedTheme(): void {
  preferences.getPreferences(getContext(this), PREFS_NAME, ...);
}
```

**违规点**：
- Page 层（最外层）直接 import `@kit.ArkData`，破坏了 `pages → viewmodels → usecases → ports → adapters` 的依赖方向
- 主题持久化应通过 `SkinProvider` port 或其 adapter 实现完成
- Page 层不应了解存储机制（preferences、文件名 `'app_settings'`、键名 `'theme'`）

**修复建议**：
1. 在 `SkinProviderImpl` 中新增 `loadPersistedTheme(): Promise<SkinTheme>` 方法（扩展 `SkinProvider` port 接口）
2. 或创建独立的 `ThemeRepository` port + adapter 负责主题读写
3. HeatmapPage 的主题初始化改为调用 VM 方法，VM 通过 SkinProvider port 获取持久化主题

---

### R-2. ThemeProvider 直接调用 `@kit.ArkData`，且与 HeatmapPage 功能重复

**文件**：`pages/components/ThemeProvider.ets:6` `pages/components/ThemeProvider.ets:32-65`

**现状**：
- ThemeProvider 独立实现了 `loadPersistedTheme()` / `persistTheme()`，逻辑与 HeatmapPage 完全相同
- 两者使用相同的 `PREFS_NAME = 'app_settings'` 和 `KEY_THEME = 'theme'`
- ThemeProvider 是 `@Component`，在组件树中提供 `@Provide tokens`，与 HeatmapPage 的 `@Provide tokens` 存在**双重提供源冲突**

**违规点**：
- 组件层不应直接操作平台持久化 API
- 同一份持久化逻辑在 3 处独立实现（HeatmapPage、ThemeProvider、SkinProviderImpl），违反 DRY
- HeatmapPage 已自含 `@Provide tokens`，ThemeProvider 实际上处于**未被使用**状态（HeatmapPage 直接 @Provide，未包裹 ThemeProvider）

**修复建议**：
1. 废弃 ThemeProvider.ets（当前 HeatmapPage 已直接承担 @Provide 职责）
2. 将持久化逻辑统一收归 SkinProviderImpl 或新建 ThemeRepository port
3. 保留 HeatmapPage 作为唯一的 `@Provide tokens` 源

---

### R-3. 主题持久化逻辑 3 处重复且不一致

**涉及文件**：
| # | 文件 | 持久化方式 | 是否走 port |
|---|------|-----------|------------|
| 1 | `pages/HeatmapPage.ets:175-206` | 直接 `preferences.getPreferences()` | ❌ |
| 2 | `pages/components/ThemeProvider.ets:32-65` | 直接 `preferences.getPreferences()` | ❌ |
| 3 | `adapters/SkinProviderImpl.ets` | **无持久化**，仅 `getTokens()` / `listThemes()` | — |

**问题**：
- SkinProvider port 只定义了 `getTokens()` 和 `listThemes()`，**不包含持久化操作**
- SkinProviderImpl 是纯内存查找（`ThemePalette[id]`），没有读写 preferences
- 导致"谁负责持久化"的职责落到了 Page 层，这违反了分层原则

**修复建议**：
1. 扩展 `SkinProvider` port：
   ```typescript
   export interface SkinProvider {
     getTokens(id: SkinTheme): DesignTokens;
     listThemes(): SkinTheme[];
     loadPersisted(): Promise<SkinTheme>;    // 新增
     persist(id: SkinTheme): Promise<void>;   // 新增
   }
   ```
2. 在 `SkinProviderImpl` 中实现这两个方法，封装 preferences 读写
3. 删除 HeatmapPage 和 ThemeProvider 中的所有 preferences 代码
4. HeatmapPage 的 `aboutToAppear()` 改为：`this.vm.initialize(...)` → VM 调用 `skinProvider.loadPersisted()` → 回传主题 → Page 更新 tokens

---

### R-4. DebugRuntime 使用 object literal 创建 EasterEgg，违反 ArkTS 严格模式

**文件**：`debug/DebugRuntime.ets:217-224`

**现状**：
```typescript
private egg(keyword: string, quote: string, effectType: string, soundFile: string): EasterEgg {
  return {                    // ← object literal 实现 interface
    keyword: keyword,
    quote: quote,
    effectType: effectType,
    soundFile: soundFile,
  };
}
```

**违规点**：
- ArkTS 严格模式禁止用 object literal 实现接口（`arkts-no-obj-literals-as-types`）
- 当前可能因 debug 目录未被严格检查而未报错，但规则应一致
- AGENTS.md 明确要求"mock classes must be named classes that implement the interface"

**修复建议**：
1. 在 `domain/EasterEgg.ets` 中将 `EasterEgg` interface 改为 named class：
   ```typescript
   export class EasterEgg {
     keyword: string;
     quote: string;
     effectType: string;
     soundFile: string;
     constructor(keyword: string, quote: string, effectType: string, soundFile: string) {
       this.keyword = keyword;
       this.quote = quote;
       this.effectType = effectType;
       this.soundFile = soundFile;
     }
   }
   ```
2. 更新 DebugRuntime.egg() 使用 `new EasterEgg(...)`
3. 更新所有引用 EasterEgg 的代码（usecases、adapters、mocks）以适配 class 构造函数

---

### R-5. HeatmapVM `@Observed` 装饰器与 `AppStorage` 传递方式不匹配

**文件**：`viewmodels/HeatmapVM.ets:19` + `entryability/EntryAbility.ets:50` + `pages/HeatmapPage.ets:26`

**现状**：
```typescript
// HeatmapVM.ets
@Observed
export class HeatmapVM { ... }

// EntryAbility.ets
AppStorage.setOrCreate<HeatmapVM>('heatmapVM', viewModel);

// HeatmapPage.ets
@StorageLink('heatmapVM') private vm: HeatmapVM | null = null;
```

**问题**：
- `@Observed` 的设计意图是配合 `@ObjectLink` 在子组件中做细粒度更新
- 当前通过 `@StorageLink` 访问 VM，`@Observed` 的细粒度响应机制**完全不被触发**——`@StorageLink` 监听的是引用替换，不是属性变化
- VM 属性变更（如 `this.cells = ...`）触发的是 `@StorageLink` 的整对象替换检测，而非 `@Observed` 的属性级通知
- 这导致潜在的 UI 刷新问题：VM 内部属性变更可能不会可靠触发 Page 重渲染

**修复建议**：
1. **方案 A**：移除 `@Observed`，改用 `@StorageLink` 的引用替换策略（每次操作后创建新 VM 或手动触发刷新）
2. **方案 B**（推荐）：将 VM 从 `AppStorage` 传递改为 `@State` 持有，配合 `@Observed` + `@ObjectLink`：
   - EntryAbility 通过 `AppStorage` 传递 VM（仅初始化时）
   - HeatmapPage 用 `@State vm: HeatmapVM` 接收
   - 子组件用 `@ObjectLink vm: HeatmapVM` 做细粒度更新
3. 无论哪种方案，当前 `@Observed` + `@StorageLink` 的组合应明确为其中一种语义

---

## 🟡 中等问题（10 项）

> 设计偏差或潜在风险，不影响运行但增加维护成本或导致行为与设计不一致。

---

### M-1. HeatmapContent.ets 是孤岛组件，未被引用

**文件**：`pages/HeatmapContent.ets`

**现状**：
- 定义了完整的 `HeatmapContent` 组件（SkinSwitcher + HeatmapGrid + CheckInInput）
- 但 `HeatmapPage.ets` 直接组装了相同功能的 UI，未使用 HeatmapContent
- HeatmapContent 中的 `@Prop vm: HeatmapVM` 与 HeatmapPage 的 `@StorageLink` 传递方式也不一致

**修复建议**：删除 `HeatmapContent.ets`，或将 HeatmapPage 的内联 UI 拆分到 HeatmapContent 中以减少 HeatmapPage 的复杂度。

---

### M-2. Index.ets 是 Hello World 残留，未使用

**文件**：`pages/Index.ets`

**现状**：
- 包含默认模板代码（Hello World / Welcome 切换）
- 路由配置指向 `pages/HeatmapPage`，Index 不会被加载
- 存在 `$r('app.float.page_text_font_size')` 资源引用，但可能无对应资源

**修复建议**：删除 `Index.ets` 或替换为实际用途。确认 `main_pages.json` 中不含此页面路由。

---

### M-3. FrequencyPatternEngine 放在 domain 层但实现了 port 接口

**文件**：`domain/FrequencyPatternEngine.ets`

**现状**：
```typescript
export class FrequencyPatternEngine implements UsagePatternEngine { ... }
```

**问题**：
- domain 层应为纯实体和接口定义，不应包含业务逻辑实现
- FrequencyPatternEngine 包含完整的模式识别逻辑（extractTerms、countTerm、summarize），是业务逻辑类
- 它实现了 `UsagePatternEngine` port，按架构规则应属于 usecases 或 adapters 层

**修复建议**：
1. 将 `FrequencyPatternEngine` 移至 `usecases/` 目录
2. 或如果它被视为"策略引擎"（类似 LearnedPatternPolicy），可保留在 domain 但不应实现 port——改为由 usecase 委托调用

---

### M-4. LearnedPatternPolicy 被直接实例化，绕过依赖注入

**文件**：`entryability/EntryAbility.ets:46`

**现状**：
```typescript
new ManageLearnedPatterns(learnedPatternRepo, new LearnedPatternPolicy(), learningObservationRepo)
```

**问题**：
- `LearnedPatternPolicy` 是 domain 中的策略类，包含可调参数（CANDIDATE_OCCURRENCES、MATURE_CONFIDENCE 等）
- 直接 `new` 意味着策略无法被替换或 mock 测试
- 与 DIP 原则不完全一致——usecase 应通过注入获得策略

**修复建议**：
1. 为 `LearnedPatternPolicy` 定义 port 接口（如 `PatternPolicy`），或在 `ManageLearnedPatterns` 构造函数中接受配置参数
2. 如果认为 Policy 是 domain 内部细节且无需替换，则当前做法可接受，但应在文档中明确标注

---

### M-5. LoadHeatmap 对 level 只设 0/1，未使用设计的 0-4 分级

**文件**：`usecases/LoadHeatmap.ets:24-28`

**现状**：
```typescript
cells.push({
  date: dateStr,
  level: match ? 1 : 0,  // ← 永远只有 0 或 1
  checkIn: match ? match : undefined,
});
```

**设计定义**（`domain/Streak.ets:33`）：
```typescript
/** Intensity level 0-4 (0 = no check-in, 4 = most check-ins) */
level: number;
```

**问题**：
- DayCell 的 `getCellColor()` 实现了 level 2/3/4 的颜色映射，但数据层永远不会产生这些级别
- StreakInfo 的 StreakLevel（L1_GLOW / L2_ATFIELD / L3_AWAKENED）也依赖 level 分级
- 当前热力图视觉上只有"已打卡/未打卡"两种状态

**修复建议**：
1. 设计每日多次打卡或内容长度→level 的映射规则
2. 在 LoadHeatmap 中实现分级逻辑（如基于 checkIn.content 长度或当日打卡次数）
3. 或修改 HeatmapCell.level 的设计定义，使其与实际数据一致

---

### M-6. StreakCalculator port 无实现、无调用

**文件**：`domain/ports/StreakCalculator.ets`

**现状**：
```typescript
export interface StreakCalculator {
  calculate(records: CheckIn[]): StreakInfo;
}
```

**问题**：
- port 接口已定义，但无 adapter 实现
- HeatmapVM 中有 `streakInfo: StreakInfo` 字段，但从未被赋值（始终为默认值 `{ current: 0, longest: 0, level: StreakLevel.NONE }`）
- 连续天数计算逻辑散落在 HeatmapVM 的 getter `longestMonthStreak` 中，未通过 StreakCalculator port

**修复建议**：
1. 实现 StreakCalculator adapter，正确计算 current/longest/level
2. 在 HeatmapVM.initialize() 和 doCheckIn() 后调用 StreakCalculator
3. 移除 HeatmapVM 中的 `longestMonthStreak` getter，改用 streakInfo

---

### M-7. SoundPlayerImpl 缺少 `eva_alert` 音效映射

**文件**：`adapters/SoundPlayerImpl.ets:65-72`

**现状**：
```typescript
private getFrequency(fileName: string): number {
  if (fileName === 'wind_chime') return 880;
  if (fileName === 'jojo_menace') return 440;
  if (fileName === 'healing_bell') return 740;
  if (fileName === 'anime_sparkle') return 990;
  if (fileName === 'level_up') return 1046;
  return 660;  // ← eva_alert 落入默认
}
```

**问题**：
- `FrequencyPatternEngine` 定义了 `SOUNDS[5] = 'eva_alert'`
- EasterEggLab 中 AT_FIELD 场景使用 `'eva_alert'`
- 但 `getFrequency()` 没有映射，播放时回落到 660Hz，与 EVA A.T. Field 的紧张感不匹配

**修复建议**：
```typescript
if (fileName === 'eva_alert') return 523;  // E5，紧迫警报感
```

---

### M-8. ParticleOverlay 使用硬编码颜色，脱离设计系统

**文件**：`pages/components/ParticleOverlay.ets:60-74`

**现状**：
```typescript
private getColorsForEffect(): string[] {
  switch (this.effectType) {
    case 'eva_at_field':
      return ['#FF6B35', '#7B2D8E', '#FFA500', '#FF4500'];  // ← 硬编码
    ...
  }
}
```

**问题**：
- 所有粒子颜色都是硬编码 hex 值，不经过 DesignTokens
- 切换主题后粒子颜色不会变化
- 与 `@Consume tokens` 的设计系统模式不一致

**修复建议**：
1. 将粒子调色板作为 DesignTokens 的扩展字段（如 `particlePalette: string[]`），或
2. 基于 `tokens.brandPrimary` / `tokens.brandAccent` 动态生成粒子颜色
3. 至少在主题切换时提供不同的粒子色板

---

### M-9. DayCell 和 HeatmapGrid 重复定义 CELL_SIZE = 40

**文件**：
- `pages/components/DayCell.ets:9`
- `pages/components/HeatmapGrid.ets:10`

**现状**：
```typescript
const CELL_SIZE = 40;  // 两处各自定义
```

**问题**：
- 违反设计系统"不使用硬编码数字"的规则
- 修改格子尺寸需要同时改两个文件

**修复建议**：
在 `SpacingTokens.ets` 或新建 `LayoutTokens.ets` 中定义：
```typescript
static readonly cellSize: number = 40;
```

---

### M-10. HeatmapVM 中两套彩蛋检测逻辑并存

**文件**：`viewmodels/HeatmapVM.ets:81-96`

**现状**：
```typescript
async doCheckIn(content: string): Promise<void> {
  ...
  await this.recordCheckIn.execute(this.selectedDate, content);
  await this.patternLearning.captureInput(content, this.selectedDate, now);
  const egg = await this.patternLearning.match(content, now);  // ← 路径 A: PatternLearning
  ...
}
```

同时存在 `DetectEasterEgg` usecase（路径 B: FrequencyPatternEngine），但 `doCheckIn()` 只走路径 A。

**问题**：
- `DetectEasterEgg` usecase 被注入但从未在 VM 中调用
- 两条检测路径独立运行，可能产生重复彩蛋触发
- 语义不清：`patternLearning.match()` 是"学习型模式匹配"，`DetectEasterEgg` 是"频率里程碑检测"，二者职责不同但触发时机相同

**修复建议**：
1. 在 `doCheckIn()` 中串联两条路径：先 `DetectEasterEgg`（频率里程碑），再 `patternLearning.match()`（学习型匹配）
2. 或合并为统一的 `IEasterEggDetector` port，内部协调两条路径
3. 移除未使用的 `DetectEasterEgg` usecase（如果确认 PatternLearning 已完全替代）

---

## 🟢 改善建议（6 项）

> 提升代码质量和可维护性，非阻塞性问题。

---

### S-1. Section 组件中 sectionLabel/summaryRow Builder 重复

**涉及文件**：
- `pages/sections/LogsSection.ets`
- `pages/sections/PatternsSection.ets`
- `pages/sections/ProfileSection.ets`
- `pages/sections/CalendarSection.ets`

**现状**：每个 Section 都独立定义了结构几乎相同的 `sectionLabel()` 和 `summaryRow()` / `settingRow()` Builder。

**建议**：抽取为共享的 `SectionBuilder.ets`，通过 `@Builder` 函数统一提供。

---

### S-2. TypographyStyles.ets 定义的 @Extend 样式从未使用

**文件**：`common/TypographyStyles.ets`

**现状**：定义了 `h1Style` / `h2Style` / `bodyStyle` / `captionStyle` 四个 `@Extend(Text)` 函数，但所有组件都直接内联 fontSize/fontWeight，未引用这些样式。

**建议**：
1. 在各组件中替换内联字体设置为 TypographyStyles 调用
2. 或如果确认不使用，删除此文件以减少死代码

---

### S-3. GlassTheme.ets 未见实际使用

**文件**：`common/GlassTheme.ets`

**现状**：定义了 `GlassTheme.surface()` / `border()` / `shadow()` 三个方法，但搜索整个代码库未发现引用。

**建议**：确认是否为预留功能。如无使用计划，删除以减少认知负载。

---

### S-4. VMFixture 测试 fixture 直接依赖 SkinProviderImpl

**文件**：`entry/src/test/mocks/VMFixture.ets:1`

**现状**：
```typescript
import { SkinProviderImpl } from '../../main/ets/adapters/SkinProviderImpl';
```

**问题**：测试 fixture 应只依赖 port 接口，而非具体 adapter 实现。当前 VMFixture 直接 `new SkinProviderImpl()` 创建主题提供者。

**建议**：创建 `MockSkinProvider implements SkinProvider`，返回固定 DesignTokens。

---

### S-5. EasterEgg 和 CheckIn 应从 interface 改为 class

**文件**：
- `domain/EasterEgg.ets:4-13`
- `domain/CheckIn.ets:5-12`

**现状**：两个核心实体使用 `interface` 定义。

**建议**：ArkTS 严格模式下，interface 只能用于类型声明，不能用于 object literal 实现。将频繁实例化的实体改为 `class`：
- 便于 new 构造
- 避免 object literal 陷阱
- 与 LearnedPattern、UsagePattern、LearningObservation 等已有 class 实体保持一致

---

### S-6. DebugRuntime 中 `failure()` 参数类型为 Object

**文件**：`debug/DebugRuntime.ets:237`

**现状**：
```typescript
private failure(error: Object): string {
  return `FAIL | ${JSON.stringify(error)}`;
}
```

**建议**：ArkTS 不推荐使用 `Object` 类型，应改为 `Error` 或具体业务错误类型。

---

## 架构合规矩阵

| 规则 | 合规 | 违规文件 | 问题编号 |
|------|------|---------|---------|
| Page 层零 `@kit.*` import | ❌ | HeatmapPage, ThemeProvider | R-1, R-2 |
| Domain 层零 `@kit.*` import | ✅ | — | — |
| Page 层零持久化逻辑 | ❌ | HeatmapPage, ThemeProvider | R-1, R-2, R-3 |
| Composition Root 单一职责 | ✅ | EntryAbility | — |
| Port 接口不包含实现 | ✅ | — | — |
| ArkTS 无 object literal for interface | ❌ | DebugRuntime | R-4 |
| `@Observed` / `@ObjectLink` 正确使用 | ❌ | HeatmapVM + HeatmapPage | R-5 |
| 无死代码 | ❌ | HeatmapContent, Index, TypographyStyles, GlassTheme | M-1, M-2, S-2, S-3 |
| Domain 层不含业务实现 | ⚠️ | FrequencyPatternEngine | M-3 |
| 设计系统一致性（SpacingTokens / DesignTokens） | ⚠️ | ParticleOverlay, DayCell, HeatmapGrid | M-8, M-9 |
| 所有 Port 均有实现 | ❌ | StreakCalculator | M-6 |
| 测试 mock 均为 named class | ✅ | MockCheckInRepo, MockUseCases, etc. | — |

---

## 修复优先级路线图

### Phase 1 — 架构合规（阻断性）

| 序号 | 问题 | 修复动作 | 影响文件 |
|------|------|---------|---------|
| 1 | R-1/R-2/R-3 | 扩展 SkinProvider port 含持久化方法，SkinProviderImpl 实现，删除 Page 层 preferences 代码 | SkinProvider, SkinProviderImpl, HeatmapPage, ThemeProvider |
| 2 | R-4 | EasterEgg interface → class，DebugRuntime.egg() 改用构造函数 | EasterEgg, DebugRuntime, ManageLearnedPatterns, DetectEasterEgg |
| 3 | R-5 | 明确 VM 传递方式：`@Observed` + `@ObjectLink` 或 `@StorageLink`（二选一） | HeatmapVM, HeatmapPage, 子组件 |

### Phase 2 — 功能完整性

| 序号 | 问题 | 修复动作 | 影响文件 |
|------|------|---------|---------|
| 4 | M-6 | 实现 StreakCalculator adapter，在 VM 中调用 | 新建 adapter, HeatmapVM |
| 5 | M-10 | 统一彩蛋检测逻辑（串联或合并两条路径） | HeatmapVM, DetectEasterEgg |
| 6 | M-5 | 设计并实现 HeatmapCell level 0-4 分级 | LoadHeatmap |
| 7 | M-7 | 添加 eva_alert 频率映射 | SoundPlayerImpl |

### Phase 3 — 代码清洁度

| 序号 | 问题 | 修复动作 | 影响文件 |
|------|------|---------|---------|
| 8 | M-1 | 删除或激活 HeatmapContent.ets | HeatmapContent |
| 9 | M-2 | 删除 Index.ets | Index |
| 10 | M-3 | FrequencyPatternEngine 移至 usecases/ | FrequencyPatternEngine |
| 11 | M-8/M-9 | 粒子颜色接入 DesignTokens，CELL_SIZE 移入 SpacingTokens | ParticleOverlay, DayCell, HeatmapGrid |
| 12 | S-1 | 抽取共享 SectionBuilder | 所有 Section 组件 |
| 13 | S-2/S-3 | 清理未使用的 TypographyStyles / GlassTheme | TypographyStyles, GlassTheme |
| 14 | S-4/S-5/S-6 | VMFixture 用 MockSkinProvider，EasterEgg/CheckIn 改 class，failure() 参数改 Error | VMFixture, EasterEgg, CheckIn, DebugRuntime |

---

## 附录：文件清单与层级归属校验

| 文件 | 当前层级 | 正确层级 | 是否需迁移 |
|------|---------|---------|-----------|
| domain/FrequencyPatternEngine.ets | domain | usecases | ⚠️ M-3 |
| domain/LearnedPatternPolicy.ets | domain | domain（可接受） | ✅ |
| pages/components/ThemeProvider.ets | components | 废弃或重构 | ⚠️ R-2 |
| pages/HeatmapContent.ets | components | 废弃 | ⚠️ M-1 |
| pages/Index.ets | pages | 废弃 | ⚠️ M-2 |
| common/TypographyStyles.ets | common | 废弃或启用 | ⚠️ S-2 |
| common/GlassTheme.ets | common | 废弃或启用 | ⚠️ S-3 |
