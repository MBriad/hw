---
name: clean-arch-app
description: Clean Architecture design principles for OpenHarmony / HarmonyOS application development. Use when designing, reviewing, or refactoring ArkTS/ArkUI/Rust code to enforce SOLID principles, dependency rules, and testable architecture.
license: MIT
---

# Clean Architecture — OpenHarmony / HarmonyOS

Design rules for maintainable application code. Based on Robert C. Martin's Clean Architecture, adapted for ArkTS, ArkUI, and Rust (NAPI native modules).

Tradeoff: Full Clean Architecture adds overhead to simple CRUD. Apply strictly to core business logic; relax for trivial scaffolding. Use judgment.

## 1. Dependency Always Points Inward

Source code dependencies must only point toward higher-level policy. Inner layers never import outer layers.

```
pages/ → viewmodels/ → usecases/ → domain/
  │          │             │
  └──────────┴─────────────┴──→ ports/  (interfaces defined here)
                                     ↑
adapters/ ───────────────────────────┘  (implement ports)
       ↑
napi/rust/  (NAPI Rust native modules — implement performance-critical adapters)
```

Before importing, ask:
* Does `domain/` import anything from `@ohos.*` or `@kit.*`? If yes, fix it.
* Does `usecases/` import any adapter? If yes, fix it.
* Does `EntryAbility.ets` do all wiring? It's the only place that may import everything.
* Does any ArkUI `@Component` import a usecase directly? Components depend on ViewModels, not usecases.

## 2. SOLID at Class and Component Level

**SRP**: One reason to change per module.
* An `@Component` fetching user data must not also manage WebSocket notifications.
* A ViewModel orchestrating cart logic must not also format display strings — that's a Presenter's job.
* Split when you see more than one `aboutToAppear()` concern in the same component.
* A Rust NAPI module doing file I/O must not also parse business entities — split the crate.

**OCP**: Add behavior by adding code, not editing existing code.
* Replace `if (type === 'info') { ... } else if (type === 'warning') { ... }` chains with a `Map<string, TypeHandler>` strategy registry.
* Replace switch/if-else inside a service with the Strategy pattern — inject the strategy via constructor.
* New notification type = new handler file, not a new branch in an existing handler.
* In ArkUI: prefer `@Builder` function maps over `if/else` chains for variant rendering.

**LSP**: Subtypes must be fully substitutable.
* If `BaseButton` disables with `enabled: boolean = true`, then `SubmitButton` must respect it too.
* A component accepting `@Prop modelValue: string` must emit `string`, never `null` or `undefined`.
* A Rust trait implementation must honor the trait contract — no panics where the trait says `Result`.
* Narrow interfaces prevent LSP violations: define what you need, nothing more.

**ISP**: Don't force clients to depend on methods they don't use.
* A ViewModel exposing 20+ properties signals a fat interface — split it.
* `class UserStore` that returns user, cart, orders, notifications = ISP violation.
* Split into `UserViewModel`, `CartViewModel`, `OrderViewModel`.
* In Rust: a `trait Storage` with 15 methods should be split into `trait Reader`, `trait Writer`, `trait Deleter`.

**DIP**: Depend on abstractions, not concretions.
* A component calling `import { http } from '@kit.NetworkKit'` directly = DIP violation. Inject a service interface.
* Define `interface UserService` in the usecase layer. Implement in the adapter layer with `@kit.NetworkKit`.
* Define `trait Database` in domain. Implement in `napi/rust/` with a Rust NAPI module.
* Mock the interface in `@ohos/hamock`-based tests — no real HTTP or database calls.

## 3. Humble Object Pattern

Separate hard-to-test code from easy-to-test code.
* **Logic** (validation, computation, state transitions): pure functions or ViewModels, unit-tested with `@ohos/hypium`.
* **View** (ArkUI `@Component`): receive ViewModel, render it. No conditionals beyond `if`/`else` for display.
* **Rust native logic** (algorithms, parsing, crypto): pure `no_std`-compatible functions, tested with `cargo test`.
* Test the Presenter/ViewModel, not the UI. `loanVM.statusLevel === LoanLevel.DANGER` requires no ArkUI render.
* Rust unit tests verify business rules without NAPI overhead — call `cargo test` in the native crate.

