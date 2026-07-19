# Actrace App端多主题设计规范 (Design System) — ArkTS/ArkUI

> 当前版本：v3.0 (鸿蒙 ArkUI)
> 适用平台：HarmonyOS (ArkTS + ArkUI)
> 主题包含：清爽浅蓝 (Light)、深海暗夜 (Dark)、魔法少女粉 (Pink)、马卡龙幻梦 (Pastel)

本文档是针对鸿蒙 ArkUI 的 Touch-first 设计规范。所有 UI 组件通过 **ThemeProvider 全局状态** 或 **`$r()` 资源引用** 获取色值，严禁在组件中硬编码 Hex 色值。

---

## 🏗️ 〇、ArkUI 主题管理架构

ArkUI 中实现多主题（不仅限于系统 Dark/Light），推荐以下方案：

### 方案：@Provide / @Consume + Theme 模型类

性能最优，支持运行时切换任意主题，无需重启应用。

```typescript
// === models/ThemeModel.ets ===

/** 主题名称 */
export type ThemeName = 'light' | 'dark' | 'pink' | 'pastel'

/** 设计令牌集 */
export class DesignTokens {
  // 基础表面
  bgBase: ResourceColor = '#F8FAFC'
  bgSurface: ResourceColor = '#FFFFFF'
  bgSurfacePressed: ResourceColor = '#E0F2FE'
  borderColor: ResourceColor = '#E2E8F0'

  // 文本
  textPrimary: ResourceColor = '#0F172A'
  textSecondary: ResourceColor = '#334155'
  textMuted: ResourceColor = '#64748B'
  textPlaceholder: ResourceColor = '#94A3B8'

  // 品牌色
  brandPrimary: ResourceColor = '#0EA5E9'
  brandActive: ResourceColor = '#0369A1'
  brandLight: ResourceColor = '#F0F9FF'
  brandText: ResourceColor = '#0284C7'
  brandAccent: ResourceColor = '#F59E0B'
}

// === models/ThemeData.ets ===

/** 四个主题的完整色板 */
export const ThemePalette: Record<ThemeName, DesignTokens> = {
  light: {
    bgBase: '#F8FAFC',
    bgSurface: '#FFFFFF',
    bgSurfacePressed: '#E0F2FE',
    borderColor: '#E2E8F0',
    textPrimary: '#0F172A',
    textSecondary: '#334155',
    textMuted: '#64748B',
    textPlaceholder: '#94A3B8',
    brandPrimary: '#0EA5E9',
    brandActive: '#0369A1',
    brandLight: '#F0F9FF',
    brandText: '#0284C7',
    brandAccent: '#F59E0B',
  } as DesignTokens,
  dark: {
    bgBase: '#080C10',
    bgSurface: '#161B22',
    bgSurfacePressed: '#30363D',
    borderColor: '#30363D',
    textPrimary: '#F0F6FC',
    textSecondary: '#C9D1D9',
    textMuted: '#8B949E',
    textPlaceholder: '#6E7681',
    brandPrimary: '#3B82F6',
    brandActive: '#2563EB',
    brandLight: 'rgba(59,130,246,0.15)',       // 注意 ArkUI 无空格写法
    brandText: '#93C5FD',
    brandAccent: '#F43F5E',
  } as DesignTokens,
  pink: {
    bgBase: '#FFF1F2',
    bgSurface: '#FFFFFF',
    bgSurfacePressed: '#FECDD3',
    borderColor: '#FECDD3',
    textPrimary: '#4C1D95',
    textSecondary: '#701A75',
    textMuted: '#9D174D',
    textPlaceholder: '#F472B6',
    brandPrimary: '#FF4D94',
    brandActive: '#BE185D',
    brandLight: '#FCE7F3',
    brandText: '#BE185D',
    brandAccent: '#FBBF24',
  } as DesignTokens,
  pastel: {
    bgBase: '#FAFAFC',
    bgSurface: '#FFFFFF',
    bgSurfacePressed: '#F2F5FF',
    borderColor: '#EBF0F7',
    textPrimary: '#3D3E50',
    textSecondary: '#6E7085',
    textMuted: '#A3A5B8',
    textPlaceholder: '#C5C7D9',
    brandPrimary: '#85A3F7',
    brandActive: '#6B8CE8',
    brandLight: '#F2F5FF',
    brandText: '#6B8CE8',
    brandAccent: '#FF9BAD',
  } as DesignTokens,
}
```

