/**
 * UseCase: Remove all persisted check-in records.
 * Depends on CheckInRepository (port).
 */
import { CheckInRepository } from '../domain/ports/CheckInRepository';
import { IClearCheckIns } from '../domain/ports/HeatmapUseCases';

export class ClearCheckIns implements IClearCheckIns {
  private repo: CheckInRepository;

  constructor(repo: CheckInRepository) {
    this.repo = repo;
  }

  async execute(): Promise<void> {
    await this.repo.clear();
  }
}
