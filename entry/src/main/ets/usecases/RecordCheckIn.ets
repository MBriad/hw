/**
 * UseCase: Record a new check-in for a given date.
 * Depends on CheckInRepository (port).
 */
import { CheckIn } from '../domain/CheckIn';
import { CheckInRepository } from '../domain/ports/CheckInRepository';
import { IRecordCheckIn } from '../domain/ports/HeatmapUseCases';

export class RecordCheckIn implements IRecordCheckIn {
  private repo: CheckInRepository;

  constructor(repo: CheckInRepository) {
    this.repo = repo;
  }

  async execute(date: string, content: string): Promise<void> {
    const checkIn = new CheckIn(date, content, Date.now());
    await this.repo.save(checkIn);
  }
}
