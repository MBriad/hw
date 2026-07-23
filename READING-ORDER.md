# 代码阅读顺序 — 架构优先（由内向外）

> **原则**：遵循依赖方向 `pages → viewmodels → usecases → domain/ports`，由内向外逐层阅读。
> 外层依赖内层，内层不依赖外层，所以先读内层再读外层时已有上下文。

---

## 第一层：领域实体（Domain Entities）

**零外部依赖，最纯粹的模型定义。** 理解了这些就理解了系统的"语言"。

| 序号 | 文件 | 要点 |
|------|------|------|
| 1 | `domain/CheckIn.ets` | 核心实体：打卡记录，包含日期、关键词等字段 |
| 2 | `domain/Streak.ets` | 连续打卡天数模型 |
| 3 | `domain/EasterEgg.ets` | 彩蛋触发条件与状态 |
| 4 | `domain/LearnedPattern.ets` | 学习到的用户行为模式 |
| 5 | `domain/LearnedPatternPolicy.ets` | 模式匹配策略 |
| 6 | `domain/FrequencyPatternEngine.ets` | 频率模式识别引擎 |
| 7 | `domain/ActivitySnapshot.ets` | 活动快照 |
| 8 | `domain/AppSection.ets` | 应用分区枚举（Tab 页面标识） |
| 9 | `domain/SkinTheme.ets` | **设计令牌** — 4 套主题色（Light/Dark/Pink/Pastel）的 13 个 DesignTokens 字段定义 |

---

## 第二层：端口接口（Domain Ports）

**抽象接口，定义"能做什么"而不关心"怎么做"。** 阅读这些接口就知道系统有哪些能力契约。

| 序号 | 文件 | 要点 |
|------|------|------|
| 10 | `domain/ports/CheckInRepository.ets` | 打卡数据的增删查接口 |
| 11 | `domain/ports/HeatmapUseCases.ets` | 热力图相关用例接口：`ILoadHeatmap`、`IRecordCheckIn` 等 |
| 12 | `domain/ports/ActivityUseCases.ets` | 活动记录用例接口 |
| 13 | `domain/ports/StreakCalculator.ets` | 连续打卡天数计算接口 |
| 14 | `domain/ports/PatternLearningApi.ets` | 模式学习 API 接口 |
| 15 | `domain/ports/UsagePatternEngine.ets` | 使用模式引擎接口 |
| 16 | `domain/ports/LearnedPatternRepository.ets` | 学习模式的持久化接口 |
| 17 | `domain/ports/SkinProvider.ets` | 主题切换/查询接口 |
| 18 | `domain/ports/SoundPlayer.ets` | 音效播放接口 |

---

## 第三层：用例（Use Cases）

**业务逻辑编排层。** 每个用例注入端口接口，协调领域实体完成一个完整业务场景。

| 序号 | 文件 | 要点 |
|------|------|------|
| 19 | `usecases/LoadHeatmap.ets` | 加载热力图数据（月份→格子列表） |
| 20 | `usecases/RecordCheckIn.ets` | 记录一次打卡 |
| 21 | `usecases/LoadActivity.ets` | 加载活动日志 |
| 22 | `usecases/ClearCheckIns.ets` | 清除打卡数据 |
| 23 | `usecases/DetectEasterEgg.ets` | 彩蛋检测逻辑 |
| 24 | `usecases/ManageLearnedPatterns.ets` | 学习模式的增删查管理 |

---

## 第四层：ViewModel

**@Observed 状态持有者，连接用例和 UI。** 这里是数据流的中枢。

| 序号 | 文件 | 要点 |
|------|------|------|
| 25 | `viewmodels/HeatmapVM.ets` | **核心 VM** — 持有 cells/streak/skin/selectedDate 等状态，调用各用例接口，暴露方法给页面 |

---

## 第五层：公共 UI 基础设施（Common）

**设计系统的常量与工具，UI 层的基础。**

| 序号 | 文件 | 要点 |
|------|------|------|
| 26 | `common/SpacingTokens.ets` | 间距常量 |
| 27 | `common/RadiusTokens.ets` | 圆角常量 |
| 28 | `common/TypographyStyles.ets` | 字体排版样式 |
| 29 | `common/GlassTheme.ets` | 毛玻璃效果工具 |

---

