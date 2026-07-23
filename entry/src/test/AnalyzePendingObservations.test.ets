import { describe, it, expect } from '@ohos/hypium';
import { LearningObservation } from '../main/ets/domain/LearningObservation';
import { PatternSuggestion } from '../main/ets/domain/LearnedPattern';
import { AnalyzePendingObservations } from '../main/ets/usecases/AnalyzePendingObservations';
import { MockAiPatternAdvisor } from './mocks/MockAiPatternAdvisor';
import { MockPatternLearning } from './mocks/MockUseCases';

function makeSuggestion(): PatternSuggestion {
  return new PatternSuggestion(
    'creative flow',
    ['sketch practice', 'drawing session'],
    0.65,
    'Keep creating!',
    'particle_rise',
    'level_up'
  );
}

export default function analyzePendingObservationsTest() {
  describe('AnalyzePendingObservations', () => {
    it('returns_zero_summary_when_no_pending_observations', 0, async () => {
      const learning = new MockPatternLearning();
      const advisor = new MockAiPatternAdvisor();
      const usecase = new AnalyzePendingObservations(learning, advisor);
      const result = await usecase.execute(1000);
      expect(result.analyzed).assertEqual(0);
      expect(result.patternsCreated).assertEqual(0);
      expect(advisor.analyzeCount).assertEqual(0);
    });

    it('processes_batch_and_creates_patterns', 0, async () => {
      const learning = new MockPatternLearning();
      learning.pendingObservations = [
        new LearningObservation('2026-07-01', 'evening sketch practice', 100),
        new LearningObservation('2026-07-02', 'daily drawing session', 200),
        new LearningObservation('2026-07-03', 'illustration study today', 300),
      ];
      const advisor = new MockAiPatternAdvisor();
      advisor.suggestions = [makeSuggestion()];
      const usecase = new AnalyzePendingObservations(learning, advisor);
      const result = await usecase.execute(1000);
      expect(result.analyzed).assertEqual(3);
      expect(result.patternsCreated).assertEqual(1);
      expect(advisor.analyzeCount).assertEqual(1);
      // Observations consumed
      expect(learning.pendingCount).assertEqual(0);
      expect(learning.pendingObservations.length).assertEqual(0);
    });

    it('returns_empty_when_advisor_returns_no_suggestions', 0, async () => {
      const learning = new MockPatternLearning();
      learning.pendingObservations = [
        new LearningObservation('2026-07-01', 'random note', 100),
      ];
      const advisor = new MockAiPatternAdvisor();
      advisor.suggestions = [];
      const usecase = new AnalyzePendingObservations(learning, advisor);
      const result = await usecase.execute(1000);
      expect(result.analyzed).assertEqual(1);
      expect(result.patternsCreated).assertEqual(0);
      // Observations still consumed to avoid infinite loop
      expect(learning.pendingCount).assertEqual(0);
    });

    it('degrades_gracefully_when_advisor_throws', 0, async () => {
      const learning = new MockPatternLearning();
      learning.pendingObservations = [
        new LearningObservation('2026-07-01', 'important note', 100),
      ];
      learning.pendingCount = 1;
      const advisor = new MockAiPatternAdvisor();
      advisor.shouldThrow = true;
      const usecase = new AnalyzePendingObservations(learning, advisor);
      const result = await usecase.execute(1000);
      expect(result.analyzed).assertEqual(0);
      expect(result.patternsCreated).assertEqual(0);
      // Observations NOT consumed — safe retry
      expect(learning.pendingObservations.length).assertEqual(1);
      expect(learning.pendingCount).assertEqual(1);
    });
  });
}
