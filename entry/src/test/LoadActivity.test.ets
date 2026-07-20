import { describe, it, expect } from '@ohos/hypium';
import { FrequencyPatternEngine } from '../main/ets/domain/FrequencyPatternEngine';
import { LoadActivity } from '../main/ets/usecases/LoadActivity';
import { MockCheckInRepo } from './mocks/MockCheckInRepo';

export default function loadActivityTest() {
  describe('LoadActivity', () => {
    it('sorts_recent_first_and_returns_learned_patterns', 0, async () => {
      const repo = new MockCheckInRepo();
      repo.loadAllResult = [
        { date: '2026-07-01', content: 'pixel art', timestamp: 1 },
        { date: '2026-07-03', content: 'pixel art', timestamp: 3 },
        { date: '2026-07-02', content: 'pixel art', timestamp: 2 },
      ];
      const snapshot = await new LoadActivity(repo, new FrequencyPatternEngine()).execute();
      expect(snapshot.checkIns[0].date).assertEqual('2026-07-03');
      expect(snapshot.patterns.length > 0).assertEqual(true);
      expect(snapshot.patterns[0].count).assertEqual(3);
    });
  });
}
