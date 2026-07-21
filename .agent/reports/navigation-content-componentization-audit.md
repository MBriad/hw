# Actrace 导航栏内容区域组件化审计报告

> 基于 `skill/clean-arch-app/SKILL.md` — Clean Architecture for OpenHarmony / HarmonyOS

---

## 1. 审计范围

| 项目 | 说明 |
|------|------|
| **导航栏** | `HorizontalNavigation.ets` — 4 Tab 切换 (CALENDAR / LOGS / PATTERNS / PROFILE) |
| **内容区域** | `HeatmapPage.ets` 中的 4 个 `@Builder` 方法：`dataPage()`、`logsPage()`、`corePage()`、`userPage()` |
| **路由枚举** | `AppSection.ets` — `DATA \| LOGS \| CORE \| USER` |
| **ViewModel** | `HeatmapVM.ets` — 单一 ViewModel 服务所有 4 个 Section |
| **对照参考** | `HeatmapContent.ets` — 旧版无导航的组件（未接入当前页面流） |

---

## 2. 核心发现：内容区域未组件化

### 2.1 现状总览

| 内容区域 | 实现方式 | 是否独立 `@Component` | 行数 | 文件位置 |
|----------|---------|----------------------|------|---------|
| **CALENDAR** (`dataPage`) | `HeatmapPage` 内 `@Builder` | ❌ 否 | ~85 行 | `HeatmapPage.ets:112-196` |
| **LOGS** (`logsPage`) | `HeatmapPage` 内 `@Builder` | ❌ 否 | ~77 行 | `HeatmapPage.ets:198-275` |
| **PATTERNS** (`corePage`) | `HeatmapPage` 内 `@Builder` | ❌ 否 | ~103 行 | `HeatmapPage.ets:277-380` |
| **PROFILE** (`userPage`) | `HeatmapPage` 内 `@Builder` | ❌ 否 | ~98 行 | `HeatmapPage.ets:382-480` |
| **分发逻辑** (`activePage`) | `if/else` 链 | ❌ 否 | ~12 行 | `HeatmapPage.ets:482-493` |

**结论：4 个导航内容区域全部以内联 `@Builder` 方式写在 `HeatmapPage.ets` 中，没有拆分为独立的 `@Component` 组件。**

### 2.2 与已有组件的对比

项目中已经正确组件化的部分：

| 组件 | 文件 | 行数 | 职责 |
|------|------|------|------|
| `HorizontalNavigation` | `components/HorizontalNavigation.ets` | 65 | 导航栏切换 |
| `HeatmapGrid` | `components/HeatmapGrid.ets` | 89 | 日历网格 |
| `DayCell` | `components/DayCell.ets` | 72 | 单日格子 |
| `CheckInInput` | `components/CheckInInput.ets` | 92 | 签到输入 |
| `SkinSwitcher` | `components/SkinSwitcher.ets` | 71 | 主题切换 |
| `QuoteBanner` | `components/QuoteBanner.ets` | 76 | 彩蛋横幅 |
| `ParticleOverlay` | `components/ParticleOverlay.ets` | 98 | 粒子特效 |
| `GridBackdrop` | `components/GridBackdrop.ets` | 36 | 背景网格 |

**已有 8 个组件均已独立为 `@Component`，但 4 个占页面主体内容的区域却未做同等拆分，形成了明显的架构不一致。**

---

## 3. Clean Architecture 违规详细分析

### 3.1 SRP 违规 — 单一职责原则

> Skill 规则："One reason to change per module"

**HeatmapPage.ets 当前 598 行，承担 6+ 项职责：**

1. 主题持久化（`loadPersistedTheme` / `persistTheme`）— 与 `ThemeProvider.ets` 功能重复
2. 系统头部渲染（`systemHeader`）
3. 工作区头部渲染（`workspaceHeader`）
4. **4 个内容页面渲染**（data / logs / core / user）
5. 内容分发逻辑（`activePage` 的 if/else）
6. 彩蛋特效叠加层管理

Skill 判定信号：**`@Component > 300 lines → SRP 违规，应拆分为 ViewModel + sub-components`**

HeatmapPage 远超 300 行阈值（598 行），且 `@Builder` 内含复杂布局逻辑。

### 3.2 OCP 违规 — 开闭原则

> Skill 规则："Add behavior by adding code, not editing existing code"

**`activePage()` 的 if/else 链：**

```typescript
// HeatmapPage.ets:482-493
@Builder
private activePage() {
  if (this.activeSection === AppSection.LOGS) {
    this.logsPage()
  } else if (this.activeSection === AppSection.CORE) {
    this.corePage()
  } else if (this.activeSection === AppSection.USER) {
    this.userPage()
  } else {
    this.dataPage()
  }
}
```

新增 Section 需修改此方法 + 新增 `@Builder` + 修改 `HorizontalNavigation` 的 tab 列表 — **三处编辑**而非"添加一个新组件类"。

