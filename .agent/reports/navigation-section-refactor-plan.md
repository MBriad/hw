# 导航栏内容区域增量重构计划

> 基于审计报告 `navigation-content-componentization-audit.md`，制定 7 步增量重构路线。
> 每步只改一点，可独立编译验证，可独立回滚。

---

## 总览

| 步骤 | 内容 | 改动文件数 | HeatmapPage 减行 | 风险 |
|------|------|-----------|-----------------|------|
| Step 1 | 提取 `LogsSection` | 2 | ~77 | 🟢 最低 |
| Step 2 | 提取 `PatternsSection` | 2 | ~103 | 🟢 低 |
| Step 3 | 提取 `ProfileSection` | 2 | ~98 | 🟡 中低 |
| Step 4 | 提取 `CalendarSection` | 2 | ~85 | 🟡 中 |
| Step 5 | 用注册 Map 替换 if/else 链 | 1 | ~2 (净减) | 🟢 低 |
| Step 6 | 主题持久化移入 `SkinProviderImpl` | 3 | ~30 | 🟡 中 |
| Step 7 | 拆分 ViewModel（可选/暂缓） | 5+ | 重构级 | 🟠 较高 |

**完成 Step 1-4 后，HeatmapPage 从 598 行降至 ~200 行，4 个 Section 均为独立组件。**

---

## Step 1 — 提取 `LogsSection`

### 目标
将 `logsPage()` Builder 提取为独立 `@Component`。

### 改动文件

| 文件 | 操作 |
|------|------|
| `pages/components/LogsSection.ets` | **新建** — 从 HeatmapPage 移出 `logsPage()` 内容 |
| `pages/HeatmapPage.ets` | **修改** — 删除 `logsPage()` Builder，改为使用 `<LogsSection>` 组件 |

### 具体改动

**新建 `LogsSection.ets`：**

```typescript
import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct LogsSection {
  @Consume tokens: DesignTokens;
  @Prop checkIns: CheckIn[];
  @Prop totalCommitCount: number;

  build() {
    Scroll() {
      Column() {
        // 标题区
        Row() {
          Column() {
            Text('COMMIT_LOG')
              .fontSize(28)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
              .fontFamily('monospace')

            Text('LOCAL ACTIVITY STREAM')
              .fontSize(9)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(`${this.totalCommitCount}`)
            .fontSize(38)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
        }
        .width('100%')
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        // 列表
        if (this.checkIns.length === 0) {
          Text('AWAITING FIRST COMMIT...')
            .width('100%')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .padding({ top: Spacing.xl, bottom: Spacing.xl })
        } else {
          ForEach(this.checkIns, (checkIn: CheckIn, index: number) => {
            Row() {
              Column() {
                Text(checkIn.date.replace(/-/g, '.'))
                  .fontSize(10)
                  .fontWeight(700)
                  .fontColor(this.tokens.textMuted)
                  .fontFamily('monospace')

                Text(checkIn.content)
                  .fontSize(15)
                  .fontWeight(600)
                  .fontColor(this.tokens.textPrimary)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: Spacing.xxs })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(String(this.checkIns.length - index).padStart(3, '0'))
                .fontSize(12)
                .fontWeight(700)
                .fontColor(this.tokens.brandPrimary)
                .fontFamily('monospace')
            }
            .width('100%')
            .padding({ top: Spacing.sm, bottom: Spacing.sm })
            .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
          }, (checkIn: CheckIn) => `${checkIn.date}-${checkIn.timestamp}`)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
```

**修改 `HeatmapPage.ets`：**

1. 顶部新增 import：
```typescript
import { LogsSection } from './components/LogsSection';
```

2. 删除整个 `logsPage()` Builder 方法（约 77 行）

3. 修改 `activePage()` 中的 LOGS 分支：
```typescript
// 原来：this.logsPage()
// 改为：
LogsSection({
  checkIns: this.vm!.checkIns,
  totalCommitCount: this.vm!.totalCommitCount,
})
```

### 依赖的 ViewModel 属性
- `checkIns: CheckIn[]`
- `totalCommitCount: number`