## 4. Crossing Boundaries

Data crossing a layer boundary must be transformed.
* NAPI/HTTP response → Controller → RequestDTO → UseCase
* UseCase → ResponseDTO → Presenter → ViewModel → ArkUI `@Component`
* Never pass framework objects (`http.HttpResponse`, NAPI `napi_value`, `relationalStore.ResultSet`) into a usecase.
* DTOs are plain `interface` / `class` (ArkTS) or `struct` (Rust). No behavior. No `@kit.*` imports. No `napi` derives.
* Rust ↔ ArkTS boundary: use `napi-ohos` to expose Rust structs as NAPI objects. Transform NAPI DTOs to domain structs at the boundary.

```
Rust NAPI Module (adapter)          ArkTS Adapter              UseCase (ArkTS)
─────────────────────────          ─────────────              ────────────────
napi_ohos::Value  ──→  transform  ──→  RequestDTO (plain)  ──→  execute(dto)
                   ←──             ←──  ResponseDTO (plain) ←──
```

## 5. Composition Root

One place wires everything. No hidden dependencies.
* `EntryAbility.ets` / `DIContainer.ets` creates all concrete instances and injects them.
* No `new HttpClient()` buried inside a ViewModel or `@Component`.
* No service locator pattern hiding dependencies. Constructor injection is explicit.
* Rust NAPI modules are loaded once in the Composition Root via `import nativeModule from 'libnative.so'`, then injected.
* Use `@Provide` / `@Consume` only for framework-level state (theme, locale) — never for business dependencies.

```typescript
// EntryAbility.ets — Composition Root
import { UserServiceImpl } from './adapters/UserServiceImpl';
import { GetUserUseCase } from './usecases/GetUserUseCase';
import { UserViewModel } from './viewmodels/UserViewModel';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    // Wire everything here — the only place that knows about concretions
    const userService = new UserServiceImpl(this.context);
    const getUserUseCase = new GetUserUseCase(userService);
    const userVM = new UserViewModel(getUserUseCase);
    // Pass ViewModel down; no component creates its own dependencies
  }
}
```

## 6. ArkUI Component Design

**Component = Humble View**: Render ViewModel, emit intents. No business logic.

```typescript
// GOOD — component receives ViewModel, renders it, emits user intents
@Component
export struct UserProfile {
  @Prop viewModel: UserProfileVM;  // ViewModel, not usecase or service
  onRefresh?: () => void;          // Intent callback — component doesn't know what happens

  build() {
    Column() {
      Text(this.viewModel.displayName)
        .fontSize(24)
      Button('Refresh')
        .onClick(() => this.onRefresh?.())  // Emit intent, don't orchestrate
    }
  }
}
```

**Anti-patterns**:
* `@Component` calling `http.createHttp()` directly — DIP violation.
* `@Component` containing `if (balance < 0) { router.pushUrl(...) }` — business logic in view.
* `@Component` with `@State` holding raw API response data — no transformation at boundary.
* `aboutToAppear()` with 50 lines of data fetching, parsing, and state mutation — SRP violation.

## 7. State Management in Clean Architecture

ArkUI state decorators map to Clean Architecture layers:

| Decorator | Clean Arch Layer | Usage |
|-----------|-----------------|-------|
| `@State` | ViewModel (component-owned) | Local UI state derived from ViewModel |
| `@Prop` | View (parent→child) | ViewModel data passed down to child components |
| `@Link` | View (two-way) | Bound to a ViewModel property for form inputs |
| `@Provide`/`@Consume` | Composition Root only | Theme, locale, DI container — NOT business state |
| `@StorageLink`/`@StorageProp` | Cross-ability state | App-wide preferences, not domain state |
| `@Observed`/`@ObjectLink` | ViewModel | Observed ViewModel class with nested reactivity |

