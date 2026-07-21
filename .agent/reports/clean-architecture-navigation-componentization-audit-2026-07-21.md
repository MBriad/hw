# Actrace Clean Architecture 与导航内容组件化审查报告

- 审查日期：2026-07-21
- 审查依据：`skill/clean-arch-app/SKILL.md`、仓库根目录 `AGENTS.md`
- 审查范围：`entry/src/main/ets`，重点检查导航区域切换后的内容区域是否为独立组件
- 审查方式：静态源码审查；本次仅输出文档，未修改业务代码，未执行构建或设备交互测试

## 1. 结论摘要

当前工程的 Clean Architecture 基础结构总体清晰，但导航内容区域只完成了“控件级组件化”，尚未完成“页面 Section 级组件化”。

核心结论：

1. `HorizontalNavigation` 已是独立 `@Component`，能够通过 `@Prop active` 接收状态、通过 `onNavigate` 发出导航意图，符合 Humble View 和单向数据流原则。
2. 导航切换后的四个内容区域 `CALENDAR / LOGS / PATTERNS / PROFILE` 均仍以内联 `@Builder` 形式存在于 598 行的 `HeatmapPage.ets` 中，不是可独立复用、测试和演进的页面组件。
3. `HeatmapPage` 同时承担主题持久化、页面骨架、导航状态、四个 Section 渲染、签到入口和特效叠层，明显违反 SRP。
4. 页面层直接使用 `@kit.ArkData` 读写主题，绕过已有 `SkinProvider` port，违反 DIP；相同逻辑还与未使用的 `ThemeProvider.ets` 重复。
5. `HeatmapVM` 集中服务四个导航 Section、主题、签到、统计和彩蛋效果，存在明显的 ISP/SRP 压力，但建议先拆 Section，再按稳定边界拆 ViewModel。

综合判定：

| 检查项 | 结论 |
|---|---|
| 分层目录 | 基本合规 |
| 依赖方向 | 主链路基本合规，页面主题持久化例外 |
| Composition Root | 基本合规 |
| 导航组件 | 合规 |
| 导航内容 Section 组件化 | 不合规 |
| Humble View | 部分合规 |
| 可独立测试性 | Section 层不足 |
| 总体评级 | B-：架构基础良好，但页面展示层需要拆分 |

## 2. 导航区域与内容区域组件化判定

### 2.1 判定标准

一个导航内容区域要被认定为“已组件化”，至少应满足：

- 是独立文件中的 `@Component`，而非父页面内部的 `@Builder`。
- 通过窄 `@Prop`、`@ObjectLink` 或专用 ViewModel 接收所需数据。
- 通过回调发出用户意图，不直接创建 usecase、adapter 或框架服务。
- 可以使用 stub 数据单独进行 ArkUI 渲染和交互测试。
- 父页面只负责页面骨架、导航状态和内容分发。

### 2.2 当前组件化矩阵

| 区域 | 当前实现 | 独立 `@Component` | 判定 | 证据 |
|---|---|---:|---|---|
| 导航栏 | `HorizontalNavigation` | 是 | 合规 | `pages/components/HorizontalNavigation.ets:8-65` |
| CALENDAR | `HeatmapPage.dataPage()` | 否 | 部分组件化 | `HeatmapPage.ets:111-196` |
| LOGS | `HeatmapPage.logsPage()` | 否 | 未组件化 | `HeatmapPage.ets:198-275` |
| PATTERNS | `HeatmapPage.corePage()` | 否 | 未组件化 | `HeatmapPage.ets:277-380` |
| PROFILE | `HeatmapPage.userPage()` | 否 | 未组件化 | `HeatmapPage.ets:382-480` |
| Section 分发 | `HeatmapPage.activePage()` | 否 | 与父页面耦合 | `HeatmapPage.ets:482-493` |
| 内容宿主 | `HeatmapPage.build()` | 否 | 职责过重 | `HeatmapPage.ets:495-564` |

CALENDAR 内部已经使用 `HeatmapGrid`、`DayCell`、`CheckInInput` 等组件，因此属于“控件级组件化”；但整个 CALENDAR Section 仍不是独立组件。其余三个 Section 的主体布局全部直接写在 `HeatmapPage` 中。

最终回答：导航区域切换到其他页面后，内容区域没有完成页面级组件化。

## 3. 已合规部分

### 3.1 导航组件符合 Humble View

`HorizontalNavigation.ets` 的职责较单一：

- `@Prop active: AppSection` 接收当前状态。
- `onNavigate?: (section: AppSection) => void` 发出用户意图。
- 使用 `@Consume tokens` 获取主题。
- 所有 Tab 具备 `stateStyles({ pressed: ... })` 按压反馈。
- 不访问 ViewModel、usecase、adapter 或框架存储。

因此导航控件本身符合组件化和 Humble View 原则。

### 3.2 主要依赖方向正确

静态检查未发现：

- `domain/` 导入 `@kit.*` 或 `@ohos.*` 模块。
- `usecases/` 导入 adapter 或框架模块。
- ViewModel 导入具体 adapter。
- ArkUI 组件直接创建 usecase 或 adapter。

