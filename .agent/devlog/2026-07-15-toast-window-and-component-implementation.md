# 2026-07-15 Toast 窗口与组件实现

## 会话目标

参考 `trace` 子项目，在主项目实现右下角 Toast 通知窗口与对应的 Vue 组件。

## 已完成

- 后端 `window_manager` 模块（Windows 无焦点显示 + macOS 回退）
- 后端 `reminder_toast.rs`（窗口预创建、复用、右下角定位、通知追加）
- `lib.rs` 集成与 `show_toast` / `get_reminder_data` / `close_reminder_window` 命令
- `Cargo.toml` 增加 `Win32_Foundation`
- Tauri 2 权限配置 `capabilities/default.json`
- 前端 `ToastCard.vue` 通用通知卡片
- 前端 `ReminderToast.vue` 窗口容器（堆叠、动画、自动消失、hover 暂停）
- `App.vue` / `main.ts` 路由与透明背景适配
- `Settings.vue` 测试按钮
- 修复 `pnpm tauri dev` 时旧 `actrace.exe` 未退出导致的 `os error 5`

## 关键文件变更

| 文件 | 变更 |
|------|------|
| `src-tauri/src/window_manager/mod.rs` | 新建 Tauri 插件 |
| `src-tauri/src/window_manager/shared.rs` | 窗口常量与通用 show/hide |
| `src-tauri/src/window_manager/windows.rs` | Windows 无焦点实现 |
| `src-tauri/src/window_manager/macos.rs` | macOS 回退 |
| `src-tauri/src/reminder_toast.rs` | Toast 窗口管理 |
| `src-tauri/src/lib.rs` | 注册模块、命令、store |
| `src-tauri/Cargo.toml` | 添加 `Win32_Foundation` |
| `src-tauri/capabilities/default.json` | 窗口权限 |
| `src/components/ToastCard.vue` | 新建通用卡片 |
| `src/views/ReminderToast.vue` | 新建窗口容器 |
| `src/App.vue` | 路由适配与透明背景 |
| `src/main.ts` | 注册路由 |
| `src/views/Settings.vue` | 测试按钮 |

## 验证结果

- `cargo check` ✅
- `pnpm build` ✅
- `pnpm vue-tsc --noEmit` ✅
- `pnpm tauri dev` 可正常启动 ✅

## 剩余/后续

- 休息计时、护眼/喝水专用卡片可按 kind 扩展
- 通知去重策略可按业务需要补充
