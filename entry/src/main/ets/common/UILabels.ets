/**
 * All UI labels — decoupled via @Provide/@Consume.
 * Supports Chinese and English via CHINESE_UI_LABELS / ENGLISH_UI_LABELS.
 */
export class UILabels {
  // ── Navigation tabs
  tabCalendar: string;
  tabLogs: string;
  tabPatterns: string;
  tabProfile: string;
  // ── Day-of-week headers
  dayMo: string;
  dayTu: string;
  dayWe: string;
  dayTh: string;
  dayFr: string;
  daySa: string;
  daySu: string;
  // ── CheckIn
  commitTarget: string;
  commitPlaceholder: string;
  commitButton: string;
  noDateSelected: string;
  // ── Calendar section
  calendarView: string;
  bestRun: string;
  daysUnit: string;
  monthCommits: string;
  // ── Logs section
  summary: string;
  activityStream: string;
  localRecords: string;
  storageMode: string;
  privateAppData: string;
  onDevice: string;
  commits: string;
  noCommitsYet: string;
  awaitingCalendarInput: string;
  // ── Patterns section
  engine: string;
  patternEngine: string;
  localInference: string;
  listening: string;
  learnedPatterns: string;
  activeTerms: string;
  milestones: string;
  signal: string;
  rhythm: string;
  habit: string;
  mastery: string;
  signals: string;
  noPatternsYet: string;
  awaitingLocalActivity: string;
  nextMilestone: string;
  milestoneComplete: string;
  // ── Profile section
  appearance: string;
  themeLabel: string;
  colorSystem: string;
  storage: string;
  storageLocation: string;
  localActivity: string;
  dataSummary: string;
  developer: string;
  commitCountLabel: string;
  patternCountLabel: string;
  // ── Skin switcher
  light: string;
  darkTheme: string;
  pink: string;
  pastel: string;
  // ── HeatmapPage
  initializing: string;
  signalReceived: string;
  // ── DebugPanel (existing, now in UILabels)
  devDebugPanel: string;
  unifiedDebugEntry: string;
  quickTests: string;
  featureLabs: string;
  loadHeatmap: string;
  loadActivity: string;
  reloadMonth: string;
  refreshData: string;
  tokenSnapshot: string;
  clearRecords: string;
  easterEggLab: string;
  easterEggLabSub: string;
  patternLearningLab: string;
  patternLearningLabSub: string;
  // ── EasterEggLabDialog
  liveEffectPipeline: string;
  presets: string;
  lifecycle: string;
  sparkle: string;
  darkEgg: string;
  bubble: string;
  sakura: string;
  rise: string;
  atField: string;
  autoDismiss: string;
  tapDismiss: string;
  retriggerBlock: string;
  rapidTaps: string;
  afterEnd: string;
  // ── PatternLearningLabDialog
  realLearningPipeline: string;
  stages: string;
  matching: string;
  data_section: string;
  ai_section: string;
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
  // ── Calendar navigation and lab
  today: string;
  calendarLab: string;
  calendarLabSub: string;
  monthNavigationPipeline: string;
  calendarStandard: string;
  calendarYearBoundaries: string;
  previousMonth: string;
  nextMonth: string;
  currentMonth: string;
  decemberToJanuary: string;
  januaryToDecember: string;
  // ── Language toggle
  langZh: string;
  langEn: string;

