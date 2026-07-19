# Premium Redesign

Actrace 当前采用的设计风格。主界面从 Apple 极简风格切换为更现代、亮蓝 + 毛玻璃质感的 Premium 风格，参考根目录 `actrace_premium_redesign.html`。原 Apple 设计 token 已完全清理。

## 文件涉及

- [`src/style.css`](../../src/style.css) — slate/brand 色系、毛玻璃、阴影、大圆角 token。
- [`src/App.vue`](../../src/App.vue) — 侧边栏加宽、毛玻璃背景、带图标的导航按钮。
- [`src/views/Dashboard.vue`](../../src/views/Dashboard.vue) — 大圆角毛玻璃卡片、渐变能量条、蓝色遥测数字。
- [`src/views/Plugins.vue`](../../src/views/Plugins.vue) — 插件卡片列表、渐变图标、iOS 风格 toggle、详情面板 footer。
- [`src/views/Settings.vue`](../../src/views/Settings.vue) — 分组卡片、亮蓝主按钮、设置项 hover 高亮。
- [`src/components/ToastCard.vue`](../../src/components/ToastCard.vue) — 毛玻璃卡片、渐变进度条、 slate 文字色。

## 设计规范

完整 Premium Redesign 设计规范见 [[ui-design-system]]：

- [`.agent/architecture/ui-design-system/README.md`](../../architecture/ui-design-system/README.md) — 设计系统总览
- [`.agent/architecture/ui-design-system/design-tokens-and-component-patterns.md`](../../architecture/ui-design-system/design-tokens-and-component-patterns.md) — 完整 token、组件规范与必遵规则

## 子文档

- [files-changed-for-premium-redesign-and-token-mappings.md](files-changed-for-premium-redesign-and-token-mappings.md) — 各文件改动点与 token/颜色映射表