### 主题提供者（根组件包裹）

```typescript
// === components/ThemeProvider.ets ===

@Component
export struct ThemeProvider {
  /** 用 @Provide 向整个组件树下发当前令牌 */
  @Provide @Watch('onThemeChange') tokens: DesignTokens = ThemePalette.light
  @Provide themeName: ThemeName = 'light'

  @BuilderParam child: () => void

  onThemeChange(): void {
    // tokens 变化时 ArkUI 自动触发子树重绘，无需额外操作
  }

  /** 运行时切换主题 */
  switchTheme(name: ThemeName): void {
    this.themeName = name
    this.tokens = ThemePalette[name]
  }

  build() {
    Column() {
      this.child()
    }
    .backgroundColor(this.tokens.bgBase)
  }
}
```

### 子组件消费主题

```typescript
// === 任意子组件 ===

@Component
export struct MyCard {
  /** 从祖先 ThemeProvider 读取当前令牌 */
  @Consume tokens: DesignTokens

  build() {
    Column() {
      Text('标题')
        .fontColor(this.tokens.textPrimary)
      Text('描述')
        .fontColor(this.tokens.textSecondary)
    }
    .backgroundColor(this.tokens.bgSurface)
    .borderRadius(16)
    // 👇 按压态通过 stateStyles 绑定
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
      }
    })
  }
}
```

> **注意**：`stateStyles` 内的链式属性需要使用 ArkUI 的 `Bind()` 语法或直接传入属性对象。具体写法见下文组件交互章节。

---

## 🎨 一、四大主题色板 Tokens

### 1. 清爽浅蓝 (Light Mode) — 默认主题

> **设计语言**：极致留白，清爽无负担。
> **适用场景**：日间阅读、高效率打卡、常规工具流。

| Token | 色值 | 用途 |
|---|---|---|
| `bgBase` | `#F8FAFC` | 底层大背景 |
| `bgSurface` | `#FFFFFF` | 卡片、弹窗主体纯白背景 |
| `bgSurfacePressed` | `#E0F2FE` | 按压卡片/列表时的浅蓝高亮 |
| `borderColor` | `#E2E8F0` | 分割线与边框 |
| `textPrimary` | `#0F172A` | 大标题、核心数据（近黑） |
| `textSecondary` | `#334155` | 正文、常规列表文字 |
| `textMuted` | `#64748B` | 次要信息、时间戳 |
| `textPlaceholder` | `#94A3B8` | 占位符、未激活图标 |
| `brandPrimary` | `#0EA5E9` | 主按钮、激活图标 (Sky Blue) |
| `brandActive` | `#0369A1` | 主按钮按压深色反馈 |
| `brandLight` | `#F0F9FF` | 选中状态浅底色 |
| `brandText` | `#0284C7` | 浅底色上的高亮文字 |
| `brandAccent` | `#F59E0B` | 辅助强调色 (琥珀黄) |

---

### 2. 深海暗夜 (Dark Mode)

> **设计语言**：沉浸、极客感，赛博朋克调性。
> **适用场景**：深夜 Coding、暗色模式偏好。

| Token | 色值 | 用途 |
|---|---|---|
| `bgBase` | `#080C10` | 全局极暗底色 |
| `bgSurface` | `#161B22` | 卡片与主体内容区 |
| `bgSurfacePressed` | `#30363D` | 按压高亮反馈 |
| `borderColor` | `#30363D` | 暗色分割线 |
| `textPrimary` | `#F0F6FC` | 亮白主标题 |
| `textSecondary` | `#C9D1D9` | 浅灰正文 |
| `textMuted` | `#8B949E` | 暗灰辅助信息 |
| `textPlaceholder` | `#6E7681` | 占位符 |
| `brandPrimary` | `#3B82F6` | 主品牌色 (亮蓝) |
| `brandActive` | `#2563EB` | 按钮按压确认感深蓝 |
| `brandLight` | `rgba(59,130,246,0.15)` | 半透明高亮底色 |
| `brandText` | `#93C5FD` | 亮蓝文字 |
| `brandAccent` | `#F43F5E` | 辅助强调色 (霓虹红) |

