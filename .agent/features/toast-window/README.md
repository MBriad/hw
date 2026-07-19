# Toast 窗口

Actrace 右下角通用通知 Toast 窗口，支持标题 + 正文、8 秒自动消失、hover 暂停、多条堆叠与 FLIP 关闭动画。

## 文件涉及

- `src-tauri/src/window_manager/mod.rs` — Tauri 插件入口，注册 `show_window` / `hide_window` / `set_window_active_mode` 命令
- `src-tauri/src/window_manager/shared.rs` — 窗口 label 常量、通用 show/hide 逻辑
- `src-tauri/src/window_manager/windows.rs` — Windows 无焦点显示实现（`WS_EX_NOACTIVATE`）
- `src-tauri/src/window_manager/macos.rs` — macOS 回退实现
- `src-tauri/src/reminder_toast.rs` — Toast 窗口预创建、复用、右下角定位、通知追加
- `src-tauri/src/lib.rs` — 注册模块与命令、setup 预创建窗口、管理 `ReminderWindowStore`
- `src-tauri/Cargo.toml` — Windows 依赖增加 `Win32_Foundation`
- `src-tauri/capabilities/default.json` — Tauri 2 窗口管理权限
- `src/components/ToastCard.vue` — 通用通知卡片组件
- `src/views/ReminderToast.vue` — Toast 窗口容器（通知堆叠、尺寸调整、动画）
- `src/App.vue` — `/reminder-toast` 路由下隐藏 sidebar、切换透明背景
- `src/main.ts` — 注册 `/reminder-toast` 路由
- `src/views/Settings.vue` — 「测试 Toast 通知」按钮

## 子文档

- [porting-from-trace-to-main-project-notes.md](porting-from-trace-to-main-project-notes.md) — 从 trace 子项目移植到主项目时的裁剪与适配点
- [window-no-activate-and-z-order-notes.md](window-no-activate-and-z-order-notes.md) — Windows 无焦点显示与 Z 序控制要点
- [window-height-calculation-and-stack-measurement.md](window-height-calculation-and-stack-measurement.md) — 动态窗口高度计算与堆叠内容测量