  constructor(
    tabCalendar: string, tabLogs: string, tabPatterns: string, tabProfile: string,
    dayMo: string, dayTu: string, dayWe: string, dayTh: string, dayFr: string, daySa: string, daySu: string,
    commitTarget: string, commitPlaceholder: string, commitButton: string, noDateSelected: string,
    calendarView: string, bestRun: string, daysUnit: string, monthCommits: string,
    summary: string, activityStream: string, localRecords: string, storageMode: string,
    privateAppData: string, onDevice: string, commits: string, noCommitsYet: string, awaitingCalendarInput: string,
    engine: string, patternEngine: string, localInference: string, listening: string,
    learnedPatterns: string, activeTerms: string, milestones: string, signal: string,
    rhythm: string, habit: string, mastery: string, signals: string,
    noPatternsYet: string, awaitingLocalActivity: string, nextMilestone: string, milestoneComplete: string,
    appearance: string, themeLabel: string, colorSystem: string, storage: string,
    storageLocation: string, localActivity: string, dataSummary: string, developer: string,
    commitCountLabel: string, patternCountLabel: string,
    light: string, darkTheme: string, pink: string, pastel: string,
    initializing: string, signalReceived: string,
    devDebugPanel: string, unifiedDebugEntry: string, quickTests: string, featureLabs: string,
    loadHeatmap: string, loadActivity: string, reloadMonth: string, refreshData: string,
    tokenSnapshot: string, clearRecords: string,
    easterEggLab: string, easterEggLabSub: string, patternLearningLab: string, patternLearningLabSub: string,
    liveEffectPipeline: string, presets: string, lifecycle: string,
    sparkle: string, darkEgg: string, bubble: string, sakura: string, rise: string, atField: string,
    autoDismiss: string, tapDismiss: string, retriggerBlock: string, rapidTaps: string, afterEnd: string,
    realLearningPipeline: string, stages: string, matching: string, data_section: string, ai_section: string,
    observing: string, candidate: string, mature: string, similarMatch: string, noMatch: string,
    cooldown: string, observationStatus: string, resetSample: string,
    aiPing: string, aiAnalyzeSample: string, aiTimeout: string, aiInvalidResponse: string,
    today: string, calendarLab: string, calendarLabSub: string, monthNavigationPipeline: string,
    calendarStandard: string, calendarYearBoundaries: string,
    previousMonth: string, nextMonth: string, currentMonth: string,
    decemberToJanuary: string, januaryToDecember: string,
    langZh: string, langEn: string,
  ) {
    this.tabCalendar = tabCalendar; this.tabLogs = tabLogs; this.tabPatterns = tabPatterns; this.tabProfile = tabProfile;
    this.dayMo = dayMo; this.dayTu = dayTu; this.dayWe = dayWe; this.dayTh = dayTh; this.dayFr = dayFr; this.daySa = daySa; this.daySu = daySu;
    this.commitTarget = commitTarget; this.commitPlaceholder = commitPlaceholder; this.commitButton = commitButton; this.noDateSelected = noDateSelected;
    this.calendarView = calendarView; this.bestRun = bestRun; this.daysUnit = daysUnit; this.monthCommits = monthCommits;
    this.summary = summary; this.activityStream = activityStream; this.localRecords = localRecords; this.storageMode = storageMode;
    this.privateAppData = privateAppData; this.onDevice = onDevice; this.commits = commits; this.noCommitsYet = noCommitsYet; this.awaitingCalendarInput = awaitingCalendarInput;
    this.engine = engine; this.patternEngine = patternEngine; this.localInference = localInference; this.listening = listening;
    this.learnedPatterns = learnedPatterns; this.activeTerms = activeTerms; this.milestones = milestones; this.signal = signal;
    this.rhythm = rhythm; this.habit = habit; this.mastery = mastery; this.signals = signals;
    this.noPatternsYet = noPatternsYet; this.awaitingLocalActivity = awaitingLocalActivity; this.nextMilestone = nextMilestone; this.milestoneComplete = milestoneComplete;
    this.appearance = appearance; this.themeLabel = themeLabel; this.colorSystem = colorSystem; this.storage = storage;
    this.storageLocation = storageLocation; this.localActivity = localActivity; this.dataSummary = dataSummary; this.developer = developer;
    this.commitCountLabel = commitCountLabel; this.patternCountLabel = patternCountLabel;
    this.light = light; this.darkTheme = darkTheme; this.pink = pink; this.pastel = pastel;
    this.initializing = initializing; this.signalReceived = signalReceived;
    this.devDebugPanel = devDebugPanel; this.unifiedDebugEntry = unifiedDebugEntry; this.quickTests = quickTests; this.featureLabs = featureLabs;
    this.loadHeatmap = loadHeatmap; this.loadActivity = loadActivity; this.reloadMonth = reloadMonth; this.refreshData = refreshData;
    this.tokenSnapshot = tokenSnapshot; this.clearRecords = clearRecords;
    this.easterEggLab = easterEggLab; this.easterEggLabSub = easterEggLabSub; this.patternLearningLab = patternLearningLab; this.patternLearningLabSub = patternLearningLabSub;
    this.liveEffectPipeline = liveEffectPipeline; this.presets = presets; this.lifecycle = lifecycle;
    this.sparkle = sparkle; this.darkEgg = darkEgg; this.bubble = bubble; this.sakura = sakura; this.rise = rise; this.atField = atField;
    this.autoDismiss = autoDismiss; this.tapDismiss = tapDismiss; this.retriggerBlock = retriggerBlock; this.rapidTaps = rapidTaps; this.afterEnd = afterEnd;
    this.realLearningPipeline = realLearningPipeline; this.stages = stages; this.matching = matching; this.data_section = data_section; this.ai_section = ai_section;
    this.observing = observing; this.candidate = candidate; this.mature = mature; this.similarMatch = similarMatch; this.noMatch = noMatch;
    this.cooldown = cooldown; this.observationStatus = observationStatus; this.resetSample = resetSample;
    this.aiPing = aiPing; this.aiAnalyzeSample = aiAnalyzeSample; this.aiTimeout = aiTimeout; this.aiInvalidResponse = aiInvalidResponse;
    this.today = today; this.calendarLab = calendarLab; this.calendarLabSub = calendarLabSub;
    this.monthNavigationPipeline = monthNavigationPipeline;
    this.calendarStandard = calendarStandard; this.calendarYearBoundaries = calendarYearBoundaries;
    this.previousMonth = previousMonth; this.nextMonth = nextMonth; this.currentMonth = currentMonth;
    this.decemberToJanuary = decemberToJanuary; this.januaryToDecember = januaryToDecember;
    this.langZh = langZh; this.langEn = langEn;
  }
}