```typescript
// GOOD — ViewModel is the source of truth
@Observed
class TaskListVM {
  tasks: TaskItem[] = [];
  isLoading: boolean = false;
  errorMessage: string = '';

  constructor(private loadTasks: LoadTasksUseCase) {}

  async refresh(): Promise<void> {
    this.isLoading = true;
    try {
      this.tasks = await this.loadTasks.execute();
    } catch (e) {
      this.errorMessage = 'Failed to load';
    } finally {
      this.isLoading = false;
    }
  }
}

@Component
struct TaskListPage {
  @ObjectLink vm: TaskListVM;  // Reacts to nested changes

  aboutToAppear(): void {
    this.vm.refresh();  // One-liner — logic lives in ViewModel
  }
}
```

## 8. Rust NAPI Modules in Clean Architecture

Rust NAPI modules are adapters — they sit at the outer layer implementing ports defined by the domain.

```
                      ports/
                    ┌───────────┐
                    │ trait     │  ← Defined in domain (pure, no framework)
                    │ Storage   │
                    └─────┬─────┘
                          │ implements
              ┌───────────┼───────────┐
              │           │           │
        adapters/    adapters/    adapters/
      sqlite.ets    napi/rust/   napi/rust/
                    libcrypto.so libstorage.so
```

**Rust crate structure** (inside a HarmonyOS project):

```
entry/src/main/
├── ets/                    # ArkTS source
│   ├── domain/
│   ├── usecases/
│   ├── adapters/
│   └── viewmodels/
└── cpp/                    # Native source (C++ wrapper + Rust via NAPI)
    └── rust/
        ├── Cargo.toml
        └── src/
            ├── lib.rs       # NAPI entry points
            ├── domain.rs    # Pure domain logic (no NAPI)
            ├── adapters.rs  # NAPI-aware implementations of traits
            └── ports.rs     # Trait definitions (can be shared with ArkTS conceptually)
```

**Rust adapter pattern**:

```rust
// ports.rs — pure, no NAPI dependency
pub trait CryptoProvider {
    fn hash(&self, input: &[u8]) -> Result<Vec<u8>, CryptoError>;
    fn verify(&self, input: &[u8], hash: &[u8]) -> Result<bool, CryptoError>;
}

// adapters.rs — NAPI-aware implementation
use napi_ohos::{Error, Status, Result};

pub struct NapiCryptoProvider;

impl CryptoProvider for NapiCryptoProvider {
    fn hash(&self, input: &[u8]) -> Result<Vec<u8>, CryptoError> {
        // Pure computation — testable without NAPI
        Ok(sha256::digest(input).as_bytes().to_vec())
    }
}

// lib.rs — NAPI boundary (thin wrapper)
#[napi]
fn hash_password(input: String) -> napi::Result<String> {
    let provider = NapiCryptoProvider;
    let hash = provider.hash(input.as_bytes())
        .map_err(|e| napi::Error::from_reason(e.to_string()))?;
    Ok(hex::encode(hash))
}
```

## 9. Testing Strategy

| Layer | Framework | What to test | Mock strategy |
|-------|-----------|-------------|---------------|
| Domain entities | `@ohos/hypium` | Pure logic, validation rules | No mocks needed — pure functions |
| Use Cases | `@ohos/hypium` | Orchestration, error paths | Mock port interfaces via constructor injection |
| ViewModels | `@ohos/hypium` | State transitions, formatting | Mock usecases |
| ArkUI Components | `@ohos/uitest` | Interaction, rendering | Provide stub ViewModels |
| Rust domain | `cargo test` | Business rules, algorithms | No mocks — pure functions |
| Rust adapters | `cargo test` | Transform logic, error mapping | Mock trait implementations |
| Rust NAPI boundary | Integration test via ArkTS | End-to-end data flow | Real NAPI module loaded in test runner |

```typescript
// Testing a UseCase with mocked port
import { describe, it, expect } from '@ohos/hypium';

describe('GetUserUseCase', () => {
  it('returns user DTO on success', async () => {
    // Arrange — inject mock that implements UserService interface
    const mockService: UserService = {
      fetchUser: async (id: string) => ({ id, name: 'Test', email: 'test@test.com' })
    };
    const usecase = new GetUserUseCase(mockService);

    // Act
    const result = await usecase.execute('123');

    // Assert
    expect(result.name).assertEqual('Test');
  });
});
```

