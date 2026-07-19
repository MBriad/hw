# 2026-07-15 参考 actrace_premium_redesign.html 改造主界面样式

## Session goal

参考根目录 `actrace_premium_redesign.html` 的现代毛玻璃/卡片风格，仅通过修改 UI 样式刷新 Actrace 主界面，不新增/删除组件。

## Completed

- 扩展全局 token：新增 slate/brand 色系、毛玻璃、阴影、大圆角 token，保留原有 Apple token。
- 改造 `src/App.vue`：侧边栏加宽至 256px、毛玻璃背景、Logo + 副标题、带图标的导航按钮。
- 改造 `src/views/Dashboard.vue`：毛玻璃大圆角卡片、渐变能量条、蓝色遥测数字、更新热力图配色。
- 改造 `src/views/Plugins.vue`：卡片式插件列表、渐变图标、iOS 风格 toggle、详情面板 footer。
- 改造 `src/views/Settings.vue`：分组卡片、亮蓝主按钮、设置项 hover 高亮。
- 通过验证：`pnpm vue-tsc --noEmit`、`pnpm build`、`cd src-tauri && cargo check`。

## Remaining

- 无。后续如需要深色模式支持，可在现有 token 基础上扩展 `dark` 主题。

## Key file changes

| File | Change |
|---|---|
| `src/style.css` | 追加 Premium token（slate/brand/glass/shadow/radius） |
| `src/App.vue` | 侧边栏加宽、毛玻璃、图标导航、品牌区改造 |
| `src/views/Dashboard.vue` | 卡片/标题/能量条/donut/遥测/热力图换肤 |
| `src/views/Plugins.vue` | 列表卡片、渐变图标、iOS toggle、详情 footer |
| `src/views/Settings.vue` | 分组卡片、亮蓝按钮、设置项样式 |