export const CHINESE_UI_LABELS: UILabels = new UILabels(
  // Navigation
  '日历', '日志', '模式', '用户',
  // Days
  '一', '二', '三', '四', '五', '六', '日',
  // CheckIn
  '打卡目标', '记录今天的进展', '提交', '未选择日期',
  // Calendar
  '日历视图', '最长连续', '天', '本月提交',
  // Logs
  '摘要', '活动流', '本地记录', '存储模式', '应用私有数据', '设备本地', '提交记录',
  '尚无提交', '等待日历输入',
  // Patterns
  '引擎', '模式引擎', '本地推理', '监听中', '已学习模式', '活跃词汇', '里程碑',
  '初现', '节奏', '习惯', '精通', '信号',
  '尚无模式', '等待本地活动', '下一里程碑 // ', '里程碑 // 完成',
  // Profile
  '外观', '主题', '色彩系统', '存储', '存储位置', '本地活动', '数据摘要', '开发者', '次提交', '个模式',
  // Skin
  '浅色', '深色', '粉色', '幻彩',
  // HeatmapPage
  '初始化中 // ACTRACE',
  'ACTRACE // 收到信号',
  // DebugPanel
  '开发调试面板', '统一调试入口', '快速测试', '功能实验室',
  '加载热力图', '加载活动', '刷新月份', '刷新数据', '主题快照', '清除记录',
  '彩蛋实验室', '预设 / 生命周期 / 实时效果', '模式学习实验室', '阶段 / 匹配 / 冷却',
  // EasterEggLab
  '实时效果管线', '预设', '生命周期',
  '闪光', '暗影', '气泡', '樱花', '升腾', 'A.T.力场',
  '自动关闭', '点击关闭', '重入阻断', '快速连点', '结束后重播',
  // PatternLearningLab
  '真实学习管线', '阶段', '匹配', '数据', 'AI',
  '观察中', '候选', '已成熟', '相似匹配', '无匹配', '冷却中', '观察状态', '重置样本',
  'AI 探活', 'AI 分析样本', 'AI 超时', 'AI 无效响应',
  // Calendar navigation and lab
  '今日', '日历实验室', '月份导航 / 跨年边界', '月份导航管线', '常规', '跨年边界',
  '上一月', '下一月', '本月', '十二月 > 一月', '一月 > 十二月',
  // Language toggle
  '中', '英',
);