Skill 建议：**"Replace `if/else` chains with a `Map<string, TypeHandler>` strategy registry"** 或 **"prefer `@Builder` function maps over `if/else` chains for variant rendering"**

### 3.3 ISP 违规 — 接口隔离原则

> Skill 规则："ViewModel exposing > 10 properties → split into focused ViewModels"

**HeatmapVM 当前暴露的属性：**

| 属性 | 服务哪个 Section |
|------|-----------------|
| `cells` | DATA (CALENDAR) |
| `selectedDate` | DATA + CheckInInput |
| `streakInfo` | DATA |
| `checkIns` | LOGS |
| `usagePatterns` | CORE + USER |
| `triggeredEgg` / `showParticles` / `showBanner` | 彩蛋（跨 Section） |
| `currentSkin` / `currentTokens` | USER + 全局 |
| `longestMonthStreak` (getter) | DATA |
| `monthCommitCount` (getter) | DATA |
| `totalCommitCount` (getter) | LOGS + USER |
| `monthCode` (getter) | 头部 |
| `todayString` (getter) | DATA |

共 **12+ 属性**，每个 Section 只用到其中 3-5 个。一个 LOGS 页面不需要知道 `cells`、`streakInfo`、`longestMonthStreak`；一个 DATA 页面不需要 `checkIns`、`usagePatterns`。

Skill 判定：**"A ViewModel exposing 20+ properties signals a fat interface — split it"** — 已接近阈值。

### 3.4 DIP 违规 — 依赖倒置原则

> Skill 规则："A component calling `import { http } from '@kit.NetworkKit'` directly = DIP violation"

**HeatmapPage 直接调用 `@kit.ArkData`：**

```typescript
// HeatmapPage.ets:2
import { preferences } from '@kit.ArkData';
```

页面层（最外层 View）直接操作 framework 级 API 做主题持久化，这本身就是 DIP 违规。而 `ThemeProvider.ets` 也做了完全相同的事——两者重复。

正确做法：主题持久化应通过 `SkinProvider` port（已有 `domain/ports/SkinProvider.ets`），由 adapter 处理，页面只调用 ViewModel/Provider 接口。

### 3.5 Humble Object 违规

> Skill 规则："View (ArkUI @Component): receive ViewModel, render it. No conditionals beyond if/else for display"

**各 `@Builder` 方法中包含非展示性逻辑：**

- `dataPage()` 中的 `this.vm!.cells.length` 计算和 `this.vm!.longestMonthStreak` / `this.vm!.monthCommitCount` 展示 — 纯展示但依赖 ViewModel getter
- `logsPage()` 中的 `String(this.vm!.checkIns.length - index).padStart(3, '0')` — 格式化逻辑应在 ViewModel
- `corePage()` 中的 `pattern.nextMilestone > 0 ? ... : ...` — 条件展示逻辑可接受但建议用 ViewModel 的格式化方法
- `userPage()` 中 `ThemeNames[this.themeName]` 查表 — 可接受但跨类型访问

主要 Humble Object 问题在于：**`@Builder` 不是独立的 Humble View，无法独立测试。** 如果拆为 `@Component`，则可提供 stub ViewModel 进行 UI 测试。

---

## 4. 架构依赖流向分析

### 4.1 当前依赖流

```
HeatmapPage (@Entry @Component, 598行)
  ├── 直接 import { preferences } from '@kit.ArkData'  ← DIP 违规
  ├── 直接访问 HeatmapVM 的 12+ 属性                     ← ISP 违规
  ├── 内联渲染 4 个 Section（@Builder）                 ← SRP 违规
  ├── if/else 分发                                      ← OCP 违规
  └── 主题持久化逻辑（与 ThemeProvider 重复）

应有依赖流：
pages/ → viewmodels/ → usecases/ → domain/ports
                              ↑
                         adapters/ (implement ports)
```

### 4.2 `HeatmapContent.ets` — 孤立文件

`HeatmapContent.ets`（70 行）是一个已经组件化的 `@Component`，但它：
- 不使用导航系统
- 不包含 LOGS / CORE / USER 页面
- 未被任何页面加载引用（`EntryAbility` 加载的是 `pages/HeatmapPage`）
- 与当前 HeatmapPage 的设计完全脱节

**判定：这是一个过时/弃用的文件，可能是早期重构的残留。**

---

## 5. 已有组件合规性速检

| 组件 | Humble View | `@Consume tokens` | `stateStyles` | 无业务逻辑 | 评定 |
|------|------------|-------------------|--------------|-----------|------|
| HorizontalNavigation | ✅ | ✅ | ✅ | ✅ | ✅ 合规 |
| HeatmapGrid | ✅ | ✅ | N/A (非交互) | ✅ | ✅ 合规 |
| DayCell | ✅ | ✅ | ✅ | ✅ | ✅ 合规 |
| CheckInInput | ✅ | ✅ | ✅ | ✅ | ✅ 合规 |
| SkinSwitcher | ✅ | ✅ | ✅ | ✅ | ✅ 合规 |
| QuoteBanner | ✅ | ✅ | ✅ | ✅ | ✅ 合规 |
| ParticleOverlay | ⚠️ | N/A (无 tokens) | N/A | ⚠️ 含生成逻辑 | ⚠️ 基本合规 |
| GridBackdrop | ✅ | ✅ | N/A | ✅ | ✅ 合规 |

