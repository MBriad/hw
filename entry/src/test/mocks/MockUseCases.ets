import { HeatmapCell } from '../../main/ets/domain/Streak';
import { ILoadHeatmap, IRecordCheckIn } from '../../main/ets/domain/ports/HeatmapUseCases';

/**
 * Mock usecases for ViewModel testing.
 * Implements the same interfaces as real usecases (DIP).
 */
export class MockLoadHeatmap implements ILoadHeatmap {
  public capturedYear: number = 0;
  public capturedMonth: number = 0;
  public resultCells: HeatmapCell[] = [];

  async execute(year: number, month: number): Promise<HeatmapCell[]> {
    this.capturedYear = year;
    this.capturedMonth = month;
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
