/**
 * Detect a usage milestone without knowing how history is stored or analyzed.
 */
import { CheckIn } from '../domain/CheckIn';
import { EasterEgg } from '../domain/EasterEgg';
import { IDetectEasterEgg } from '../domain/ports/ActivityUseCases';
import { CheckInRepository } from '../domain/ports/CheckInRepository';
import { UsagePatternEngine } from '../domain/ports/UsagePatternEngine';

export class DetectEasterEgg implements IDetectEasterEgg {
  private repo: CheckInRepository;
  private engine: UsagePatternEngine;

  constructor(repo: CheckInRepository, engine: UsagePatternEngine) {
    this.repo = repo;
    this.engine = engine;
  }

  async execute(date: string, content: string): Promise<EasterEgg | null> {
    if (content.trim().length === 0) {
      return null;
    }
    const all = await this.repo.loadAll();
    const history = all.filter((checkIn: CheckIn) => checkIn.date !== date);
    return this.engine.evaluate(content, history);
  }
}
