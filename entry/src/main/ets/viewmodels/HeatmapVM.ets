/**
 * ViewModel: Central state management for the heatmap page.
 * @Observed — ArkUI components react to property changes via @ObjectLink.
 * Injects usecases and providers via constructor (DIP).
 */
import { HeatmapCell, StreakInfo, StreakLevel } from '../domain/Streak';
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { ILoadHeatmap, IRecordCheckIn } from '../domain/ports/HeatmapUseCases';
import { SkinProvider } from '../domain/ports/SkinProvider';

@Observed
export class HeatmapVM {
  cells: HeatmapCell[] = [];
  currentSkin: SkinTheme = SkinTheme.LIGHT;
  currentTokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  selectedDate: string = '';
  streakInfo: StreakInfo = { current: 0, longest: 0, level: StreakLevel.NONE };

  private loadHeatmap: ILoadHeatmap;
  private recordCheckIn: IRecordCheckIn;
  private skinProvider: SkinProvider;
  private currentYear: number = 2026;
  private currentMonth: number = 7;

  constructor(
    loadHeatmap: ILoadHeatmap,
    recordCheckIn: IRecordCheckIn,
    skinProvider: SkinProvider,
  ) {
    this.loadHeatmap = loadHeatmap;
    this.recordCheckIn = recordCheckIn;
    this.skinProvider = skinProvider;
  }

  async loadMonth(year: number, month: number): Promise<void> {
    this.currentYear = year;
    this.currentMonth = month;
    this.cells = await this.loadHeatmap.execute(year, month);
  }

  async doCheckIn(content: string): Promise<void> {
    await this.recordCheckIn.execute(this.selectedDate, content);
    await this.loadMonth(this.currentYear, this.currentMonth);
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
}