## Quick Decision Table

| Signal | Rule Violated | Fix |
|--------|--------------|-----|
| `@Component` > 300 lines | SRP | Split into ViewModel + sub-components |
| `if/else` chain on type field in `build()` | OCP | Dynamic `@Builder` + registry map |
| Child ignores parent's `enabled` prop | LSP | Respect prop contract or split interface |
| ViewModel exposes > 10 properties | ISP | Split into focused ViewModels |
| `import { http } from '@kit.NetworkKit'` in component | DIP | Inject service interface via constructor |
| `domain/` imports `@ohos.*` or `@kit.*` | Dependency Rule | Remove framework import — domain is pure ArkTS |
| Business logic in `build()` / `aboutToAppear()` | Humble Object | Move to ViewModel or pure function |
| `@State` holding raw `http.HttpResponse` data | Crossing Boundaries | Transform to DTO at adapter boundary |
| `new SomeService()` inside `@Component` | Composition Root | Constructor-inject via ViewModel |
| Rust `unsafe` block in domain logic | SRP / Safety | Push `unsafe` to the NAPI adapter layer |
| NAPI module calls `hilog` directly | Dependency Rule | Return `Result`; let ArkTS adapter log |

## Example Index

| Concept | ArkTS / ArkUI | Rust NAPI |
|---------|--------------|-----------|
| SRP | `concepts/01-srp/` (pattern: split ViewModel + Presenter) | `concepts/01-srp/rust/` (pattern: one reason to change per module) |
| OCP | `concepts/02-ocp/` (pattern: `@Builder` registry vs if/else chain) | `concepts/02-ocp/rust/` (pattern: trait strategy vs match) |
| LSP | `concepts/03-lsp/` (pattern: component contract, `@Prop` type safety) | `concepts/03-lsp/rust/` (pattern: trait contract, no panic in impl) |
| ISP | `concepts/04-isp/` (pattern: narrow ViewModels over fat stores) | `concepts/04-isp/rust/` (pattern: narrow traits over fat interfaces) |
| DIP | `concepts/05-dip/` (pattern: inject service interface, mock in tests) | `concepts/05-dip/rust/` (pattern: inject `dyn Trait`, mock in `#[cfg(test)]`) |
| Entities | `concepts/07-entities/` (pattern: pure `interface`/`class`, zero framework dep) | `concepts/07-entities/rust/` (pattern: pure struct/enum, `no_std` compatible) |
| Use Cases | `concepts/08-use-cases/` (pattern: DTO in → DTO out, async) | — |
| Adapters | `concepts/09-adapters/` (pattern: implement port, translate data, `@kit.*` only here) | `concepts/09-adapters/rust/` (pattern: impl trait, NAPI only at crate boundary) |
| Dependency Rule | `concepts/10-dependency-rule/` (pattern: module imports → inward only) | `concepts/10-dependency-rule/rust/` (pattern: crate deps → inward only) |
| Humble Object | `concepts/11-humble-object/` (pattern: `@Component` = thin view, ViewModel = testable logic) | `concepts/11-humble-object/rust/` (pattern: pure fn logic, thin NAPI I/O) |
| Crossing Boundaries | `concepts/12-crossing-boundaries/` (pattern: DTO at each boundary, transform at adapter) | `concepts/12-crossing-boundaries/rust/` (pattern: NAPI DTO ↔ domain struct) |
| Composition Root | `concepts/14-composition-root/` (pattern: `EntryAbility.ets` wires all) | — |
| State Management | `concepts/15-state-management/` (pattern: `@Observed` VM → `@ObjectLink` component) | — |

> Each concept directory may contain Python examples for illustration. The architectural pattern is language-agnostic — apply the same structure with ArkTS interfaces and constructor injection, Rust traits and `dyn Trait` for DI, `#[cfg(test)]` for mocks, NAPI modules for native adapters, and HarmonyOS `@ohos/hypium` for testing. The key insight: **domain logic is pure ArkTS or pure Rust — no framework imports, no NAPI, no `@kit.*` — and therefore fully testable in isolation.**
