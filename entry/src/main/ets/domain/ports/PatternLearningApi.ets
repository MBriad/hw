import { EasterEgg } from '../EasterEgg';
import { LearnedPattern, PatternSuggestion } from '../LearnedPattern';

export interface PatternLearningApi {
  load(): Promise<LearnedPattern[]>;
  observe(suggestion: PatternSuggestion, date: string, now: number): Promise<LearnedPattern>;
  match(content: string, now: number): Promise<EasterEgg | null>;
  clear(): Promise<void>;
}