---

### 3. 魔法少女粉 (Pink Mode)

> **设计语言**：高能量、猛男必选，大面积白+高饱和度粉。
> **适用场景**：二次元浓度拉满、成就解锁。

| Token | 色值 | 用途 |
|---|---|---|
| `bgBase` | `#FFF1F2` | 极微弱粉色底层 |
| `bgSurface` | `#FFFFFF` | 纯白卡片 |
| `bgSurfacePressed` | `#FECDD3` | 按压时的粉红反馈 |
| `borderColor` | `#FECDD3` | 粉色分割线 |
| `textPrimary` | `#4C1D95` | 紫黑色主标题 |
| `textSecondary` | `#701A75` | 深紫红正文 |
| `textMuted` | `#9D174D` | 玫瑰红辅助 |
| `textPlaceholder` | `#F472B6` | 占位文字 |
| `brandPrimary` | `#FF4D94` | 核心粉色 |
| `brandActive` | `#BE185D` | 按压深红粉 |
| `brandLight` | `#FCE7F3` | 选中浅粉底色 |
| `brandText` | `#BE185D` | 强调文字 |
| `brandAccent` | `#FBBF24` | 辅助强调色 (明黄色) |

---

### 4. 马卡龙幻梦 (Pastel Dream) 🌟

> **设计语言**：克制、柔软、充满呼吸感。双拼糖果色。
> **适用场景**：治愈系记录、轻量级打卡。

| Token | 色值 | 用途 |
|---|---|---|
| `bgBase` | `#FAFAFC` | 带紫/蓝灰倾向的通透白 |
| `bgSurface` | `#FFFFFF` | 纯白卡片 |
| `bgSurfacePressed` | `#F2F5FF` | 按压时的极浅云朵蓝 |
| `borderColor` | `#EBF0F7` | 几乎无感的柔和边框 |
| `textPrimary` | `#3D3E50` | 柔和深蓝灰大标题 |
| `textSecondary` | `#6E7085` | 常规列表文字 |
| `textMuted` | `#A3A5B8` | 次要信息 |
| `textPlaceholder` | `#C5C7D9` | 占位符 |
| `brandPrimary` | `#85A3F7` | 核心骨架色 (长春花蓝) |
| `brandActive` | `#6B8CE8` | 按压反馈深蓝 |
| `brandLight` | `#F2F5FF` | 选中浅蓝底色 |
| `brandText` | `#6B8CE8` | 文本蓝 |
| `brandAccent` | `#FF9BAD` | 灵魂辅助色 (珊瑚软粉) |

---

## 📏 二、全局基础规范 (Global Tokens)

### 1. 字体层级 (Typography)

ArkUI 使用 `fp` 作为字体单位（跟随系统字号缩放），`vp` 用于其他尺寸。

| 层级 | 规格 | 实现 |
|---|---|---|
| **大标题 H1** | `24fp`，字重 `700`，字距 `-0.5vp` | `.fontSize(24).fontWeight(700).letterSpacing(-0.5)` |
| **卡片标题 H2** | `18fp`，字重 `600`，字距 `-0.3vp` | `.fontSize(18).fontWeight(600).letterSpacing(-0.3)` |
| **正文 Body** | `15fp`，字重 `400`/`500`，行高 `1.5` | `.fontSize(15).fontWeight(400).lineHeight(22.5)` |
| **辅助 Caption** | `12fp`/`13fp`，字重 `400` | `.fontSize(12).fontWeight(400)` |

```typescript
// === common/TypographyStyles.ets ===

/** 全局字体样式函数（@Styles 不支持传参，用 @Extend 或独立函数） */
@Extend(Text)
function h1Style(): void {
  .fontSize(24)
  .fontWeight(700)
  .letterSpacing(-0.5)
}

@Extend(Text)
function h2Style(): void {
  .fontSize(18)
  .fontWeight(600)
  .letterSpacing(-0.3)
}

@Extend(Text)
function bodyStyle(): void {
  .fontSize(15)
  .fontWeight(400)
  .lineHeight(22.5)   // 15 × 1.5 = 22.5fp
}

@Extend(Text)
function captionStyle(): void {
  .fontSize(12)
  .fontWeight(400)
}
```

### 2. 空间与间距 (Spacing)

