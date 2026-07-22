import { ActivitySnapshot } from '../domain/ActivitySnapshot';
import { CheckInResult } from '../domain/CheckInResult';
import { HeatmapCell } from '../domain/Streak';
import { IDetectEasterEgg, ILoadActivity } from '../domain/ports/ActivityUseCases';
import { IProcessCheckIn } from '../domain/ports/CheckInUseCase';
import { ILoadHeatmap, IRecordCheckIn } from '../domain/ports/HeatmapUseCases';

export class ProcessCheckIn implements IProcessCheckIn {
  private detectEasterEgg: IDetectEasterEgg;
  private recordCheckIn: IRecordCheckIn;
  private loadHeatmap: ILoadHeatmap;
  private loadActivity: ILoadActivity;

  constructor(
    detectEasterEgg: IDetectEasterEgg,
    recordCheckIn: IRecordCheckIn,
    loadHeatmap: ILoadHeatmap,
    loadActivity: ILoadActivity,
  ) {
    this.detectEasterEgg = detectEasterEgg;
    this.recordCheckIn = recordCheckIn;
    this.loadHeatmap = loadHeatmap;
    this.loadActivity = loadActivity;
  }

  async execute(date: string, content: string, year: number, month: number): Promise<CheckInResult> {
    const egg = await this.detectEasterEgg.execute(date, content);
    await this.recordCheckIn.execute(date, content);
    const results = await Promise.all([
      this.loadHeatmap.execute(year, month),
      this.loadActivity.execute(),
    ]);
    const cells = results[0] as HeatmapCell[];
    const snapshot = results[1] as ActivitySnapshot;
    return new CheckInResult(cells, snapshot.checkIns, snapshot.patterns, egg);
  }
}
