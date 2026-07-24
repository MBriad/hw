/**
 * UseCase: Load heatmap cells for a given month.
 * Depends on CheckInRepository (port).
 */
import { CheckInRepository } from '../domain/ports/CheckInRepository';
import { CheckIn } from '../domain/CheckIn';
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
      const dayCheckIns = checkins.filter((checkIn: CheckIn) => checkIn.date === dateStr);
      let totalCharacters = 0;
      let latestCheckIn: CheckIn | undefined = undefined;
      dayCheckIns.forEach((checkIn: CheckIn) => {
        totalCharacters += checkIn.content.trim().length;
        if (latestCheckIn === undefined || checkIn.timestamp >= latestCheckIn.timestamp) {
          latestCheckIn = checkIn;
        }
      });
      cells.push(new HeatmapCell(
        dateStr,
        this.levelForCharacters(totalCharacters),
        latestCheckIn,
      ));
    }

    return cells;
  }

  private levelForCharacters(totalCharacters: number): number {
    if (totalCharacters >= 100) return 4;
    if (totalCharacters >= 50) return 3;
    if (totalCharacters >= 20) return 2;
    if (totalCharacters >= 1) return 1;
    return 0;
  }
}