```typescript
// === common/SpacingTokens.ets ===

/** 全局间距常量 */
export class Spacing {
  static readonly xs: number = 8   // vp — 元素内间距（图标与文字间）
  static readonly sm: number = 12  // vp — 紧密组件间距
  static readonly md: number = 16  // vp — 黄金边距，页面左右 Padding
  static readonly lg: number = 24  // vp — 大模块或卡片之间的垂直间距
}
```

使用示例：

```typescript
Column() { /* ... */ }
  .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.lg })
  .margin({ bottom: Spacing.sm })
```

### 3. 圆角与阴影 (Radius & Shadows)

```typescript
// === common/RadiusTokens.ets ===

export class Radius {
  static readonly lg: number = 16      // vp — 卡片圆角
  static readonly md: number = 12      // vp — 按钮圆角
  static readonly pill: number = 9999  // vp — 徽章/胶囊圆角
}
```

阴影规范（仅用于 FAB 或重要弹窗，常规卡片扁平化）：

| 主题 | 阴影参数 | ArkUI 写法 |
|---|---|---|
| 浅色/粉色/马卡龙 | `radius: 16, color: rgba(0,0,0,0.06), offsetY: 4` | `.shadow({ radius: 16, color: 'rgba(0,0,0,0.06)', offsetY: 4 })` |
| 暗色 | `radius: 24, color: rgba(0,0,0,0.4), offsetY: 8` | `.shadow({ radius: 24, color: 'rgba(0,0,0,0.4)', offsetY: 8 })` |
| 马卡龙弥散光 | `radius: 24, color: rgba(133,163,247,0.15), offsetY: 8` | `.shadow({ radius: 24, color: 'rgba(133,163,247,0.15)', offsetY: 8 })` |

> ⚠️ ArkUI 的 `.shadow()` 不支持 `spread`（扩散半径），视觉上用 `radius` 调大补偿。

---

## 🧩 三、核心组件 App 端交互策略

### 1. 内容列表卡片 (List Item Card)

```typescript
// === components/ListItemCard.ets ===

@Component
export struct ListItemCard {
  @Consume tokens: DesignTokens
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop selected: boolean = false
  @Prop showDivider: boolean = true
  onPress?: () => void

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(15)
          .fontWeight(500)
          .fontColor(this.tokens.textPrimary)
        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(this.tokens.textMuted)
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.sm })
    .backgroundColor(this.selected ? this.tokens.brandLight : this.tokens.bgSurface)
    .border({
      width: this.showDivider ? { bottom: 0.5 } : 0,
      color: this.tokens.borderColor
    })
    .stateStyles({
      // 👇 按压态：瞬间变色，松手恢复
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
      }
    })
    .onClick(() => {
      this.onPress?.()
    })
  }
}
```

| 状态 | 表现 | 实现方式 |
|---|---|---|
| **常规 (Idle)** | 背景 `bgSurface`，底部分割线 `borderColor` | 默认属性 |
| **按压 (Pressed)** | 背景立刻变为 `bgSurfacePressed` | `.stateStyles({ pressed: {...} })` |
| **选中 (Selected)** | 背景常驻 `brandLight` | `@Prop selected` 控制 `.backgroundColor()` |

> 马卡龙主题建议去掉分割线，仅用背景色差区分卡片。

---

### 2. 悬浮行动按钮 (FAB)

```typescript
// === components/FloatingActionButton.ets ===

@Component
export struct FloatingActionButton {
  @Consume tokens: DesignTokens
  @Consume themeName: ThemeName
  @Prop icon: Resource = $r('app.media.ic_add')
  onPress?: () => void

  /** 马卡龙主题用 accent 色，其他主题用 primary */
  private fabColor(): ResourceColor {
    return this.themeName === 'pastel'
      ? this.tokens.brandAccent
      : this.tokens.brandPrimary
  }

  build() {
    Button({ type: ButtonType.Circle }) {
      Image(this.icon)
        .width(24)
        .height(24)
        .fillColor(Color.White)
    }
    .width(56)
    .height(56)
    .backgroundColor(this.fabColor())
    .shadow({
      radius: 16,
      color: this.themeName === 'dark'
        ? 'rgba(0,0,0,0.4)'
        : 'rgba(0,0,0,0.06)',
      offsetY: 4
    })
    .position({ x: '100%', y: '100%' })
    .markAnchor({ x: '100%', y: '100%' })
    .offset({ x: -Spacing.lg, y: -Spacing.lg })
    .stateStyles({
      // 👇 按压缩放反馈
      pressed: {
        .scale({ x: 0.92, y: 0.92 })
      }
    })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onClick(() => {
      this.onPress?.()
    })
  }
}
```

