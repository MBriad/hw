/**
 * Ports for heatmap usecases (DIP for ViewModel testing).
 * Pure interfaces — zero framework dependencies.
 */
import { HeatmapCell } from '../Streak';

export interface ILoadHeatmap {
  execute(year: number, month: number): Promise<HeatmapCell[]>;
}

export interface IRecordCheckIn {
  execute(date: string, content: string): Promise<void>;
}

export interface IClearCheckIns {
  execute(): Promise<void>;
}
