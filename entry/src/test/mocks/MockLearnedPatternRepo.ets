import { LearnedPattern } from '../../main/ets/domain/LearnedPattern';
import { LearnedPatternRepository } from '../../main/ets/domain/ports/LearnedPatternRepository';

export class MockLearnedPatternRepo implements LearnedPatternRepository {
  public patterns: LearnedPattern[] = [];
  public saveCount: number = 0;
  public clearCount: number = 0;

  async loadAll(): Promise<LearnedPattern[]> {
    return this.patterns;
  }

  async save(pattern: LearnedPattern): Promise<void> {
    this.saveCount++;
    const index = this.patterns.findIndex((item: LearnedPattern) => item.id === pattern.id);
    if (index >= 0) {
      this.patterns[index] = pattern;
    } else {
      this.patterns.push(pattern);
    }
  }

  async clear(): Promise<void> {
    this.clearCount++;
    this.patterns = [];
  }
}