| 主题 | FAB 背景色 | 按压反馈 |
|---|---|---|
| Light / Dark / Pink | `brandPrimary` | `scale(0.92)` |
| Pastel | `brandAccent`（珊瑚软粉） | `scale(0.92)` |

---

### 3. 底部导航栏 (Bottom Tab Bar)

```typescript
// === components/BottomTabBar.ets ===

export interface TabItem {
  label: string
  icon: Resource
  activeIcon?: Resource
  route: string
}

@Component
export struct BottomTabBar {
  @Consume tokens: DesignTokens
  @Link currentIndex: number
  items: TabItem[] = []

  build() {
    Row() {
      ForEach(this.items, (item: TabItem, index: number) => {
        Column() {
          Image(index === this.currentIndex && item.activeIcon
            ? item.activeIcon
            : item.icon)
            .width(24)
            .height(24)
            .fillColor(index === this.currentIndex
              ? this.tokens.brandPrimary
              : this.tokens.textPlaceholder)
          Text(item.label)
            .fontSize(10)
            .fontColor(index === this.currentIndex
              ? this.tokens.brandPrimary
              : this.tokens.textPlaceholder)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.currentIndex = index
        })
      })
    }
    .width('100%')
    .height(56)
    .padding({ bottom: 8 })
    .backgroundColor(this.tokens.bgSurface)
    .border({
      width: { top: 0.5 },
      color: this.tokens.borderColor
    })
  }
}
```

| 元素 | 未激活 (Inactive) | 激活 (Active) |
|---|---|---|
| 图标 + 文字颜色 | `textPlaceholder` | `brandPrimary` |
| 背景 | `bgSurface` | `bgSurface` |

---

### 4. 主按钮 (Primary Button)

```typescript
// === components/PrimaryButton.ets ===

@Component
export struct PrimaryButton {
  @Consume tokens: DesignTokens
  @Prop label: string = '按钮'
  @Prop enabled: boolean = true
  onPress?: () => void

  build() {
    Button(this.label)
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(600)
      .fontColor(Color.White)
      .backgroundColor(this.enabled ? this.tokens.brandPrimary : this.tokens.textPlaceholder)
      .borderRadius(Radius.md)
      .enabled(this.enabled)
      .stateStyles({
        pressed: {
          .backgroundColor(this.tokens.brandActive)
          .scale({ x: 0.97, y: 0.97 })
        }
      })
      .animation({ duration: 100 })
      .onClick(() => {
        if (this.enabled) {
          this.onPress?.()
        }
      })
  }
}
```

---

### 5. 输入框 (Input Field)

```typescript
// === components/ThemedInput.ets ===

@Component
export struct ThemedInput {
  @Consume tokens: DesignTokens
  @Prop placeholder: string = '请输入...'
  @Prop @Watch('onTextChange') text: string = ''
  onChange?: (value: string) => void

  onTextChange(): void {
    this.onChange?.(this.text)
  }

  build() {
    TextInput({ text: $$this.text, placeholder: this.placeholder })
      .width('100%')
      .height(48)
      .fontSize(15)
      .fontColor(this.tokens.textPrimary)
      .placeholderColor(this.tokens.textPlaceholder)
      .backgroundColor(this.tokens.bgSurface)
      .borderRadius(Radius.md)
      .border({
        width: 1,
        color: this.tokens.borderColor
      })
      .padding({ left: Spacing.md, right: Spacing.md })
      .caretColor(this.tokens.brandPrimary)
      .stateStyles({
        focused: {
          .border({ width: 1.5, color: this.tokens.brandPrimary })
        }
      })
  }
}
```

---

## ⚠️ 四、ArkUI 开发必遵原则

### 1. 彻底摒弃 Hover 概念

ArkUI 原生就是 Touch-first，不存在 `:hover` 伪类。所有反馈通过 `stateStyles` 的 `pressed` 状态触发，杜绝需要两次点击的问题。

