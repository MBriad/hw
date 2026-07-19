# Windows 无焦点显示与 Z 序控制

## 目标

Toast 窗口需要：
1. 显示时不抢夺当前输入焦点
2. 始终可见在内容之上
3. 不推高 Z 序导致全屏独占应用（如游戏）被切出全屏

## 实现

- Tauri builder 设置 `always_on_top(true)`，使窗口位于 `WS_EX_TOPMOST` 层
- 显示时设置 `WS_EX_NOACTIVATE` 扩展样式
- 使用 `ShowWindow(hwnd, SW_SHOWNOACTIVATE)` 显示
- `SetWindowPos` 必须带 `SWP_NOZORDER`，避免 `HWND_TOPMOST` 重新推高 Z 序

## 关键代码

```rust
fn apply_no_activate_style(hwnd: HWND) {
    unsafe {
        let style = GetWindowLongPtrW(hwnd, GWL_EXSTYLE);
        let new_style = style | WS_EX_NOACTIVATE.0 as isize;
        let _ = SetWindowLongPtrW(hwnd, GWL_EXSTYLE, new_style);
        let _ = SetWindowPos(
            hwnd,
            None,
            0, 0, 0, 0,
            SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED,
        );
    }
}
```

## 窗口复用

- Toast 窗口在 `setup` 阶段预创建，初始 `visible(false)`
- 关闭时调用 `hide_window_internal` 隐藏，不销毁
- 下次通知到达时复用已有窗口，避免创建窗口时的焦点抖动

## 并发安全

- 使用全局 `tokio::sync::Mutex` 串行化所有窗口创建/显示/追加操作
- 防止快速连续触发时并发操作 `WebviewWindow` 导致崩溃
