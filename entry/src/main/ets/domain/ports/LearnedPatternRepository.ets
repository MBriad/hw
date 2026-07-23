import { LearnedPattern } from '../LearnedPattern';

export interface LearnedPatternRepository {
  loadAll(): Promise<LearnedPattern[]>;
  save(pattern: LearnedPattern): Promise<void>;
  clear(): Promise<void>;
}
