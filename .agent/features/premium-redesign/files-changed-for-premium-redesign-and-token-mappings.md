# Premium Redesign 改动点与 Token 映射

## 背景

参考根目录 `actrace_premium_redesign.html` 的 Tailwind 风格，将 Apple 极简风格改造为现代亮蓝 + 毛玻璃风格。原 Apple 设计 token 已完全从 `src/style.css` 中移除，所有组件已迁移到新 token。

约束：不新增/删除组件，仅修改 UI 样式。

## 新增全局 Token

| Token | 值 | 用途 |
|---|---|---|
| `--color-slate-50` | `#f8fafc` | 页面背景 |
| `--color-slate-100` | `#f1f5f9` | hover 背景、边框 |
| `--color-slate-200` | `#e2e8f0` | 输入框边框、分隔线 |
| `--color-slate-400` | `#94a3b8` | 次要文字 |
| `--color-slate-500` | `#64748b` | 描述文字 |
| `--color-slate-800` | `#1e293b` | 深色文字 |
| `--color-slate-900` | `#0f172a` | 主标题文字 |
| `--color-brand-500` | `#3b82f6` | 主强调色 |
| `--color-brand-600` | `#2563eb` | 按钮、active 文字 |
| `--color-brand-700` | `#1d4ed8` | 按钮 hover |
| `--color-brand-50` | `#eff6ff` | active 背景 |
| `--color-indigo-500` | `#6366f1` | 渐变辅助色 |
| `--color-cyan-500` | `#0ea5e9` | 辅助渐变 |
| `--color-emerald-500` | `#10b981` | 状态指示点 |
| `--glass-bg` | `rgba(255,255,255,0.72)` | 毛玻璃卡片背景 |
| `--glass-border` | `rgba(226,232,240,0.6)` | 毛玻璃边框 |
| `--glass-backdrop` | `saturate(180%) blur(20px)` | 毛玻璃模糊 |
| `--shadow-card` | `0 10px 40px rgba(15,23,42,0.06)` | 卡片阴影 |
| `--shadow-blue` | `0 4px 14px rgba(37,99,235,0.2)` | 蓝色按钮阴影 |
| `--radius-xl` | `24px` | 大卡片圆角 |
| `--radius-2xl` | `16px` | 列表项圆角 |

## 各文件改动摘要

### `src/style.css`

- 在 `:root` 末尾追加上表所有 token。
- 原有 Apple token（`--color-primary` 等）保持不变，避免破坏未涉及视图。

### `src/App.vue`

- `.app-container` 背景改为 `--color-slate-50`。
- `.app-sidebar` 宽度 `176px → 256px`，背景改为毛玻璃白，右侧 `1px` 半透明边框。
- `.sidebar-brand` 改为图标 + 标题 + 副标题"智能活动监测中心"；Logo 使用渐变闪电 SVG。
- `tabs` 数组增加 `icon` 字段（内联 SVG），导航按钮改为 flex 图标+文字布局。
- `.nav-btn` active 状态：蓝色浅底 + 蓝色文字 + 细边框。

### `src/views/Dashboard.vue`

- 标题字号 `40px → 28px`，加粗，letter-spacing -0.5px。
- 顶部 tab active 状态改为蓝色。
- `.card` / `.heatmap-card`：毛玻璃背景、24px 圆角、卡片阴影。
- 排行项：增加 padding、16px 圆角、hover 上浮阴影。
- 能量条：改为 `linear-gradient(90deg, #3b82f6, #6366f1)`。
- 概览 donut：active 改为 `#3b82f6`，idle 改为 `#93c5fd`。
- 遥测数值改为 `--color-brand-600`。
- 热力图空/休息格颜色改为 slate-200 / blue-300。
- tooltip 背景改为 slate-900、白色文字、12px 圆角。

### `src/views/Plugins.vue`

- 侧边栏宽度略扩，标题改为 `24px / 700`。
- `.plugin-list-item` 改为独立卡片式：16px 圆角、hover 阴影、active 带品牌色边框。
- `.plugin-icon` 改为蓝到靛蓝渐变，白色图标。
- `.plugin-detail`：毛玻璃背景、24px 圆角、阴影。
- `.detail-header` 增加底部分隔线；`.detail-icon` 改为渐变、16px 圆角。
- toggle：改为 iOS 风格 44×24 pill，关闭 slate-200，开启 brand-500。
- 新增 `.detail-footer`：提示文字 + 蓝色"应用设置"按钮。

### `src/views/Settings.vue`

- `.title` 改为 `28px / 700`。
- `.card`：毛玻璃、24px 圆角、阴影。
- `.card-title`：大写、letter-spacing 加宽、slate-500。
- `.setting-row`：slate-50 背景、16px 圆角、hover 边框。
- `.setting-label` 改为 slate-900 加粗。
- `.setting-value`：白色背景、brand-600 文字、12px 圆角。
- `.btn-primary`：brand-600 背景、12px 圆角、蓝色阴影。
- `.tool-item` / `.api-item`：slate-50 背景、hover 高亮。

### `src/components/ToastCard.vue`

- 卡片背景改为 `--glass-bg`、边框 `--glass-border`、圆角 `--radius-xl`、阴影 `--shadow-card`。
- 进度条改为 brand-500 到 indigo-500 渐变。
- 标题颜色改为 `--color-slate-900`、正文改为 `--color-slate-500`。
- 关闭按钮 hover 改为 `--color-slate-100` 背景 + `--color-brand-600` 图标。

### 旧 Apple Token 清理

已从 `src/style.css` 移除的 token：

`--color-primary`、`--color-primary-focus`、`--color-primary-on-dark`、`--color-ink`、`--color-body`、`--color-body-on-dark`、`--color-body-muted`、`--color-ink-muted-80`、`--color-ink-muted-48`、`--color-divider-soft`、`--color-hairline`、`--color-canvas`、`--color-canvas-parchment`、`--color-surface-pearl`、`--color-surface-tile-*`、`--color-surface-black`、`--color-surface-chip-translucent`、`--color-on-primary`、`--color-on-dark`。

代码库中已无 `var(--color-*)` 引用这些旧 token。

## 验证

改造后执行并通过：

- `pnpm vue-tsc --noEmit`
- `pnpm build`
- `cd src-tauri && cargo check`

## 与 Apple 设计规范的差异

| 方面 | Apple 规范 | Premium Redesign |
|---|---|---|
| 强调色 | `#0066cc` | `#3b82f6 / #2563eb` |
| 卡片 | 1px hairline、18px 圆角、无阴影 | 毛玻璃、24px 圆角、阴影 |
| 渐变/阴影 | 不使用 | 卡片阴影、按钮阴影、渐变能量条 |
| 侧边栏 | 176px、纯文字 | 256px、图标+文字 |
| 按钮 | pill | 12px 圆角 |

上述差异是用户明确要求去掉 Apple 风格、全面采用 Premium 风格后的结果。
