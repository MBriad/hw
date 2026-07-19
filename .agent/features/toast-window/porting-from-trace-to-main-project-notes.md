# 从 trace 移植 Toast 窗口到主项目的裁剪与适配

## 参考来源

- `trace/src/window_manager/` — 窗口管理后端
- `trace/src/reminder_toast.rs` — Toast 后端逻辑
- `trace/ui-src/views/ReminderToast.vue` — Toast 前端容器
- `trace/ui-src/components/EyeToastCard.vue` — 专用卡片示例

## 主项目现状差异

- 无 `vue-i18n`，卡片文本由调用方传入或硬编码中文
- 无 `naive-ui`，全部使用原生 Vue / CSS
- 已有 Apple 设计 token（`AGENTS.md`），卡片不使用 box-shadow
- Tauri 2 权限使用 `capabilities/default.json` 而非 trace 中的空配置

## 裁剪内容

| trace 功能 | 主项目处理 |
|---|---|
| 休息计时（rest-timer） | 未实现 |
| 护眼专用卡片（EyeToastCard） | 未实现 |
| 喝水提醒卡片 | 未实现 |
| 更新通知卡片（update） | 未实现 |
| i18n 多语言 | 未引入 |
| naive-ui 组件 | 未引入 |
| 通知去重 | 通用通知暂不去重 |

## 保留扩展性

- `ReminderWindowData.kind` 字段保留，后续可按 kind 渲染不同卡片
- `ToastCard.vue` 目前只处理通用通知，但 props 结构可扩展
- `ReminderToast.vue` 的 `addToastNotification` 接口与 trace 一致，Rust 端可直接复用

## 新增内容

- `ToastCard.vue` 通用卡片组件（trace 中无单独通用卡片）
- `src-tauri/capabilities/default.json` 显式声明窗口权限
- `Settings.vue` 测试按钮
