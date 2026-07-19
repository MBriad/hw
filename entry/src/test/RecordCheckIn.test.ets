import { describe, it, expect } from '@ohos/hypium';
import { RecordCheckIn } from '../main/ets/usecases/RecordCheckIn';
import { MockCheckInRepo } from './mocks/MockCheckInRepo';

export default function recordCheckInTest() {
  describe('RecordCheckIn', () => {

    it('calls_repository_save_with_correct_data', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new RecordCheckIn(mockRepo);
      await usecase.execute('2026-07-19', 'Rust学习');

      expect(mockRepo.lastSavedDate).assertEqual('2026-07-19');
      expect(mockRepo.lastSavedContent).assertEqual('Rust学习');
    });

    it('creates_checkin_with_timestamp', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new RecordCheckIn(mockRepo);
      await usecase.execute('2026-07-19', 'test');

      // Timestamp should be a positive number (milliseconds)
      let hasTimestamp: boolean = (mockRepo.lastSavedTimestamp > 0);
      expect(hasTimestamp).assertEqual(true);
    });

    it('preserves_empty_content', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new RecordCheckIn(mockRepo);
      await usecase.execute('2026-07-19', '');

      expect(mockRepo.savedCheckIns.length).assertEqual(1);
      expect(mockRepo.lastSavedContent).assertEqual('');
    });
  });
}