**ParticleOverlay** 的 `generateParticles()` 包含随机数生成和物理计算（`Math.cos`/`Math.sin`），理论上可抽到 ViewModel 或纯函数，但因其为纯视觉效果且不影响业务逻辑，严重程度低。

---

## 6. 重构建议

### 6.1 拆分 4 个 Section 为独立 `@Component`

| 目标组件 | 文件路径 | 从 HeatmapPage 移出的 Builder | 需要的 ViewModel 属性 |
|----------|---------|------------------------------|---------------------|
| `CalendarSection` | `pages/components/CalendarSection.ets` | `dataPage()` | `cells`, `selectedDate`, `todayString`, `longestMonthStreak`, `monthCommitCount` |
| `LogsSection` | `pages/components/LogsSection.ets` | `logsPage()` | `checkIns`, `totalCommitCount` |
| `PatternsSection` | `pages/components/PatternsSection.ets` | `corePage()` | `usagePatterns` |
| `ProfileSection` | `pages/components/ProfileSection.ets` | `userPage()` | `usagePatterns.length`, `totalCommitCount`, `themeName`, `switchTheme()` |

### 6.2 OCP 修复 — Section 注册表

```typescript
// 用 Map 替代 if/else 链
private sectionBuilders: Map<AppSection, () => void> = new Map([
  [AppSection.DATA,   () => { CalendarSection({...}) }],
  [AppSection.LOGS,   () => { LogsSection({...}) }],
  [AppSection.CORE,   () => { PatternsSection({...}) }],
  [AppSection.USER,   () => { ProfileSection({...}) }],
]);
```

新增 Section = 新增组件文件 + 注册一行 Map entry，无需修改分发逻辑。

### 6.3 ISP 修复 — 拆分 ViewModel

当前 `HeatmapVM` 拆分建议：

| ViewModel | 职责 | 依赖的 UseCase |
|-----------|------|---------------|
| `HeatmapVM` (保留精简) | 页面级生命周期 + 彩蛋 | `DetectEasterEgg`, `SoundPlayer` |
| `CalendarVM` | 日历数据 + 统计 | `ILoadHeatmap`, `IRecordCheckIn` |
| `ActivityVM` | 签到记录 + 模式 | `ILoadActivity` |
| `ProfileVM` | 主题 + 统计摘要 | `SkinProvider` |

### 6.4 DIP 修复 — 移除页面层的 `@kit.ArkData` 直接调用

将 `HeatmapPage` 中的 `preferences` 主题持久化逻辑移至 `SkinProviderImpl` adapter（已有 `domain/ports/SkinProvider.ets`），页面只通过 ViewModel/Provider 接口操作。

### 6.5 清理孤立文件

- 删除或重构 `HeatmapContent.ets`（与当前导航架构不兼容）
- `ThemeProvider.ets` 的职责已被 `HeatmapPage` 直接承担，存在重复；应统一为一种方案

---

## 7. 风险评估

| 风险项 | 级别 | 说明 |
|--------|------|------|
| HeatmapPage 膨胀 | 🔴 高 | 598 行，继续增长将难以维护 |
| 4 个 Section 无法独立测试 | 🟡 中 | 无法提供 stub ViewModel 验证单个 Section 的渲染 |
| HeatmapVM ISP 违规 | 🟡 中 | 12+ 属性，新增 Section 会继续膨胀 |
| 主题持久化重复 | 🟢 低 | `HeatmapPage` 与 `ThemeProvider` 重复，但不影响功能 |
| `HeatmapContent.ets` 孤立 | 🟢 低 | 不影响运行，但增加理解成本 |

---

## 8. 总结

**核心结论：导航栏切换后的 4 个内容区域（CALENDAR / LOGS / PATTERNS / PROFILE）均未做成独立组件，全部以 `@Builder` 内联方式存在于 `HeatmapPage.ets` 中。**

这在 Clean Architecture 视角下产生以下违规：
- **SRP**: HeatmapPage 598 行，承担过多渲染职责
- **OCP**: `activePage()` 的 if/else 链使新增 Section 需修改多处
- **ISP**: HeatmapVM 暴露 12+ 属性服务 4 个不同 Section
- **DIP**: HeatmapPage 直接调用 `@kit.ArkData` 做持久化

而项目中 8 个已拆分的子组件（HorizontalNavigation、DayCell 等）均合规，说明团队已有组件化能力，4 个 Section 的拆分属于遗漏而非设计选择。

建议按优先级分步重构：先拆 4 个 Section 为独立 `@Component`（SRP 修复），再引入注册表替代 if/else（OCP 修复），最后考虑 ViewModel 拆分（ISP 修复）。
