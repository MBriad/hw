/**
 * ViewModel: Central state management for the heatmap page.
 * @Observed — ArkUI components react to property changes via @ObjectLink.
 * Injects usecases and providers via constructor (DIP).
 */
import { HeatmapCell, StreakInfo, StreakLevel } from '../domain/Streak';
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { CheckIn } from '../domain/CheckIn';
import { EasterEgg, UsagePattern } from '../domain/EasterEgg';
import { ILoadActivity, IPlaySound } from '../domain/ports/ActivityUseCases';
import { ILoadHeatmap } from '../domain/ports/HeatmapUseCases';
import { ILoadPersistedTheme, ISwitchTheme } from '../domain/ports/ThemeUseCases';
import { IProcessCheckIn } from '../domain/ports/CheckInUseCase';

@Observed
export class HeatmapVM {
  cells: HeatmapCell[] = [];
  currentSkin: SkinTheme = SkinTheme.LIGHT;
  currentTokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  selectedDate: string = '';
  streakInfo: StreakInfo = { current: 0, longest: 0, level: StreakLevel.NONE };
  checkIns: CheckIn[] = [];
  usagePatterns: UsagePattern[] = [];

  // Easter egg state
  triggeredEgg: EasterEgg | null = null;
  showParticles: boolean = false;
  showBanner: boolean = false;
  soundFile: string = '';

  private loadHeatmap: ILoadHeatmap;
  private loadActivity: ILoadActivity;
  private processCheckIn: IProcessCheckIn;
  private loadPersistedTheme: ILoadPersistedTheme;
  private switchTheme: ISwitchTheme;
  private playSound: IPlaySound;
  private eggRunId: number = 0;
  private currentYear: number = 2026;
  private currentMonth: number = 7;

  constructor(
    loadHeatmap: ILoadHeatmap,
    loadActivity: ILoadActivity,
    processCheckIn: IProcessCheckIn,
    loadPersistedTheme: ILoadPersistedTheme,
    switchTheme: ISwitchTheme,
    playSound: IPlaySound,
  ) {
    this.loadHeatmap = loadHeatmap;
    this.loadActivity = loadActivity;
    this.processCheckIn = processCheckIn;
    this.loadPersistedTheme = loadPersistedTheme;
    this.switchTheme = switchTheme;
    this.playSound = playSound;
  }

  async initialize(year: number, month: number): Promise<void> {
    await Promise.all([this.loadMonth(year, month), this.refreshActivity()]);
  }

  async loadMonth(year: number, month: number): Promise<void> {
    this.currentYear = year;
    this.currentMonth = month;
    this.cells = await this.loadHeatmap.execute(year, month);
  }

  async doCheckIn(content: string): Promise<void> {
    const result = await this.processCheckIn.execute(
      this.selectedDate, content, this.currentYear, this.currentMonth);
    this.cells = result.cells;
    this.checkIns = result.checkIns;
    this.usagePatterns = result.usagePatterns;

    if (result.egg !== null) {
      this.triggerEasterEgg(result.egg);
    }
  }

  async refreshActivity(): Promise<void> {
    const snapshot = await this.loadActivity.execute();
    this.checkIns = snapshot.checkIns;
    this.usagePatterns = snapshot.patterns;
  }

  private triggerEasterEgg(egg: EasterEgg): void {
    if (this.triggeredEgg === null) {
      this.triggeredEgg = egg;
      this.showParticles = true;
      this.showBanner = true;
      this.soundFile = egg.soundFile;
      this.playSound.execute(egg.soundFile);
      const runId = ++this.eggRunId;
      setTimeout(() => {
        if (this.eggRunId === runId) {
          this.dismissEgg();
        }
      }, 2800);
    }
  }

  dismissEgg(): void {
    this.triggeredEgg = null;
    this.showParticles = false;
    this.showBanner = false;
  }

  selectDate(date: string): void {
    this.selectedDate = date;
  }

  async loadPersistedSkin(): Promise<void> {
    const result = await this.loadPersistedTheme.execute();
    this.currentSkin = result.theme;
    this.currentTokens = result.tokens;
  }