主要依赖链保持为：

```text
pages -> viewmodels -> usecases/interfaces -> domain/ports
                                          <- adapters implement ports
```

### 3.3 Composition Root 基本集中

`EntryAbility.ets:31-45` 创建：

- `PreferencesCheckInRepo`
- `FrequencyPatternEngine`
- `LoadHeatmap`
- `RecordCheckIn`
- `LoadActivity`
- `DetectEasterEgg`
- `SkinProviderImpl`
- `SoundPlayerImpl`
- `HeatmapVM`

具体实现的装配集中在 `EntryAbility`，符合 Composition Root 的方向。

## 4. 主要问题

### P1：四个导航内容 Section 未独立组件化

证据：

- `dataPage()`：`HeatmapPage.ets:111-196`
- `logsPage()`：`HeatmapPage.ets:198-275`
- `corePage()`：`HeatmapPage.ets:277-380`
- `userPage()`：`HeatmapPage.ets:382-480`

影响：

- `HeatmapPage.ets` 达到 598 行，超过 skill 中 `@Component > 300 lines` 的 SRP 风险信号。
- 任一 Section 的布局变化都会修改入口页面。
- 无法针对单个 Section 注入 stub 数据进行独立 UI 测试。
- 四个 Section 直接读取同一个大 ViewModel，页面边界不清晰。
- 新增导航页需要同时修改枚举、导航栏、标题映射和内容分发。

建议目标：

```text
pages/
├── HeatmapPage.ets              # 页面壳、导航状态、全局叠层
├── navigation/
│   ├── NavigationSpec.ets       # Tab 元数据
│   └── SectionHost.ets          # 唯一内容分发点
└── sections/
    ├── CalendarSection.ets
    ├── LogsSection.ets
    ├── PatternsSection.ets
    └── ProfileSection.ets
```

第一阶段只搬迁现有 Builder 内容，不改变业务行为，也暂不拆 ViewModel，以降低风险。

### P1：页面层直接执行主题持久化

证据：

- `HeatmapPage.ets:2` 直接导入 `@kit.ArkData`。
- `HeatmapPage.ets:566-597` 直接调用 preferences。
- `ThemeProvider.ets:32-64` 存在几乎相同的持久化逻辑。
- `SkinProviderImpl.ets` 当前只提供主题令牌，没有承担持久化。

这使 ArkUI 页面同时承担存储 adapter 的职责，违反 DIP 和 Humble View。

建议：

- 在 `SkinProvider` 或单独的 `ThemePreferencePort` 中定义加载、保存主题的方法。
- 在 adapters 层使用 `@kit.ArkData` 实现。
- ViewModel 调用 port，页面只发出“切换主题”意图并渲染状态。
- `ThemeProvider` 与 `HeatmapPage` 的主题根职责只保留一套实现。

### P2：HeatmapVM 职责集中

`HeatmapVM.ets` 同时管理：

- 月历格子和选中日期。
- 签到写入和月历刷新。
- 活动日志。
- 使用模式统计。
- 主题令牌。
- 彩蛋、粒子、横幅和音效。
- 多项页面展示格式与统计 getter。

它还注入六个依赖：两个热力图 usecase、两个活动 usecase、主题 provider 和声音 provider。

这不是立即必须重写的问题，但四个 Section 全部直接依赖该 ViewModel，使接口隔离不足。建议在 Section 拆分稳定后，再按实际消费者拆为：

- `CalendarVM`
- `ActivityVM`
- `ProfileVM`
- 页面级 `EffectsVM` 或保留精简后的 `HeatmapVM`

不要在拆 Section 的同一次变更中同步大拆 ViewModel，以免扩大回归面。

### P2：导航元数据和内容分发存在多处重复

当前新增一个 Section 至少需要修改：

1. `domain/AppSection.ets`
2. `HorizontalNavigation.ets:52-55`
3. `HeatmapPage.sectionLabel():46-57`
4. `HeatmapPage.activePage():482-493`
5. 新增页面 Builder

同一导航概念分散在多个文件和条件链中，违反 OCP，且容易出现“Tab 已出现但标题或内容未注册”的漂移。

建议建立单一导航规格：

```text
AppSection -> tabLabel -> statusLabel -> section renderer/host registration
```

考虑 ArkUI/ArkTS 严格模式限制，可使用专用 `SectionHost` 作为唯一显式分发点，不必强行使用复杂的动态 Builder Map；重点是把分支集中到一个位置。

### P2：通过 AppStorage 隐式获取业务 ViewModel

证据：

- `EntryAbility.ets:43` 将 `HeatmapVM` 写入 `AppStorage`。
- `HeatmapPage.ets:26` 使用 `@StorageLink('heatmapVM')` 获取业务 ViewModel。

优点是装配仍由 EntryAbility 完成；问题是页面依赖没有通过组件接口显式表达，AppStorage 在这里具有 service locator 的特征。按照 skill 的状态映射，`@StorageLink` 更适合跨 Ability 偏好或全局 UI 状态，而不是完整业务依赖图。