仅 2 个属性，接口最窄。

### 验证方式
1. `arkts_check` 检查 `LogsSection.ets` 和 `HeatmapPage.ets`
2. `build_project` 编译通过
3. 启动 App → 切换到 LOGS tab → 检查：
   - 标题 "COMMIT_LOG" + "LOCAL ACTIVITY STREAM" 显示正常
   - 空状态 "AWAITING FIRST COMMIT..." 显示正常
   - 有签到记录时列表正常渲染
   - 序号（右侧数字）格式正确
   - 主题切换后颜色正确

### 回滚方式
- 删除 `LogsSection.ets`
- 在 HeatmapPage 中恢复 `logsPage()` Builder 并还原 `activePage()` 中的调用

---

## Step 2 — 提取 `PatternsSection`

### 目标
将 `corePage()` Builder 提取为独立 `@Component`。

### 改动文件

| 文件 | 操作 |
|------|------|
| `pages/components/PatternsSection.ets` | **新建** — 从 HeatmapPage 移出 `corePage()` 内容 |
| `pages/HeatmapPage.ets` | **修改** — 删除 `corePage()` Builder，改为使用 `<PatternsSection>` 组件 |

### 具体改动

**新建 `PatternsSection.ets`：**

```typescript
import { UsagePattern } from '../../domain/EasterEgg';
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct PatternsSection {
  @Consume tokens: DesignTokens;
  @Prop usagePatterns: UsagePattern[];

  build() {
    Scroll() {
      Column() {
        // 标题区
        Column() {
          Text('USAGE_CORE')
            .fontSize(28)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('LOCAL PATTERN ENGINE // NO FIXED KEYWORDS')
            .fontSize(9)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        // 统计区
        Row() {
          Column() {
            Text('LEARNED PATTERNS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.usagePatterns.length}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('MILESTONES')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text('03 / 07 / 14 / 30')
              .fontSize(12)
              .fontWeight(700)
              .fontColor(this.tokens.textPrimary)
              .fontFamily('monospace')
              .margin({ top: Spacing.sm })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.md, bottom: Spacing.md })
        .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })

        // 模式列表
        if (this.usagePatterns.length === 0) {
          Text('SIGNAL: LISTENING...')
            .width('100%')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .padding({ top: Spacing.xl, bottom: Spacing.xl })
        } else {
          ForEach(this.usagePatterns, (pattern: UsagePattern) => {
            Row() {
              Column() {
                Text(pattern.term.toUpperCase())
                  .fontSize(15)
                  .fontWeight(800)
                  .fontColor(this.tokens.textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(pattern.nextMilestone > 0 ? `NEXT // ${pattern.nextMilestone}` : 'LEVEL // MAX')
                  .fontSize(9)
                  .fontWeight(700)
                  .fontColor(this.tokens.textMuted)
                  .fontFamily('monospace')
                  .margin({ top: Spacing.xxs })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(`x${pattern.count}`)
                .fontSize(24)
                .fontWeight(900)
                .fontColor(this.tokens.brandPrimary)
                .fontFamily('monospace')
            }
            .width('100%')
            .padding({ top: Spacing.sm, bottom: Spacing.sm })
            .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
          }, (pattern: UsagePattern) => pattern.term)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
