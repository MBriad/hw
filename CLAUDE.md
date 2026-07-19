# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

Build tools live at `D:\Devstudio\DevEco Studio\tools\`. The SDK is at `D:\Devstudio\DevEco Studio\sdk\`.

```powershell
$env:DEVECO_SDK_HOME = "D:\Devstudio\DevEco Studio\sdk"
$NODE = "D:\Devstudio\DevEco Studio\tools\node\node.exe"
$HVIGOR = "D:\Devstudio\DevEco Studio\tools\hvigor\bin\hvigorw.js"
$BASE = "--mode module -p module=entry@default -p product=default -p buildMode=debug"

# Build HAP (no signing)
& $NODE $HVIGOR $BASE assembleHap

# Run all unit tests (hypium)
& $NODE $HVIGOR $BASE test

# Stop daemon (to clear caches between builds)
& $NODE $HVIGOR --stop-daemon
```

Target: **HarmonyOS 6.1.1 (API 24)**, stage mode, strict mode enabled. Devices: phone, tablet, 2in1.

Tests use `@ohos/hypium` (1.0.25) and `@ohos/hamock` (1.0.0). They are registered in `entry/src/test/List.test.ets` and run via `hvigorw test`. ArkTS strict mode forbids object literals for interface implementations — mock classes must be **named classes** that implement the interface.

## Architecture

```
entry/src/main/ets/
├── domain/           # Pure entities + interfaces (ZERO @kit.* imports)
│   └── ports/        # Abstract interfaces: CheckInRepository, KeywordMatcher, etc.
├── usecases/         # Business logic orchestration (injects ports via constructor)
├── viewmodels/       # @Observed state holders, injected with usecase interfaces
├── adapters/         # Implement ports using @kit.* (preferences, audio, etc.)
└── pages/            # ArkUI @Components — Humble Views, render ViewModel, emit intents
    └── components/   # Reusable UI: DayCell, SkinSwitcher, ThemeProvider, etc.
```

**Dependency rule**: `pages → viewmodels → usecases → domain/ports` (inward only). `adapters` implement ports. `EntryAbility.ets` is the Composition Root — the only place that creates concrete instances.

**Usecases depend on port interfaces** (e.g., `ILoadHeatmap`, `IRecordCheckIn` from `domain/ports/HeatmapUseCases.ets`), not concrete classes. This enables mock testing at every layer.

## Design System (Actrace Multi-Theme)

Defined in `.agent/architecture/ui-design-system/design-tokens-and-component-patterns.md`. Key rules:

- **`DesignTokens` class** (13 fields: `bgBase`, `bgSurface`, `bgSurfacePressed`, `borderColor`, `textPrimary`, `textSecondary`, `textMuted`, `textPlaceholder`, `brandPrimary`, `brandActive`, `brandLight`, `brandText`, `brandAccent`)
- **4 themes**: `LIGHT` (清爽浅蓝), `DARK` (深海暗夜), `PINK` (魔法少女粉), `PASTEL` (马卡龙幻梦)
- **`@Provide/@Consume`** pattern: the page provides `DesignTokens` via `@Provide`, all children read them via `@Consume tokens: DesignTokens`. Never pass theme via `@Prop` chains.
- **`stateStyles({ pressed: {...} })`** required on every interactive element — no hover, touch-first only.
- **Spacing/Radius constants** from `common/SpacingTokens.ets` and `common/RadiusTokens.ets` — no hardcoded numbers.
- Theme persistence via `@ohos.data.preferences` with key `'theme'`.

## ArkTS Strict Mode Constraints

The project uses strict mode (`useNormalizedOHMUrl: true`). Critical rules:

- **Object literals cannot implement interfaces** — always create a named `class` for mocks.
- **`Object.keys()` on enums** is forbidden — verify enum values individually.
- **`assertNotNull()` does not exist** in hypium — use `expect(x !== null).assertEqual(true)`.
- **`getContext(this)`** is deprecated but functional; use in `aboutToAppear()`, not in field initializers.
- **`@BuilderParam` trailing lambdas** may not work as root nodes in `@Entry` components — prefer `@Provide` directly on the entry page.

## Key Files

| File | Role |
|------|------|
| `entry/src/main/ets/pages/HeatmapPage.ets` | Entry page, `@Provide` tokens, assembles all UI |
| `entry/src/main/ets/viewmodels/HeatmapVM.ets` | Central state: cells, skin, selectedDate, streakInfo |
| `entry/src/main/ets/domain/SkinTheme.ets` | `DesignTokens` class + `ThemePalette` (4 themes) |
| `entry/src/main/ets/domain/ports/` | All abstractions (repo, matcher, calculator, provider) |
| `entry/src/main/ets/adapters/PreferencesCheckInRepo.ets` | JSON persistence via `@ohos.data.preferences` |
| `entry/src/test/mocks/` | Reusable mock classes for tests |
| `target.md` | Product design document |
| `.agent/architecture/ui-design-system/` | Design system reference |
| `skill/clean-arch-app/SKILL.md` | Clean Architecture patterns for ArkTS/Rust |
| `skill/karpathy-guidelines/SKILL.md` | Coding discipline guidelines |
