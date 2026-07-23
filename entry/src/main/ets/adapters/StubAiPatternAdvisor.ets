import { LearningObservation } from '../domain/LearningObservation';
import { PatternSuggestion } from '../domain/LearnedPattern';
import { AiPatternAdvisor } from '../domain/ports/AiPatternAdvisor';

/**
 * Stub implementation of AiPatternAdvisor.
 *
 * Always returns an empty array — the safe degradation baseline.
 * When a real HTTP adapter is ready, swap this in EntryAbility
 * without touching any usecase or VM code.
 */
export class StubAiPatternAdvisor implements AiPatternAdvisor {
  async analyze(observations: LearningObservation[]): Promise<PatternSuggestion[]> {
    return [];
  }
}