## 第六层：页面与组件（Pages & Components）

**ArkUI 声明式 UI 层。** 从入口页面向下读，理解视图如何消费 ViewModel。

### 入口页面

| 序号 | 文件 | 要点 |
|------|------|------|
| 30 | `pages/Index.ets` | 路由入口页 |
| 31 | `pages/HeatmapPage.ets` | **主页面** — `@Provide tokens`，组装所有 section |
| 32 | `pages/HeatmapContent.ets` | 热力图内容区 |

### Section 区域组件

| 序号 | 文件 | 要点 |
|------|------|------|
| 33 | `pages/sections/CalendarSection.ets` | 日历打卡区 |
| 34 | `pages/sections/LogsSection.ets` | 活动日志区 |
| 35 | `pages/sections/PatternsSection.ets` | 学习模式展示区 |
| 36 | `pages/sections/ProfileSection.ets` | 个人中心/设置区 |

### 通用组件

| 序号 | 文件 | 要点 |
|------|------|------|
| 37 | `pages/components/DayCell.ets` | 日历格子组件 |
| 38 | `pages/components/HeatmapGrid.ets` | 热力图网格 |
| 39 | `pages/components/GridBackdrop.ets` | 网格背景 |
| 40 | `pages/components/CheckInInput.ets` | 打卡输入框 |
| 41 | `pages/components/QuoteBanner.ets` | 语录横幅 |
| 42 | `pages/components/SkinSwitcher.ets` | 主题切换器 |
| 43 | `pages/components/ThemeProvider.ets` | 主题提供者 |
| 44 | `pages/components/ParticleOverlay.ets` | 粒子特效覆盖层 |
| 45 | `pages/components/HorizontalNavigation.ets` | 水平导航栏 |

### Debug UI

| 序号 | 文件 | 要点 |
|------|------|------|
| 46 | `debug/ui/DebugPanel.ets` | 调试面板 |
| 47 | `debug/ui/EasterEggLabDialog.ets` | 彩蛋实验室对话框 |
| 48 | `debug/ui/PatternLearningLabDialog.ets` | 模式学习实验室对话框 |
| 49 | `debug/DebugRuntime.ets` | 调试运行时 |

---

## 第七层：适配器（Adapters）

**端口接口的具体实现，使用 @kit.* 平台 API。** 最外层，可替换。

| 序号 | 文件 | 要点 |
|------|------|------|
| 50 | `adapters/PreferencesCheckInRepo.ets` | 用 `@ohos.data.preferences` 实现 `CheckInRepository` |
| 51 | `adapters/PreferencesLearnedPatternRepo.ets` | 学习模式的持久化实现 |
| 52 | `adapters/SkinProviderImpl.ets` | 主题切换实现（含持久化） |
| 53 | `adapters/SoundPlayerImpl.ets` | 音效播放实现 |

---

## 第八层：组合根（Composition Root）

**唯一创建具体实例的地方。** 理解了前面所有层，最后看这里就知道依赖是如何注入的。

| 序号 | 文件 | 要点 |
|------|------|------|
| 54 | `entryability/EntryAbility.ets` | 应用入口 — 创建所有适配器实例，注入到 ViewModel，挂载页面 |

---

## 补充：产品与架构文档

| 序号 | 文件 | 要点 |
|------|------|------|
| 55 | `target.md` | 产品设计文档，理解功能需求 |
| 56 | `AGENTS.md` | 构建命令、架构规则、设计系统规范 |
| 57 | `.agent/architecture/ui-design-system/` | UI 设计系统详细参考 |

---

## 阅读策略总结

```
领域实体 (1→9)     → 理解"系统在说什么"
端口接口 (10→18)   → 理解"系统能做什么"
用例编排 (19→24)   → 理解"业务怎么做"
ViewModel (25)     → 理解"状态怎么流转"
公共基础 (26→29)   → 理解"UI 的设计语言"
页面组件 (30→49)   → 理解"用户看到什么、操作什么"
适配器  (50→53)    → 理解"底层怎么存储/播放"
组合根  (54)       → 理解"一切如何组装"
文档    (55→57)    → 补充产品与规范背景
```

**建议**：每读完一层，用一句话总结该层的职责和对外暴露的契约，这样到组合根时会有"水到渠成"的感觉。
