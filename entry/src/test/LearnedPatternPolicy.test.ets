import { describe, it, expect } from '@ohos/hypium';
import { LearnedPattern, PatternStage, PatternSuggestion } from '../main/ets/domain/LearnedPattern';
import { LearnedPatternPolicy } from '../main/ets/domain/LearnedPatternPolicy';

function suggestion(confidence: number): PatternSuggestion {
  return new PatternSuggestion(
    'creative flow',
    ['sketch practice', 'drawing session'],
    confidence,
    'PATTERN MATURE // CREATIVE FLOW',
    'particle_rise',
    'level_up'
  );
}

export default function learnedPatternPolicyTest() {
  describe('LearnedPatternPolicy', () => {
    it('advances_only_after_count_date_and_confidence_thresholds', 0, () => {
      const policy = new LearnedPatternPolicy();
      let pattern: LearnedPattern | null = null;
      pattern = policy.observe(pattern, suggestion(0.35), '2026-07-01', 1);
      expect(pattern.stage).assertEqual(PatternStage.OBSERVING);
      pattern = policy.observe(pattern, suggestion(0.65), '2026-07-01', 2);
      pattern = policy.observe(pattern, suggestion(0.65), '2026-07-02', 3);
      expect(pattern.stage).assertEqual(PatternStage.CANDIDATE);
      pattern = policy.observe(pattern, suggestion(0.9), '2026-07-03', 4);
      pattern = policy.observe(pattern, suggestion(0.9), '2026-07-04', 5);
      expect(pattern.stage).assertEqual(PatternStage.MATURE);
      expect(pattern.occurrenceCount).assertEqual(5);
      expect(pattern.distinctDateCount).assertEqual(4);
    });

    it('matches_alias_only_when_mature_and_enters_cooldown', 0, () => {
      const policy = new LearnedPatternPolicy();
      const pattern = new LearnedPattern('creative flow', 'creative flow');
      pattern.aliases = ['sketch practice'];
      pattern.stage = PatternStage.MATURE;
      pattern.quote = 'CREATIVE FLOW';
      pattern.effectType = 'particle_rise';
      pattern.soundFile = 'level_up';
      const first = policy.match(pattern, 'evening sketch practice', 1000);
      expect(first.egg !== null).assertEqual(true);
      expect(first.pattern.stage).assertEqual(PatternStage.COOLDOWN);
      const blocked = policy.match(pattern, 'sketch practice', 2000);
      expect(blocked.egg === null).assertEqual(true);
      const replay = policy.match(pattern, 'sketch practice', 1000 + 24 * 60 * 60 * 1000);
      expect(replay.egg !== null).assertEqual(true);
      expect(replay.pattern.lastMatchedAt).assertEqual(1000 + 24 * 60 * 60 * 1000);
    });

    it('does_not_match_observing_or_unrelated_content', 0, () => {
      const policy = new LearnedPatternPolicy();
      const pattern = new LearnedPattern('creative flow', 'creative flow');
      pattern.aliases = ['sketch practice'];
      expect(policy.match(pattern, 'sketch practice', 1).egg === null).assertEqual(true);
      pattern.stage = PatternStage.MATURE;
      expect(policy.match(pattern, 'strength training plan', 2).egg === null).assertEqual(true);
    });
  });
}
