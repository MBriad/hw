import { EasterEgg } from '../EasterEgg';
import { LearningObservation } from '../LearningObservation';
import { LearnedPattern, PatternSuggestion } from '../LearnedPattern';

export interface PatternLearningApi {
  load(): Promise<LearnedPattern[]>;
  captureInput(content: string, date: string, now: number): Promise<void>;
  pendingObservationCount(): Promise<number>;
  loadPendingBatch(limit: number): Promise<LearningObservation[]>;
  acknowledgeProcessed(observations: LearningObservation[]): Promise<void>;
  observe(suggestion: PatternSuggestion, date: string, now: number): Promise<LearnedPattern>;
  match(content: string, now: number): Promise<EasterEgg | null>;
  clear(): Promise<void>;
}
