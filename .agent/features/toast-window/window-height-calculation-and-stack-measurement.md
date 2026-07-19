# Toast 窗口高度计算与堆叠测量

`src/views/ReminderToast.vue` 中，前端根据当前通知数量动态调整 Tauri 窗口高度，使 Toast 窗口始终紧贴屏幕右下角并完整显示所有卡片。

## 关键常量

```ts
const CARD_HEIGHT = 128      // 与 ToastCard.vue 的 min-height: 8rem 对应
const CARD_GAP = 8           // gap: 0.5rem
const PADDING = 16           // root padding: 1rem
const WINDOW_WIDTH = 360
```

## 为什么不能用 `scrollHeight` 直接算

`.toast-stack` 原本带有 `max-height: 100%`（即不超过当前窗口高度）。当窗口已经只有 2 条通知高度时，`scrollHeight` 会被这个 `max-height` 限制住，加入第 3 条通知后 `scrollHeight` 仍然只有 2 条的高度，导致 `adjustWindowSize` 算出的窗口高度不会增加，顶部通知被截断。

## 当前实现

1. 移除 `.toast-stack` 的 `max-height: 100%` 与 `overflow-y: auto`，改为 `overflow-y: visible`，让子元素可以自由撑开容器。
2. `adjustWindowSize` 等待一帧 `requestAnimationFrame`，确保新卡片的 `visible` 类已经应用。
3. 直接遍历 `.toast-card-wrapper`，用 `getBoundingClientRect().height` 累加每个卡片的实际渲染高度，再加上 `gap`。
4. 如果 DOM 尚未就绪（测量为 0），回退到 `calcWindowHeight(count)` 的固定估算。

## 窗口位置计算

```ts
const newHeightLogical = Math.min(workAreaHeight, contentHeight + PADDING * 2)
const newXLogical = workAreaX + workAreaWidth - WINDOW_WIDTH
const newYLogical = workAreaY + workAreaHeight - newHeightLogical
```

窗口始终右下角对齐，高度不超过当前工作区高度。

## 注意事项

- `adjustWindowSize` 不再被 `isAnimating` 提前返回阻塞；FLIP 动画期间仍可继续调整尺寸。
- 卡片初始状态有 `transform: translateX(120%) scale(0.96)`，但仍在文档流中占位，因此测量时即使尚未获得 `visible` 类也能得到大致高度；等待一帧后再测量可获得精确的 128px。
- 后端初始窗口高度为 `TOAST_WINDOW_MIN_HEIGHT = 160`（单条通知高度），后续由前端接管调整。
