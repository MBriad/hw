import { describe, it, expect } from '@ohos/hypium';
import { PatternStage, PatternSuggestion } from '../main/ets/domain/LearnedPattern';
import { LearnedPatternPolicy } from '../main/ets/domain/LearnedPatternPolicy';
import { ManageLearnedPatterns } from '../main/ets/usecases/ManageLearnedPatterns';
import { MockLearnedPatternRepo } from './mocks/MockLearnedPatternRepo';

function matureSuggestion(): PatternSuggestion {
  return new PatternSuggestion(
    'creative flow',
    ['sketch practice', 'drawing session'],
    0.9,
    'PATTERN MATURE // CREATIVE FLOW',
    'particle_rise',
    'level_up'
  );
}

export default function manageLearnedPatternsTest() {
  describe('ManageLearnedPatterns', () => {
    it('observes_and_persists_stage_progress', 0, async () => {
      const repo = new MockLearnedPatternRepo();
      const usecase = new ManageLearnedPatterns(repo, new LearnedPatternPolicy());
      const input = matureSuggestion();
      await usecase.observe(input, '2026-07-01', 1);
      await usecase.observe(input, '2026-07-02', 2);
      const pattern = await usecase.observe(input, '2026-07-03', 3);
      expect(pattern.stage).assertEqual(PatternStage.CANDIDATE);
      expect(repo.patterns.length).assertEqual(1);
      expect(repo.saveCount).assertEqual(3);
    });

    it('matches_only_mature_alias_and_persists_cooldown', 0, async () => {
      const repo = new MockLearnedPatternRepo();
      const usecase = new ManageLearnedPatterns(repo, new LearnedPatternPolicy());
      const input = matureSuggestion();
      for (let i = 0; i < 5; i++) {
        await usecase.observe(input, `2026-07-0${i + 1}`, i);
      }
      const egg = await usecase.match('evening sketch practice', 1000);
      expect(egg !== null).assertEqual(true);
      expect(repo.patterns[0].stage).assertEqual(PatternStage.COOLDOWN);
      const blocked = await usecase.match('drawing session', 2000);
      expect(blocked === null).assertEqual(true);
    });

    it('clear_removes_all_learned_patterns', 0, async () => {
      const repo = new MockLearnedPatternRepo();
      const usecase = new ManageLearnedPatterns(repo, new LearnedPatternPolicy());
      await usecase.observe(matureSuggestion(), '2026-07-01', 1);
      await usecase.clear();
      expect(repo.patterns.length).assertEqual(0);
      expect(repo.clearCount).assertEqual(1);
    });
  });
}