  async switchSkin(theme: SkinTheme): Promise<void> {
    // Update the render state before persistence so theme changes are visible immediately.
    this.currentSkin = theme;
    this.currentTokens = ThemePalette[theme];
    const tokens = await this.switchTheme.execute(theme);
    // Ignore a slower previous persistence request if the user switched again.
    if (this.currentSkin === theme) {
      this.currentTokens = tokens;
    }
  }

  isToday(date: string): boolean {
    const today = new Date();
    const y = today.getFullYear();
    const m = String(today.getMonth() + 1).padStart(2, '0');
    const d = String(today.getDate()).padStart(2, '0');
    return date === `${y}-${m}-${d}`;
  }

  get todayString(): string {
    const today = new Date();
    const y = today.getFullYear();
    const m = String(today.getMonth() + 1).padStart(2, '0');
    const d = String(today.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  get monthLabel(): string {
    const months = ['1月', '2月', '3月', '4月', '5月', '6月',
                    '7月', '8月', '9月', '10月', '11月', '12月'];
    return `${this.currentYear}年 ${months[this.currentMonth - 1]}`;
  }

  get monthCode(): string {
    return `${this.currentYear}.${String(this.currentMonth).padStart(2, '0')}`;
  }

  get monthCommitCount(): number {
    return this.cells.filter((cell: HeatmapCell) => cell.level > 0).length;
  }

  get totalCommitCount(): number {
    return this.checkIns.length;
  }

  get longestMonthStreak(): number {
    let longest = 0;
    let current = 0;
    this.cells.forEach((cell: HeatmapCell) => {
      if (cell.level > 0) {
        current++;
        longest = Math.max(longest, current);
      } else {
        current = 0;
      }
    });
    return longest;
  }

  // ── Debug surface (runtime layer verification) ──

  async debugUseCaseLoadHeatmap(): Promise<string> {
    try {
      const cells = await this.loadHeatmap.execute(this.currentYear, this.currentMonth);
      const active = cells.filter((c: HeatmapCell) => c.level > 0).length;
      return `OK | cells=${active}/${cells.length}`;
    } catch (e) {
      return `FAIL | ${JSON.stringify(e)}`;
    }
  }

  async debugUseCaseLoadActivity(): Promise<string> {
    try {
      const snapshot = await this.loadActivity.execute();
      return `OK | checkIns=${snapshot.checkIns.length} | patterns=${snapshot.patterns.length}`;
    } catch (e) {
      return `FAIL | ${JSON.stringify(e)}`;
    }
  }

  async debugUseCaseProcessCheckIn(): Promise<string> {
    try {
      const result = await this.processCheckIn.execute(
        this.todayString, 'debug_checkin', this.currentYear, this.currentMonth);
      this.cells = result.cells;
      this.checkIns = result.checkIns;
      this.usagePatterns = result.usagePatterns;
      const active = result.cells.filter((c: HeatmapCell) => c.level > 0).length;
      const eggInfo = result.egg !== null ? ` | egg="${result.egg.keyword}"` : '';
      return `OK | cells=${active}/${result.cells.length} | checkIns=${result.checkIns.length}${eggInfo}`;
    } catch (e) {
      return `FAIL | ${JSON.stringify(e)}`;
    }
  }

  async debugUseCaseLoadTheme(): Promise<string> {
    try {
      const result = await this.loadPersistedTheme.execute();
      return `OK | theme=${result.theme} | tokens=${result.tokens.brandPrimary}`;
    } catch (e) {
      return `FAIL | ${JSON.stringify(e)}`;
    }
  }

  async debugUseCaseSwitchTheme(): Promise<string> {
    try {
      const themes = [SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL];
      const tokens = await this.switchTheme.execute(themes[0]);
      return `OK | tokens=${tokens.brandPrimary}`;
    } catch (e) {
      return `FAIL | ${JSON.stringify(e)}`;
    }
  }

  debugClearState(): void {
    this.cells = [];
    this.currentSkin = SkinTheme.LIGHT;
    this.currentTokens = ThemePalette[SkinTheme.LIGHT];
    this.selectedDate = '';
    this.streakInfo = { current: 0, longest: 0, level: StreakLevel.NONE };
    this.checkIns = [];
    this.usagePatterns = [];
    this.triggeredEgg = null;
    this.showParticles = false;
    this.showBanner = false;
    this.soundFile = '';
  }
}