建议把它列为中期改进项：在 ArkUI 入口限制下，可保留一个明确命名的应用级容器，但应避免更多业务服务继续注册到 AppStorage；Section 组件应通过窄 props 或专用 ViewModel 显式接收依赖。

### P2：展示层概念放入 domain

`AppSection` 是导航展示状态，不是业务领域实体，却位于 `domain/AppSection.ets`。`SkinTheme.ets` 中的 `DesignTokens` 还直接使用 ArkUI 的 `ResourceColor` 类型。虽然 domain 没有显式导入 `@kit.*`，但语义上已经包含展示层模型。

建议：

- 将 `AppSection` 移至 `pages/navigation` 或 presentation/viewmodel 层。
- 将 `DesignTokens`、`ThemePalette` 移至 `common/theme` 或 presentation 层。
- domain 仅保留签到、连续记录、模式识别等业务概念。

这是语义纯度问题，优先级低于 Section 拆分和持久化边界修复。

### P3：存在未接入的重复组件

静态引用检查结果：

- `HeatmapContent.ets` 没有被其他源码引用。
- `ThemeProvider.ets` 没有被当前入口页面使用。
- `EntryAbility` 实际加载的是 `pages/HeatmapPage`。

`HeatmapContent` 只覆盖旧版月历内容，不包含当前四 Section 导航结构；`ThemeProvider` 与 `HeatmapPage` 又重复处理主题。因此二者目前是孤立代码，会增加维护者误判成本。

建议在 Section 重构后明确处理：复用、重构或删除，不要继续并存。

### P3：部分展示计算仍留在组件内部

示例：

- `HeatmapGrid.ets:74-88` 在组件内解析日期并计算日历偏移。
- `CheckInInput.ets:82-91` 在组件内格式化日期并判断提交条件。
- `HeatmapPage.ets:258` 在日志渲染时生成序号文本。

简单本地 UI 状态可以留在组件中，但可复用、需要边界测试的日期/格式计算应优先放入 Presenter/ViewModel 或纯函数，以保持 Humble View。

## 5. 测试缺口

现有单元测试覆盖了部分 ViewModel 和 usecase，但未发现以下测试：

- `AppSection` 与导航项完整性测试。
- `HorizontalNavigation` 点击后 active 状态变化测试。
- 四个 Section 的独立渲染测试。
- Section 切换后内容正确、输入区域状态保持或重置策略测试。
- 主题切换后四个 Section 的显示一致性测试。

若后续实施组件拆分，应按仓库要求完成：

1. `assembleHap`
2. 相关 hypium 单元测试
3. 在 6.8 英寸手机模拟器或真机逐一点击四个导航项
4. 在四套主题下检查每个 Section
5. 验证重复点击、切换返回、输入状态、滚动位置和按压反馈
6. 保存截图和设备日志作为验收证据

## 6. 推荐重构顺序

| 顺序 | 工作 | 目的 | 风险 |
|---:|---|---|---|
| 1 | 提取 `LogsSection`、`PatternsSection`、`ProfileSection`、`CalendarSection` | 修复最主要 SRP/组件化问题 | 低 |
| 2 | 新增 `SectionHost`，集中内容分发和导航标签规格 | 降低 OCP 漂移风险 | 低至中 |
| 3 | 将主题持久化移入 adapter/port | 修复 DIP，清除重复逻辑 | 中 |
| 4 | 清理或整合 `HeatmapContent`、`ThemeProvider` | 减少孤立代码 | 低 |
| 5 | 根据 Section 消费边界拆分 ViewModel | 改善 ISP、测试性 | 中至高 |
| 6 | 补齐组件 UI 测试和设备验收 | 验证可见行为 | 中 |

## 7. 建议的完成标准

重构完成后应满足：

- `HeatmapPage` 只负责主题提供、页面框架、导航状态、SectionHost 和全局特效。
- 四个导航内容区域各自是独立 `@Component` 文件。
- Section 只接收自身需要的数据和 intent 回调。
- 页面和组件不直接导入 `@kit.ArkData`。
- 导航项、状态标题和 Section 分发只在一个明确的注册位置维护。
- `HeatmapContent`、`ThemeProvider` 不再处于未引用且职责重复的状态。
- 每个 Section 可使用 stub 数据独立渲染和交互测试。
- 构建、单元测试、四主题设备交互验收均通过。

## 8. 最终判定

项目已经正确建立了 domain、ports、usecases、adapters、viewmodels 和 pages 的主要目录结构，Composition Root 也基本集中；导航控件和多个底层 UI 控件具备良好的组件化基础。

但从用户关注的“导航区域切换到其他页面后，内容区域是否组件化”这一点看，答案是否定的：四个内容 Section 仍全部内联在 `HeatmapPage.ets`，只能认定为局部控件组件化，不能认定为页面内容组件化。

最高优先级应是先将四个 Section 提取为独立 Humble View 组件，再处理主题持久化边界和 ViewModel 拆分。
