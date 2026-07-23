/**
 * UseCase: Load heatmap cells for a given month.
 * Depends on CheckInRepository (port).
 */
import { CheckInRepository } from '../domain/ports/CheckInRepository';
import { HeatmapCell } from '../domain/Streak';
import { ILoadHeatmap } from '../domain/ports/HeatmapUseCases';

export class LoadHeatmap implements ILoadHeatmap {
  private repo: CheckInRepository;

  constructor(repo: CheckInRepository) {
    this.repo = repo;
  }

  async execute(year: number, month: number): Promise<HeatmapCell[]> {
    const checkins = await this.repo.loadByMonth(year, month);
    const daysInMonth = new Date(year, month, 0).getDate();
    const cells: HeatmapCell[] = [];

    for (let day = 1; day <= daysInMonth; day++) {
      const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
      const match = checkins.find((c) => c.date === dateStr);
      cells.push(new HeatmapCell(dateStr, match ? 1 : 0, match));
    }

    return cells;
  }
}
