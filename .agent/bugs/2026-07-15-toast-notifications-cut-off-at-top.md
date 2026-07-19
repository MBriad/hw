# 2026-07-15 Toast 通知顶部显示不完全

## 现象

多条 Toast 堆叠时，顶部的通知被截断，只能看到下方部分卡片。窗口高度没有随通知数量增加而扩展。

## 复现

在 Settings 页连续点击「测试 Toast 通知」3 次以上，即可看到顶部卡片被截断。

## 根因

`src/views/ReminderToast.vue` 中的 `.toast-stack` 设置了 `max-height: 100%`，导致 `stackRef.value.scrollHeight` 被限制在当前窗口高度内。`adjustWindowSize` 依赖 `scrollHeight` 计算新窗口高度，因此新通知加入后窗口高度不会增加。

## 修复

- 移除 `.toast-stack` 的 `max-height: 100%`，改为 `overflow-y: visible`。
- `adjustWindowSize` 改为直接测量每个 `.toast-card-wrapper` 的 `getBoundingClientRect().height` 来累加内容高度。
- 等待一帧 `requestAnimationFrame` 确保卡片 `visible` 状态应用后再测量。

## 涉及文件

- `src/views/ReminderToast.vue`
