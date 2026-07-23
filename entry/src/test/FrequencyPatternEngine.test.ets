import { describe, it, expect } from '@ohos/hypium';
import { FrequencyPatternEngine } from '../main/ets/adapters/FrequencyPatternEngine';
import { CheckIn } from '../main/ets/domain/CheckIn';

export default function frequencyPatternEngineTest() {
  describe('FrequencyPatternEngine', () => {
    it('summarizes_patterns_and_next_milestone', 0, () => {
      const engine = new FrequencyPatternEngine();
      const history = [
        new CheckIn('2026-07-01', 'pixel art', 1),
        new CheckIn('2026-07-02', 'pixel art', 2),
        new CheckIn('2026-07-03', 'pixel art', 3),
      ];
      const patterns = engine.summarize(history);
      expect(patterns.length > 0).assertEqual(true);
      expect(patterns[0].term).assertEqual('pixel art');
      expect(patterns[0].count).assertEqual(3);
      expect(patterns[0].nextMilestone).assertEqual(7);
    });

    it('extracts_repeated_code_term_from_varied_text', 0, () => {
      const engine = new FrequencyPatternEngine();
      const history = [
        new CheckIn('2026-07-01', 'learned arkts layout', 1),
        new CheckIn('2026-07-02', 'fixed arkts state', 2),
      ];
      const patterns = engine.summarize(history);
      const arkts = patterns.find((pattern) => pattern.term === 'arkts');
      expect(arkts !== undefined).assertEqual(true);
      expect(arkts!.count).assertEqual(2);
    });

    it('omits_single_use_terms', 0, () => {
      const engine = new FrequencyPatternEngine();
      const patterns = engine.summarize([
        new CheckIn('2026-07-01', 'one-off note', 1),
      ]);
      expect(patterns.length).assertEqual(0);
    });
  });
}
