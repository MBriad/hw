/**
 * Debug UI labels — decoupled from components via @Provide/@Consume.
 * Follows the same pattern as DesignTokens / ThemePalette.
 *
 * Currently only CHINESE is provided. Add ENGLISH_DEBUG_LABELS
 * when bilingual support is needed.
 */
export class DebugLabels {
  // DebugPanel
  devDebugPanel: string;
  unifiedDebugEntry: string;
  quickTests: string;
  featureLabs: string;
  // Quick test buttons
  loadHeatmap: string;
  loadActivity: string;
  reloadMonth: string;
  refreshData: string;
  tokenSnapshot: string;
  clearRecords: string;
  // Feature lab entries
  easterEggLab: string;
  easterEggLabSub: string;
  patternLearningLab: string;
  patternLearningLabSub: string;
  // EasterEggLabDialog
  liveEffectPipeline: string;
  presets: string;
  lifecycle: string;
  // Easter egg buttons
  sparkle: string;
  dark: string;
  bubble: string;
  sakura: string;
  rise: string;
  atField: string;
  autoDismiss: string;
  tapDismiss: string;
  retriggerBlock: string;
  rapidTaps: string;
  afterEnd: string;
  // PatternLearningLabDialog
  realLearningPipeline: string;
  stages: string;
  matching: string;
  data_section: string;
  ai_section: string;
  // Pattern buttons
  observing: string;
  candidate: string;
  mature: string;
  similarMatch: string;
  noMatch: string;
  cooldown: string;
  observationStatus: string;
  resetSample: string;
  aiPing: string;
  aiAnalyzeSample: string;
  aiTimeout: string;
  aiInvalidResponse: string;

  constructor(
    devDebugPanel: string,
    unifiedDebugEntry: string,
    quickTests: string,
    featureLabs: string,
    loadHeatmap: string,
    loadActivity: string,
    reloadMonth: string,
    refreshData: string,
    tokenSnapshot: string,
    clearRecords: string,
    easterEggLab: string,
    easterEggLabSub: string,
    patternLearningLab: string,
    patternLearningLabSub: string,
    liveEffectPipeline: string,
    presets: string,
    lifecycle: string,
    sparkle: string,
    dark: string,
    bubble: string,
    sakura: string,
    rise: string,
    atField: string,
    autoDismiss: string,
    tapDismiss: string,
    retriggerBlock: string,
    rapidTaps: string,
    afterEnd: string,
    realLearningPipeline: string,
    stages: string,
    matching: string,
    data_section: string,
    ai_section: string,
    observing: string,
    candidate: string,
    mature: string,
    similarMatch: string,
    noMatch: string,
    cooldown: string,
    observationStatus: string,
    resetSample: string,
    aiPing: string,
    aiAnalyzeSample: string,
    aiTimeout: string,
    aiInvalidResponse: string,
  ) {
    this.devDebugPanel = devDebugPanel;
    this.unifiedDebugEntry = unifiedDebugEntry;
    this.quickTests = quickTests;
    this.featureLabs = featureLabs;
    this.loadHeatmap = loadHeatmap;
    this.loadActivity = loadActivity;
    this.reloadMonth = reloadMonth;
    this.refreshData = refreshData;
    this.tokenSnapshot = tokenSnapshot;
    this.clearRecords = clearRecords;
    this.easterEggLab = easterEggLab;
    this.easterEggLabSub = easterEggLabSub;
    this.patternLearningLab = patternLearningLab;
    this.patternLearningLabSub = patternLearningLabSub;
    this.liveEffectPipeline = liveEffectPipeline;
    this.presets = presets;
    this.lifecycle = lifecycle;
    this.sparkle = sparkle;
    this.dark = dark;
    this.bubble = bubble;
    this.sakura = sakura;
    this.rise = rise;
    this.atField = atField;
    this.autoDismiss = autoDismiss;
    this.tapDismiss = tapDismiss;
    this.retriggerBlock = retriggerBlock;
    this.rapidTaps = rapidTaps;
    this.afterEnd = afterEnd;
    this.realLearningPipeline = realLearningPipeline;
    this.stages = stages;
    this.matching = matching;
    this.data_section = data_section;
    this.ai_section = ai_section;
    this.observing = observing;
    this.candidate = candidate;
    this.mature = mature;
    this.similarMatch = similarMatch;
    this.noMatch = noMatch;
    this.cooldown = cooldown;
    this.observationStatus = observationStatus;
    this.resetSample = resetSample;
    this.aiPing = aiPing;
    this.aiAnalyzeSample = aiAnalyzeSample;
    this.aiTimeout = aiTimeout;
    this.aiInvalidResponse = aiInvalidResponse;
  }
}

export const CHINESE_DEBUG_LABELS: DebugLabels = new DebugLabels(
  '开发调试面板',
  '统一调试入口',
  '快速测试',
  '功能实验室',
  '加载热力图',
  '加载活动',
  '刷新月份',
  '刷新数据',
  '主题快照',
  '清除记录',
  '彩蛋实验室',
  '预设 / 生命周期 / 实时效果',
  '模式学习实验室',
  '阶段 / 匹配 / 冷却',
  '实时效果管线',
  '预设',
  '生命周期',
  '闪光',
  '暗影',
  '气泡',
  '樱花',
  '升腾',
  'A.T.力场',
  '自动关闭',
  '点击关闭',
  '重入阻断',
  '快速连点',
  '结束后重播',
  '真实学习管线',
  '阶段',
  '匹配',
  '数据',
  'AI',
  '观察中',
  '候选',
  '已成熟',
  '相似匹配',
  '无匹配',
  '冷却中',
  '观察状态',
  '重置样本',
  'AI 探活',
  'AI 分析样本',
  'AI 超时',
  'AI 无效响应',
);
