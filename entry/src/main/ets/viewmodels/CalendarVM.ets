/**
 * ViewModel: Calendar grid, selected date, month navigation, and check-in action.
 * @Observed — ArkUI components react via @ObjectLink.
 */
import { HeatmapCell } from '../domain/Streak';
import { EasterEgg } from '../domain/EasterEgg';
import { IClearCheckIns, ILoadHeatmap, IRecordCheckIn } from '../domain/ports/HeatmapUseCases';
import { PatternLearningApi } from '../domain/ports/PatternLearningApi';

@Observed
export class CalendarVM {
  cells: HeatmapCell[] = [];
  selectedDate: string = '';

  private loadHeatmap: ILoadHeatmap;
  private recordCheckIn: IRecordCheckIn;
  private clearCheckIns: IClearCheckIns;
  private patternLearning: PatternLearningApi;
  private currentYear: number = 2026;
  private currentMonth: number = 7;

  constructor(
    loadHeatmap: ILoadHeatmap,
    recordCheckIn: IRecordCheckIn,
    clearCheckIns: IClearCheckIns,
    patternLearning: PatternLearningApi,
  ) {
    this.loadHeatmap = loadHeatmap;
    this.recordCheckIn = recordCheckIn;
    this.clearCheckIns = clearCheckIns;
    this.patternLearning = patternLearning;
  }

  async loadMonth(year: number, month: number): Promise<void> {
    this.currentYear = year;
    this.currentMonth = month;
    this.cells = await this.loadHeatmap.execute(year, month);
  }

  async doCheckIn(content: string): Promise<EasterEgg | null> {
    const now = Date.now();
    await this.recordCheckIn.execute(this.selectedDate, content);
    await this.patternLearning.captureInput(content, this.selectedDate, now);
    const egg = await this.patternLearning.match(content, now);
    await this.loadMonth(this.currentYear, this.currentMonth);
    return egg;
  }

  selectDate(date: string): void {
    this.selectedDate = date;
  }

  async clearAllRecords(): Promise<void> {
    await this.clearCheckIns.execute();
    this.selectedDate = '';
    await this.loadMonth(this.currentYear, this.currentMonth);
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
}
