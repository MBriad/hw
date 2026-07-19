# UI 设计系统

Actrace 前端当前采用 **Premium Redesign** 设计语言。本目录沉淀其完整规范，作为所有 Vue/CSS 改动的唯一依据。

## 设计来源

- 原始视觉参考：项目根目录 `actrace_premium_redesign.html`（Tailwind 风格原型）。
- 当前实现映射：`src/style.css` 中的 CSS 变量体系。

## 核心特征

- **背景**：`#f8fafc`（slate-50）全局浅色画布。
- **卡片**：毛玻璃白（`rgba(255,255,255,0.72)`）+ 半透明边框 + `24px` 大圆角 + 柔和阴影。
- **强调色**：亮蓝 `#3b82f6` / `#2563eb`，用于按钮、active 状态、数值高亮、进度条。
- **辅助渐变**：品牌蓝到靛蓝 `linear-gradient(135deg, #3b82f6, #6366f1)` 用于图标、能量条、进度条。
- **文字**： slate 色阶，标题 `#0f172a`、正文 `#64748b`、次要 `#94a3b8`。
- **导航**：256px 宽侧边栏，图标 + 文字导航项，active 状态为蓝色浅底胶囊。
- **开关**：iOS 风格 44×24 pill，关闭 `slate-200`，开启 `brand-500`。

## 涉及文件

- [`src/style.css`](../../src/style.css) — 全局变量与基础样式
- [`src/App.vue`](../../src/App.vue) — 应用外壳、侧边栏导航
- [`src/views/Dashboard.vue`](../../src/views/Dashboard.vue) — 概览仪表盘
- [`src/views/Plugins.vue`](../../src/views/Plugins.vue) — 插件中心
- [`src/views/Settings.vue`](../../src/views/Settings.vue) — 偏好设置
- [`src/components/ToastCard.vue`](../../src/components/ToastCard.vue) — Toast 通知卡片

## 子文档

- [design-tokens-and-component-patterns.md](design-tokens-and-component-patterns.md) — 完整设计 token、组件规范、必遵规则与参考实现
- [[premium-redesign]] — 从 Apple 风格迁移到 Premium 的改造记录
