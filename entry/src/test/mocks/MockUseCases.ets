import { HeatmapCell } from '../../main/ets/domain/Streak';
import { ActivitySnapshot } from '../../main/ets/domain/ActivitySnapshot';
import { EasterEgg } from '../../main/ets/domain/EasterEgg';
import { IDetectEasterEgg, ILoadActivity } from '../../main/ets/domain/ports/ActivityUseCases';
import { IClearCheckIns, ILoadHeatmap, IRecordCheckIn } from '../../main/ets/domain/ports/HeatmapUseCases';

/**
 * Mock usecases for ViewModel testing.
 * Implements the same interfaces as real usecases (DIP).
 */
export class MockLoadHeatmap implements ILoadHeatmap {
  public capturedYear: number = 0;
  public capturedMonth: number = 0;
  public resultCells: HeatmapCell[] = [];
  public shouldFail: boolean = false;

  async execute(year: number, month: number): Promise<HeatmapCell[]> {
    this.capturedYear = year;
    this.capturedMonth = month;
    if (this.shouldFail) {
      throw new Error('load failed');
    }
    return this.resultCells;
  }
}

export class MockRecordCheckIn implements IRecordCheckIn {
  public capturedDate: string = '';
  public capturedContent: string = '';

  async execute(date: string, content: string): Promise<void> {
    this.capturedDate = date;
    this.capturedContent = content;
  }
}

export class MockClearCheckIns implements IClearCheckIns {
  public executeCount: number = 0;

  async execute(): Promise<void> {
    this.executeCount++;
  }
}

export class MockLoadActivity implements ILoadActivity {
  public result: ActivitySnapshot = new ActivitySnapshot([], []);
  public executeCount: number = 0;

  async execute(): Promise<ActivitySnapshot> {
    this.executeCount++;
    return this.result;
  }
}

export class MockDetectEasterEgg implements IDetectEasterEgg {
  public result: EasterEgg | null = null;
  public capturedDate: string = '';
  public capturedContent: string = '';

  async execute(date: string, content: string): Promise<EasterEgg | null> {
    this.capturedDate = date;
    this.capturedContent = content;
    return this.result;
  }
}
