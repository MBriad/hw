# Agent UI Guide

> **必读**：在修改任何前端 UI 之前，请先阅读本文档。
>
> 本项目（Actrace）的前端采用 **Premium Redesign** 设计语言（参考根目录 `actrace_premium_redesign.html`）。所有 Vue/CSS 改动必须遵循本指南，以保持风格一致。

## 设计规范

完整 UI 设计规范已沉淀到项目知识库：

- [`.agent/architecture/ui-design-system/README.md`](.agent/architecture/ui-design-system/README.md) — 设计系统总览
- [`.agent/architecture/ui-design-system/design-tokens-and-component-patterns.md`](.agent/architecture/ui-design-system/design-tokens-and-component-patterns.md) — 全局 token、组件规范、必遵规则

## 修改流程

1. 打开要修改的 Vue/CSS 文件。

2. 优先使用 `var(--color-*)` / `var(--radius-*)` / `var(--font-*)` token，不要硬编码 hex。

3. 保持 Premium 风格：大圆角卡片、柔和阴影、毛玻璃背景、亮蓝强调色。

4. 修改后运行：

   ```bash
   pnpm build
   pnpm vue-tsc --noEmit
   cargo check
   ```

## 项目知识库

本项目在 `.agent/` 目录下按功能/架构沉淀了可复用的领域知识。开始新任务前，建议先查看索引：

- [`.agent/manifest.yaml`](.agent/manifest.yaml) — 知识库总索引，包含 feature、architecture、devlog 等入口