export const ENGLISH_UI_LABELS: UILabels = new UILabels(
  // Navigation
  'CALENDAR', 'LOGS', 'PATTERNS', 'PROFILE',
  // Days
  'MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU',
  // CheckIn
  'COMMIT TARGET', "LOG TODAY'S PROGRESS", 'COMMIT', 'NO DATE SELECTED',
  // Calendar
  'CALENDAR VIEW', 'BEST RUN', 'DAYS', 'MONTH COMMITS',
  // Logs
  'SUMMARY', 'ACTIVITY STREAM', 'LOCAL RECORDS', 'STORAGE MODE', 'PRIVATE APP DATA', 'ON DEVICE', 'COMMITS',
  'NO COMMITS YET', 'AWAITING CALENDAR INPUT',
  // Patterns
  'ENGINE', 'PATTERN ENGINE', 'LOCAL INFERENCE', 'LISTENING', 'LEARNED PATTERNS', 'ACTIVE TERMS',
  'MILESTONES', 'SIGNAL', 'RHYTHM', 'HABIT', 'MASTERY', 'SIGNALS',
  'NO PATTERNS YET', 'AWAITING LOCAL ACTIVITY', 'NEXT MILESTONE // ', 'MILESTONE // COMPLETE',
  // Profile
  'APPEARANCE', 'THEME', 'COLOR SYSTEM', 'STORAGE', 'STORAGE LOCATION', 'LOCAL ACTIVITY', 'DATA SUMMARY', 'DEVELOPER',
  'COMMITS', 'PATTERNS',
  // Skin
  'LIGHT', 'DARK', 'PINK', 'PASTEL',
  // HeatmapPage
  'INITIALIZING // ACTRACE',
  'ACTRACE // SIGNAL RECEIVED',
  // DebugPanel
  'DEV DEBUG PANEL', 'UNIFIED DEBUG ENTRY', 'QUICK TESTS', 'FEATURE LABS',
  'LOAD HEATMAP', 'LOAD ACTIVITY', 'RELOAD MONTH', 'REFRESH DATA', 'TOKEN SNAPSHOT', 'CLEAR RECORDS',
  'EASTER EGG LAB', 'PRESETS / LIFECYCLE / LIVE EFFECTS', 'PATTERN LEARNING LAB', 'STAGES / MATCHING / COOLDOWN',
  // EasterEggLab
  'LIVE EFFECT PIPELINE', 'PRESETS', 'LIFECYCLE',
  'SPARKLE', 'DARK', 'BUBBLE', 'SAKURA', 'RISE', 'AT FIELD',
  'AUTO DISMISS', 'TAP DISMISS', 'RETRIGGER BLOCK', 'RAPID TAPS', 'AFTER END',
  // PatternLearningLab
  'REAL LEARNING PIPELINE', 'STAGES', 'MATCHING', 'DATA', 'AI',
  'OBSERVING', 'CANDIDATE', 'MATURE', 'SIMILAR MATCH', 'NO MATCH', 'COOLDOWN',
  'OBSERVATION STATUS', 'RESET SAMPLE',
  'AI PING', 'AI ANALYZE SAMPLE', 'AI TIMEOUT', 'AI INVALID RESPONSE',
  // Calendar navigation and lab
  'TODAY', 'CALENDAR LAB', 'NAVIGATION / YEAR BOUNDARIES', 'SYSTEM / MONTH NAVIGATION',
  'STANDARD', 'YEAR BOUNDARIES', 'PREVIOUS', 'NEXT', 'CURRENT', 'DEC > JAN', 'JAN > DEC',
  // Language toggle
  'ZH', 'EN',
);

export function labelsForLocale(locale: string): UILabels {
  return locale === 'en' ? ENGLISH_UI_LABELS : CHINESE_UI_LABELS;
}
