/**
 * ViewModel: Central state management for the heatmap page.
 * @Observed — ArkUI components react to property changes via @ObjectLink.
 * Injects usecases and providers via constructor (DIP).
 */
import { HeatmapCell, StreakInfo, StreakLevel } from '../domain/Streak';
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { CheckIn } from '../domain/CheckIn';
import { EasterEgg, UsagePattern } from '../domain/EasterEgg';
import { IDetectEasterEgg, ILoadActivity } from '../domain/ports/ActivityUseCases';
import { IClearCheckIns, ILoadHeatmap, IRecordCheckIn } from '../domain/ports/HeatmapUseCases';
import { SkinProvider } from '../domain/ports/SkinProvider';
import { SoundPlayer } from '../domain/ports/SoundPlayer';

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
  private recordCheckIn: IRecordCheckIn;
  private clearCheckIns: IClearCheckIns;
  private loadActivity: ILoadActivity;
  private detectEasterEgg: IDetectEasterEgg;
  private skinProvider: SkinProvider;
  private soundPlayer: SoundPlayer;
  private eggRunId: number = 0;
  private currentYear: number = 2026;
  private currentMonth: number = 7;

  constructor(
    loadHeatmap: ILoadHeatmap,
    recordCheckIn: IRecordCheckIn,
    clearCheckIns: IClearCheckIns,
    loadActivity: ILoadActivity,
    detectEasterEgg: IDetectEasterEgg,
    skinProvider: SkinProvider,
    soundPlayer: SoundPlayer,
  ) {
    this.loadHeatmap = loadHeatmap;
    this.recordCheckIn = recordCheckIn;
    this.clearCheckIns = clearCheckIns;
    this.loadActivity = loadActivity;
    this.detectEasterEgg = detectEasterEgg;
    this.skinProvider = skinProvider;
    this.soundPlayer = soundPlayer;
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
    const egg = await this.detectEasterEgg.execute(this.selectedDate, content);
    await this.recordCheckIn.execute(this.selectedDate, content);
    await Promise.all([this.loadMonth(this.currentYear, this.currentMonth), this.refreshActivity()]);

    if (egg !== null) {
      this.triggerEasterEgg(egg);
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
      this.soundPlayer.play(egg.soundFile);
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

  switchSkin(theme: SkinTheme): void {
    this.currentSkin = theme;
    this.currentTokens = this.skinProvider.getTokens(theme);
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

  async debugUseCaseLoadHeatmap(): Promise<string> {
    try {
      const cells = await this.loadHeatmap.execute(this.currentYear, this.currentMonth);
      const active = cells.filter((cell: HeatmapCell) => cell.level > 0).length;
      return `OK | cells=${active}/${cells.length}`;
    } catch (error) {
      return `FAIL | ${JSON.stringify(error)}`;
    }
  }

  async debugUseCaseLoadActivity(): Promise<string> {
    try {
      const snapshot = await this.loadActivity.execute();
      return `OK | checkIns=${snapshot.checkIns.length} | patterns=${snapshot.patterns.length}`;
    } catch (error) {
      return `FAIL | ${JSON.stringify(error)}`;
    }
  }

  async debugUseCaseDetectEgg(): Promise<string> {
    try {
      const egg = await this.detectEasterEgg.execute(this.todayString, 'debug_probe');
      if (egg === null) {
        return 'OK | no match';
      }
      return `OK | keyword=${egg.keyword} | effect=${egg.effectType}`;
    } catch (error) {
      return `FAIL | ${JSON.stringify(error)}`;
    }
  }

  debugTokenSnapshot(): string {
    return `OK | theme=${this.currentSkin} | primary=${this.currentTokens.brandPrimary}`;
  }

  async debugClearAllRecords(): Promise<string> {
    try {
      await this.clearCheckIns.execute();
      this.selectedDate = '';
      this.dismissEgg();
      await Promise.all([this.loadMonth(this.currentYear, this.currentMonth), this.refreshActivity()]);
      return 'OK | records cleared';
    } catch (error) {
      return `FAIL | ${JSON.stringify(error)}`;
    }
  }
}
