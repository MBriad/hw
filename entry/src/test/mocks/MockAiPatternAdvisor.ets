import { LearningObservation } from '../../main/ets/domain/LearningObservation';
import { PatternSuggestion } from '../../main/ets/domain/LearnedPattern';
import { AiPatternAdvisor } from '../../main/ets/domain/ports/AiPatternAdvisor';

/**
 * Mock implementation of AiPatternAdvisor for testing.
 *
 * Configure suggestions to return, or set shouldThrow to test
 * degradation behavior.
 */
export class MockAiPatternAdvisor implements AiPatternAdvisor {
  public suggestions: PatternSuggestion[] = [];
  public shouldThrow: boolean = false;
  public analyzeCount: number = 0;
  public lastObservations: LearningObservation[] = [];

  async analyze(observations: LearningObservation[]): Promise<PatternSuggestion[]> {
    this.analyzeCount++;
    this.lastObservations = observations;
    if (this.shouldThrow) {
      throw new Error('Mock AI failure');
    }
    return this.suggestions;
  }
}
