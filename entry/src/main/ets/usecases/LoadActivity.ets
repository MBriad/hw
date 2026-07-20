import { ActivitySnapshot } from '../domain/ActivitySnapshot';
import { CheckIn } from '../domain/CheckIn';
import { ILoadActivity } from '../domain/ports/ActivityUseCases';
import { CheckInRepository } from '../domain/ports/CheckInRepository';
import { UsagePatternEngine } from '../domain/ports/UsagePatternEngine';

export class LoadActivity implements ILoadActivity {
  private repo: CheckInRepository;
  private engine: UsagePatternEngine;

  constructor(repo: CheckInRepository, engine: UsagePatternEngine) {
    this.repo = repo;
    this.engine = engine;
  }

  async execute(): Promise<ActivitySnapshot> {
    const checkIns = await this.repo.loadAll();
    checkIns.sort((left: CheckIn, right: CheckIn) => right.timestamp - left.timestamp);
    return new ActivitySnapshot(checkIns, this.engine.summarize(checkIns));
  }
}
