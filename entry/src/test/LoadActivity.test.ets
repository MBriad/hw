import { describe, it, expect } from '@ohos/hypium';
import { FrequencyPatternEngine } from '../main/ets/adapters/FrequencyPatternEngine';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { LoadActivity } from '../main/ets/usecases/LoadActivity';
import { MockCheckInRepo } from './mocks/MockCheckInRepo';

export default function loadActivityTest() {
  describe('LoadActivity', () => {
    it('sorts_recent_first_and_returns_learned_patterns', 0, async () => {
      const repo = new MockCheckInRepo();
      repo.loadAllResult = [
        new CheckIn('2026-07-01', 'pixel art', 1),
        new CheckIn('2026-07-03', 'pixel art', 3),
        new CheckIn('2026-07-02', 'pixel art', 2),
      ];
      const snapshot = await new LoadActivity(repo, new FrequencyPatternEngine()).execute();
      expect(snapshot.checkIns[0].date).assertEqual('2026-07-03');
      expect(snapshot.patterns.length > 0).assertEqual(true);
      expect(snapshot.patterns[0].count).assertEqual(3);
    });
  });
}