```typescript
// ✅ 正确：使用 stateStyles
Column()
  .stateStyles({
    pressed: {
      .backgroundColor(this.tokens.bgSurfacePressed)
    }
  })
  .onClick(() => { /* ... */ })

// ❌ 错误：不要在 ArkUI 中寻找 hover 语义
```

### 2. 强制绑定触摸反馈

所有可交互元素（卡片、按钮、列表项、图标）必须提供 `pressed` 态反馈：

```typescript
// 通用按压反馈样式函数
@Extend(Column)
function pressableCard(tokens: DesignTokens): void {
  .stateStyles({
    pressed: {
      .backgroundColor(tokens.bgSurfacePressed)
      .scale({ x: 0.98, y: 0.98 })
    }
  })
  .animation({ duration: 150, curve: Curve.EaseOut })
  .hitTestBehavior(HitTestMode.Block)
}
```

### 3. 色彩接口一致性

四个主题均提供 `brandPrimary` 和 `brandAccent`。即使在清爽浅蓝中，`accent` 颜色也可作为警示/高光使用（如黄色），确保跨主题切换时业务逻辑无需重写。

```typescript
// ✅ 跨主题一致：始终用 tokens 引用
@Consume tokens: DesignTokens

Text('成就解锁！')
  .fontColor(this.tokens.brandAccent)   // Light → 琥珀黄 | Dark → 霓虹红 | Pastel → 珊瑚粉

// ❌ 禁止：硬编码色值
Text('成就解锁！')
  .fontColor('#F59E0B')                 // 切主题后会非常违和
```

### 4. 组件风格一致性

所有组件遵循统一模式：

```typescript
// 每个组件的标准骨架
@Component
export struct ThemedXxx {
  @Consume tokens: DesignTokens         // ① 消费主题
  // ... @Prop / @Link 等业务属性       // ② 业务属性

  build() {
    Xxx()                               // ③ 原生 ArkUI 组件
      .xxxStyle(this.tokens.xxx)        // ④ 主题色绑定
      .stateStyles({ pressed: {...} })  // ⑤ 按压反馈
      .onClick(...)                     // ⑥ 事件
  }
}
```

### 5. 资源 vs 状态选择

| 场景 | 推荐方案 | 说明 |
|---|---|---|
| 仅需跟随系统 Dark/Light | `$r('app.color.xxx')` + `resources/base/color.json` | 简单，无法实现粉色/马卡龙 |
| 需四个自定义主题 | `@Provide/@Consume` + `DesignTokens` | 本文档推荐方案 |
| 需持久化主题偏好 | 额外配合 `@ohos.data.preferences` | 启动时读取上次选择 |

```typescript
// === ThemeProvider 增加持久化 ===

import preferences from '@ohos.data.preferences'

switchTheme(name: ThemeName): void {
  this.themeName = name
  this.tokens = ThemePalette[name]

  // 持久化到本地
  const ctx = getContext(this)
  preferences.getPreferences(ctx, 'app_settings', (err, pref) => {
    if (!err) {
      pref.put('theme', name, (e) => { if (!e) pref.flush() })
    }
  })
}
```

---

## 🚀 五、快速启动清单

在鸿蒙工程中接入本设计系统，按以下步骤操作：

```
1. 创建
   src/main/ets/
   ├── models/
   │   └── ThemeData.ets        ← 四大主题色板 + DesignTokens 类
   ├── common/
   │   ├── SpacingTokens.ets     ← 间距常量
   │   ├── RadiusTokens.ets      ← 圆角常量
   │   └── TypographyStyles.ets  ← @Extend 字体样式
   └── components/
       ├── ThemeProvider.ets     ← @Provide 主题根组件
       ├── ListItemCard.ets
       ├── FloatingActionButton.ets
       ├── BottomTabBar.ets
       ├── PrimaryButton.ets
       └── ThemedInput.ets

2. 入口页面 EntryAbility.ets
   build() {
     ThemeProvider({ child: () => this.buildMainPage() })
   }

3. 任意子组件中
   @Consume tokens: DesignTokens
   然后用 this.tokens.xxx 引用色值

4. 切换主题
   获取 ThemeProvider 实例 → 调用 switchTheme('pink')
```
