import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { FrequencyPatternEngine } from '../main/ets/domain/FrequencyPatternEngine';

function checkIn(date: string, content: string): CheckIn {
  return { date: date, content: content, timestamp: 1 };
}

export default function keywordMatcherTest() {
  describe('FrequencyPatternEngine', () => {
    it('does_not_trigger_for_unseen_or_second_use', 0, () => {
      const engine = new FrequencyPatternEngine();
      expect(engine.evaluate('shader practice', []) === null).assertEqual(true);
      const once = [checkIn('2026-07-01', 'shader practice')];
      expect(engine.evaluate('shader practice', once) === null).assertEqual(true);
    });

    it('triggers_on_third_user_derived_occurrence', 0, () => {
      const engine = new FrequencyPatternEngine();
      const history = [
        checkIn('2026-07-01', 'shader practice'),
        checkIn('2026-07-02', 'shader practice'),
      ];
      const result = engine.evaluate('shader practice', history);
      expect(result !== null).assertEqual(true);
      expect(result!.keyword).assertEqual('shader practice');
      expect(result!.quote).assertContain('x3');
    });

    it('extracts_repeated_code_term_from_varied_text', 0, () => {
      const engine = new FrequencyPatternEngine();
      const history = [
        checkIn('2026-07-01', 'learned arkts layout'),
        checkIn('2026-07-02', 'fixed arkts state'),
      ];
      const result = engine.evaluate('tested arkts navigation', history);
      expect(result !== null).assertEqual(true);
      expect(result!.keyword).assertEqual('arkts');
    });

    it('does_not_use_a_built_in_trigger_vocabulary', 0, () => {
      const engine = new FrequencyPatternEngine();
      expect(engine.evaluate('Rust 加班 Bug', []) === null).assertEqual(true);
    });

    it('summarizes_patterns_and_next_milestone', 0, () => {
      const engine = new FrequencyPatternEngine();
      const history = [
        checkIn('2026-07-01', 'pixel art'),
        checkIn('2026-07-02', 'pixel art'),
        checkIn('2026-07-03', 'pixel art'),
      ];
      const patterns = engine.summarize(history);
      expect(patterns.length > 0).assertEqual(true);
      expect(patterns[0].term).assertEqual('pixel art');
      expect(patterns[0].count).assertEqual(3);
      expect(patterns[0].nextMilestone).assertEqual(7);
    });

    it('feedback_preset_is_stable_for_same_pattern', 0, () => {
      const engine = new FrequencyPatternEngine();
      const history = [
        checkIn('2026-07-01', '绘画'),
        checkIn('2026-07-02', '绘画'),
      ];
      const first = engine.evaluate('绘画', history);
      const second = engine.evaluate('绘画', history);
      expect(first!.effectType).assertEqual(second!.effectType);
      expect(first!.soundFile).assertEqual(second!.soundFile);
    });
  });
}