```

**修改 `HeatmapPage.ets`：**

1. 顶部新增 import：
```typescript
import { PatternsSection } from './components/PatternsSection';
```

2. 删除整个 `corePage()` Builder 方法（约 103 行）

3. 修改 `activePage()` 中的 CORE 分支：
```typescript
// 原来：this.corePage()
// 改为：
PatternsSection({
  usagePatterns: this.vm!.usagePatterns,
})
```

### 依赖的 ViewModel 属性
- `usagePatterns: UsagePattern[]`

仅 1 个属性，最简单。

### 验证方式
1. `arkts_check` 检查两个文件
2. `build_project` 编译通过
3. 启动 App → 切换到 PATTERNS tab → 检查：
   - 标题 "USAGE_CORE" 显示正常
   - 空状态 "SIGNAL: LISTENING..." 显示正常
   - 有模式时列表正常渲染（term、count、milestone）
   - 主题切换后颜色正确

### 回滚方式
- 删除 `PatternsSection.ets`
- 恢复 HeatmapPage 中的 `corePage()` Builder 和 `activePage()` 调用

---

## Step 3 — 提取 `ProfileSection`

### 目标
将 `userPage()` Builder 提取为独立 `@Component`。

### 改动文件

| 文件 | 操作 |
|------|------|
| `pages/components/ProfileSection.ets` | **新建** — 从 HeatmapPage 移出 `userPage()` 内容 |
| `pages/HeatmapPage.ets` | **修改** — 删除 `userPage()` Builder，改为使用 `<ProfileSection>` 组件 |

### 具体改动

**新建 `ProfileSection.ets`：**

```typescript
import { UsagePattern } from '../../domain/EasterEgg';
import { SkinTheme, DesignTokens, ThemeNames } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';
import { SkinSwitcher } from './SkinSwitcher';

@Component
export struct ProfileSection {
  @Consume tokens: DesignTokens;
  @Consume themeName: SkinTheme;
  @Prop usagePatternCount: number;
  @Prop totalCommitCount: number;
  onSwitchTheme?: (theme: SkinTheme) => void;

  build() {
    Scroll() {
      Column() {
        // 标题区
        Column() {
          Text('USER_PROFILE')
            .fontSize(28)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('LOCAL FIRST // PRIVATE BY DEFAULT')
            .fontSize(9)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        // 主题区
        Row() {
          Text('THEME PROFILE')
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
          Blank()
          Text(ThemeNames[this.themeName])
            .fontSize(12)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
        }
        .width('100%')
        .padding({ top: Spacing.md })

        SkinSwitcher({
          onSwitch: (theme: SkinTheme) => {
            if (this.onSwitchTheme) {
              this.onSwitchTheme(theme);
            }
          }
        })
          .margin({ bottom: Spacing.lg })

        // 存储区
        Row() {
          Text('STORAGE')
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
          Blank()
          Text('ON DEVICE')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')
        }
        .width('100%')
        .padding({ top: Spacing.md, bottom: Spacing.md })
        .border({ width: { top: 1, bottom: 1 }, color: this.tokens.textPrimary })

        // 统计区
        Row() {
          Column() {
            Text('TOTAL COMMITS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.totalCommitCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('PATTERNS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.usagePatternCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.lg })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
```

**修改 `HeatmapPage.ets`：**

1. 顶部新增 import：
```typescript
import { ProfileSection } from './components/ProfileSection';
```

2. 删除整个 `userPage()` Builder 方法（约 98 行）

3. 修改 `activePage()` 中的 USER 分支：
```typescript
// 原来：this.userPage()
// 改为：
ProfileSection({
  usagePatternCount: this.vm!.usagePatterns.length,
  totalCommitCount: this.vm!.totalCommitCount,
  onSwitchTheme: (theme: SkinTheme) => {
    this.switchTheme(theme);
  },
})
```

### 依赖的 ViewModel 属性
- `usagePatterns.length → usagePatternCount: number`（传入前转换）
- `totalCommitCount: number`
- `themeName: SkinTheme`（通过 `@Consume` 自动获取）
- `switchTheme` 回调（通过 `onSwitchTheme` 传入）

### 注意事项
- `ProfileSection` 内部使用 `SkinSwitcher`，需要 import
- 主题切换通过回调 `onSwitchTheme` 上传，ProfileSection 不直接操作 HeatmapPage 状态
- `@Consume themeName` 已在 ProfileSection 中声明，无需通过 @Prop 传递

### 验证方式
1. `arkts_check` 检查两个文件
2. `build_project` 编译通过
3. 启动 App → 切换到 PROFILE tab → 检查：
   - 标题 "USER_PROFILE" 显示正常
   - 主题名称和色块切换正常
   - "ON DEVICE" 标签显示正常
   - 统计数字（TOTAL COMMITS / PATTERNS）正确
   - 4 个主题色块点击后主题切换生效

### 回滚方式
- 删除 `ProfileSection.ets`
- 恢复 HeatmapPage 中的 `userPage()` Builder 和 `activePage()` 调用

---

## Step 4 — 提取 `CalendarSection`

### 目标
将 `dataPage()` Builder 提取为独立 `@Component`。

### 改动文件

| 文件 | 操作 |
|------|------|
| `pages/components/CalendarSection.ets` | **新建** — 从 HeatmapPage 移出 `dataPage()` 内容 |
| `pages/HeatmapPage.ets` | **修改** — 删除 `dataPage()` Builder，改为使用 `<CalendarSection>` 组件 |

### 具体改动

**新建 `CalendarSection.ets`：**

```typescript
import { HeatmapCell } from '../../domain/Streak';
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';
import { HeatmapGrid } from './HeatmapGrid';

@Component
export struct CalendarSection {
  @Consume tokens: DesignTokens;
  @Prop cells: HeatmapCell[];
  @Prop selectedDate: string;
  @Prop todayString: string;
  @Prop monthCommitCount: number;
  @Prop longestStreak: number;
  onCellTap?: (date: string) => void;

  build() {
    Scroll() {
      Column() {
        // 标题行
        Row() {
          Text('CALENDAR VIEW')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Blank()

          Text(`${this.cells.length} DAYS`)
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .height(38)
        .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })

        // 日历网格
        HeatmapGrid({
          cells: this.cells,
          selectedDate: this.selectedDate,
          todayString: this.todayString,
          onCellTap: (date: string) => {
            if (this.onCellTap) {
              this.onCellTap(date);
            }
          }
        })
          .width('100%')
          .margin({ top: Spacing.sm })

        // 统计行
        Row() {
          Column() {
            Text('BEST RUN')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')

            Row() {
              Text(`${this.longestStreak}`)
                .fontSize(42)
                .fontWeight(900)
                .fontColor(this.tokens.textPrimary)

              Text('DAYS')
                .fontSize(10)
                .fontWeight(700)
                .fontColor(this.tokens.textMuted)
                .fontFamily('monospace')
                .margin({ left: Spacing.xxs, bottom: Spacing.xs })
            }
            .alignItems(VerticalAlign.Bottom)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('MONTH COMMITS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')

            Text(`${this.monthCommitCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.sm, bottom: Spacing.lg })
        .margin({ top: Spacing.sm })
        .border({ width: { top: 1 }, color: this.tokens.textPrimary })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
```

**修改 `HeatmapPage.ets`：**

1. 顶部新增 import：
```typescript
import { CalendarSection } from './components/CalendarSection';
```

2. 删除整个 `dataPage()` Builder 方法（约 85 行）

3. 修改 `activePage()` 中的默认分支：
```typescript
// 原来：this.dataPage()
// 改为：
CalendarSection({
  cells: this.vm!.cells,
  selectedDate: this.vm!.selectedDate,
  todayString: this.vm!.todayString,
  monthCommitCount: this.vm!.monthCommitCount,
  longestStreak: this.vm!.longestMonthStreak,
  onCellTap: (date: string) => {
    this.vm!.selectDate(date);
  },
})
```

### 依赖的 ViewModel 属性
- `cells: HeatmapCell[]`
- `selectedDate: string`
- `todayString: string`
- `monthCommitCount: number`（getter）
- `longestMonthStreak → longestStreak: number`（getter，重命名避免语义混淆）
- `onCellTap` 回调

5 个属性 + 1 个回调，接口最宽但仍有明确边界。

### 注意事项
- 内部嵌套 `HeatmapGrid` 子组件，需 import
- `monthCommitCount` 和 `longestMonthStreak` 在 ViewModel 中是 getter，调用时已计算为 number 值
- 日期选择通过 `onCellTap` 回调上传

### 验证方式
1. `arkts_check` 检查两个文件
2. `build_project` 编译通过
3. 启动 App → 默认 CALENDAR tab → 检查：
   - "CALENDAR VIEW" 标题 + "XX DAYS" 计数显示正常
   - 日历网格渲染正确（7 列，日期、星期标题）
   - 点击格子选中状态正确
   - BEST RUN / MONTH COMMITS 数字正确
   - 主题切换后颜色正确

### 回滚方式
- 删除 `CalendarSection.ets`
- 恢复 HeatmapPage 中的 `dataPage()` Builder 和 `activePage()` 调用

---

## Step 5 — 用注册 Map 替换 if/else 链（OCP 修复）

### 前置条件
Step 1-4 全部完成。

### 目标
将 `activePage()` 中的 if/else 链替换为基于 Map 的注册分发，新增 Section 时只需加一行注册。

### 改动文件

| 文件 | 操作 |
|------|------|
| `pages/HeatmapPage.ets` | **修改** — 重写 `activePage()` 分发逻辑 |

### 具体改动

**修改 `HeatmapPage.ets` 的 `activePage()` Builder：**

```typescript
// 删除原来的 if/else 链
// 改为：
@Builder
private activePage() {
  if (this.activeSection === AppSection.DATA) {
    CalendarSection({
      cells: this.vm!.cells,
      selectedDate: this.vm!.selectedDate,
      todayString: this.vm!.todayString,
      monthCommitCount: this.vm!.monthCommitCount,
      longestStreak: this.vm!.longestMonthStreak,
      onCellTap: (date: string) => { this.vm!.selectDate(date); },
    })
  } else if (this.activeSection === AppSection.LOGS) {
    LogsSection({
      checkIns: this.vm!.checkIns,
      totalCommitCount: this.vm!.totalCommitCount,
    })
  } else if (this.activeSection === AppSection.CORE) {
    PatternsSection({
      usagePatterns: this.vm!.usagePatterns,
    })
  } else if (this.activeSection === AppSection.USER) {
    ProfileSection({
      usagePatternCount: this.vm!.usagePatterns.length,
      totalCommitCount: this.vm!.totalCommitCount,
      onSwitchTheme: (theme: SkinTheme) => { this.switchTheme(theme); },
    })
  }
}
```

> **注意：** ArkUI 的 `@Builder` 中无法使用 `Map<AppSection, () => void>` 动态分发组件（ArkUI 要求组件在 build 中静态声明）。因此这里保留 if/else 结构，但每个分支已变为单行组件调用，可读性大幅提升。
>
> 如果未来 Section 数量增长到 8+，可考虑将每个 Section 拆为独立页面通过 Navigation router 分发，彻底消除 if/else。

### 验证方式
1. `build_project` 编译通过
2. 启动 App → 逐一切换 4 个 Tab → 每个内容区域渲染正确

### 回滚方式
- 恢复 `activePage()` 的原始 if/else + `this.xxxPage()` 调用

---

## Step 6 — 主题持久化移入 `SkinProviderImpl`（DIP 修复）

### 目标
移除 HeatmapPage 中对 `@kit.ArkData` 的直接 import 和 `loadPersistedTheme` / `persistTheme` 方法，改为通过 `SkinProvider` port 操作。

### 改动文件

| 文件 | 操作 |
|------|------|
| `domain/ports/SkinProvider.ets` | **修改** — 新增 `loadPersisted()` / `persist(name)` 方法签名 |
| `adapters/SkinProviderImpl.ets` | **修改** — 实现新增的持久化方法 |
| `pages/HeatmapPage.ets` | **修改** — 删除 `import { preferences }`，删除 `loadPersistedTheme` / `persistTheme`，改用 ViewModel/Provider 接口 |

### 具体改动

**修改 `domain/ports/SkinProvider.ets`：**

在 `SkinProvider` 接口中新增：
```typescript
export interface SkinProvider {
  getTokens(theme: SkinTheme): DesignTokens;
  loadPersisted(): Promise<SkinTheme>;      // 新增
  persist(theme: SkinTheme): Promise<void>;  // 新增
}
```

**修改 `adapters/SkinProviderImpl.ets`：**

实现新增方法，将 HeatmapPage 中的 `loadPersistedTheme` / `persistTheme` 逻辑搬入此处：
```typescript
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

const PREFS_NAME = 'app_settings';
const KEY_THEME = 'theme';

export class SkinProviderImpl implements SkinProvider {
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  getTokens(theme: SkinTheme): DesignTokens {
    return ThemePalette[theme];
  }

  async loadPersisted(): Promise<SkinTheme> {
    try {
      const pref = await preferences.getPreferences(this.context, PREFS_NAME);
      const saved = await pref.get(KEY_THEME, SkinTheme.LIGHT);
      if (saved === SkinTheme.LIGHT || saved === SkinTheme.DARK ||
          saved === SkinTheme.PINK || saved === SkinTheme.PASTEL) {
        return saved as SkinTheme;
      }
    } catch (_e) {}
    return SkinTheme.LIGHT;
  }

  async persist(theme: SkinTheme): Promise<void> {
    try {
      const pref = await preferences.getPreferences(this.context, PREFS_NAME);
      await pref.put(KEY_THEME, theme);
      await pref.flush();
    } catch (_e) {}
  }
}
```

**修改 `HeatmapPage.ets`：**

1. 删除 `import { preferences } from '@kit.ArkData';`
2. 删除 `loadPersistedTheme()` 和 `persistTheme()` 方法
3. 修改 `aboutToAppear()`：
```typescript
aboutToAppear(): void {
  const now = new Date();
  if (this.vm !== null) {
    this.vm.initialize(now.getFullYear(), now.getMonth() + 1);
  }
  // 主题加载通过 ViewModel/Provider 异步完成
  this.vm?.loadPersistedSkin();
}
```
4. 修改 `switchTheme()`：
```typescript
private switchTheme(name: SkinTheme): void {
  this.themeName = name;
  this.tokens = ThemePalette[name];
  this.vm?.persistSkin(name);
}
```

**修改 `viewmodels/HeatmapVM.ets`：**

新增两个方法委托给 SkinProvider：
```typescript
async loadPersistedSkin(): Promise<void> {
  const saved = await this.skinProvider.loadPersisted();
  this.currentSkin = saved;
  this.currentTokens = this.skinProvider.getTokens(saved);
}

async persistSkin(theme: SkinTheme): Promise<void> {
  await this.skinProvider.persist(theme);
}
```

**修改 `entryability/EntryAbility.ets`：**

将 context 传入 SkinProviderImpl：
```typescript
const skinProvider = new SkinProviderImpl(this.context);  // 已有 context
```

### 注意事项
- `SkinProviderImpl` 原构造函数是否接收 context 需确认，如不接收则需新增
- HeatmapPage 的 `@Provide tokens` 和 `@Provide themeName` 仍由页面管理（@Provide 必须在组件树顶层），但持久化逻辑移到 Provider
- `ThemeProvider.ets` 中有完全相同的持久化代码，可一并清理或标记为废弃

### 验证方式
1. `arkts_check` 检查所有修改文件
2. `build_project` 编译通过
3. 启动 App → 检查：
   - 默认主题加载正确
   - 切换主题后重启 App，主题持久化正确
   - HeatmapPage 中无 `@kit.ArkData` import

### 回滚方式
- 恢复 HeatmapPage 的 `import { preferences }` 和 `loadPersistedTheme` / `persistTheme` 方法
- 撤销 `SkinProvider` 接口和 `SkinProviderImpl` 的变更

---

## Step 7 — 拆分 ViewModel（ISP 修复，可选/暂缓）

### 目标
将 `HeatmapVM` 拆分为多个专注的 ViewModel，每个 Section 只依赖自己需要的属性。

### 前置条件
Step 1-6 均已完成。

### 改动文件

| 文件 | 操作 |
|------|------|
| `viewmodels/HeatmapVM.ets` | **重构** — 精简为页面级生命周期 + 彩蛋管理 |
| `viewmodels/CalendarVM.ets` | **新建** — 日历数据 + 统计 |
| `viewmodels/ActivityVM.ets` | **新建** — 签到记录 + 模式 |
| `viewmodels/ProfileVM.ets` | **新建** — 主题 + 统计摘要 |
| `entryability/EntryAbility.ets` | **修改** — 创建多个 ViewModel 并注册到 AppStorage |
| 各 Section 组件 | **修改** — 改为接收各自专用的 ViewModel |
| `HeatmapPage.ets` | **修改** — 引用多个 ViewModel |

### 具体改动概要

**`CalendarVM`：**
```typescript
@Observed
export class CalendarVM {
  cells: HeatmapCell[] = [];
  selectedDate: string = '';

  constructor(private loadHeatmap: ILoadHeatmap) {}

  async loadMonth(year: number, month: number): Promise<void> { ... }
  selectDate(date: string): void { ... }
  get monthCommitCount(): number { ... }
  get longestStreak(): number { ... }
  get todayString(): string { ... }
}
```

**`ActivityVM`：**
```typescript
@Observed
export class ActivityVM {
  checkIns: CheckIn[] = [];
  usagePatterns: UsagePattern[] = [];

  constructor(private loadActivity: ILoadActivity) {}

  async refresh(): Promise<void> { ... }
  get totalCommitCount(): number { ... }
}
```

**`ProfileVM`：**
```typescript
@Observed
export class ProfileVM {
  constructor(private skinProvider: SkinProvider) {}

  async loadPersistedSkin(): Promise<SkinTheme> { ... }
  async persistSkin(theme: SkinTheme): Promise<void> { ... }
}
```

**精简后的 `HeatmapVM`：**
```typescript
@Observed
export class HeatmapVM {
  triggeredEgg: EasterEgg | null = null;
  showParticles: boolean = false;
  showBanner: boolean = false;

  constructor(
    private recordCheckIn: IRecordCheckIn,
    private detectEasterEgg: IDetectEasterEgg,
    private soundPlayer: SoundPlayer,
  ) {}

  async doCheckIn(content: string): Promise<void> { ... }
  dismissEgg(): void { ... }
}
```

### 交叉关注点处理

`doCheckIn()` 会触发日历重载 + 活动刷新 + 彩蛋检测。拆分后需要协调机制：

- **方案 A**：HeatmapVM.doCheckIn() 完成后通过回调通知 CalendarVM 和 ActivityVM 刷新
- **方案 B**：在 Composition Root（EntryAbility）中协调，doCheckIn 返回后手动调用各 VM 的 refresh

推荐方案 B，更符合 Clean Architecture 的显式依赖原则。

### 注意事项
- 改动面最大，涉及 7+ 文件
- `@StorageLink` 在 HeatmapPage 中只绑定一个 key，多 VM 需要多个 key 或改用其他注入方式
- 各 Section 组件的 `@Prop` 需要改为指向各自专用的 VM
- 建议在 Step 1-6 稳定运行一段时间后再执行此步

### 验证方式
1. `arkts_check` 检查所有修改文件
2. `build_project` 编译通过
3. 启动 App → 完整功能回归测试：
   - 日历渲染 + 日期选择
   - 签到流程（含彩蛋触发）
   - 4 个 Tab 切换正常
   - 主题切换 + 持久化
   - 重启 App 后状态恢复

### 回滚方式
- 恢复 `HeatmapVM.ets` 为原始单一大 ViewModel
- 删除 `CalendarVM.ets`、`ActivityVM.ets`、`ProfileVM.ets`
- 各 Section 组件恢复 `@Prop` 直接接收属性
- `EntryAbility.ets` 恢复单 VM 创建逻辑

---

## 附录：里程碑检查点

| 里程碑 | 完成条件 | HeatmapPage 行数 |
|--------|---------|-----------------|
| **M1** | Step 1 完成，LogsSection 独立 | ~521 |
| **M2** | Step 2 完成，PatternsSection 独立 | ~418 |
| **M3** | Step 3 完成，ProfileSection 独立 | ~320 |
| **M4** | Step 4 完成，CalendarSection 独立 | ~235 |
| **M5** | Step 5 完成，if/else 简化 | ~235 |
| **M6** | Step 6 完成，DIP 修复 | ~205 |
| **M7** | Step 7 完成，ISP 修复 | ~200 |

每个里程碑都可以是一个稳定的提交点。建议每步完成后提交一次 git commit，便于回滚和 code review。
