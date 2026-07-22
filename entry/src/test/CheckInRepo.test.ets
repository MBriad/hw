import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { CheckInRepository } from '../main/ets/domain/ports/CheckInRepository';

/**
 * In-memory mock implementation of CheckInRepository for testing.
 * Bypasses @ohos.data.preferences — tests the port contract,
 * not the framework integration (that requires device/emulator).
 */
class MockCheckInRepo implements CheckInRepository {
  private store: Map<string, CheckIn> = new Map();

  async save(checkIn: CheckIn): Promise<void> {
    this.store.set(checkIn.date, checkIn);
  }

  async loadAll(): Promise<CheckIn[]> {
    const result: CheckIn[] = [];
    const keys = Array.from(this.store.keys());
    for (let i = 0; i < keys.length; i++) {
      const item = this.store.get(keys[i]);
      if (item !== undefined) {
        result.push(item);
      }
    }
    return result;
  }

  async loadByMonth(year: number, month: number): Promise<CheckIn[]> {
    const all = await this.loadAll();
    const prefix = `${year}-${String(month).padStart(2, '0')}`;
    const result: CheckIn[] = [];
    for (let i = 0; i < all.length; i++) {
      if (all[i].date.startsWith(prefix)) {
        result.push(all[i]);
      }
    }
    return result;
  }

  async clear(): Promise<void> {
    this.store.clear();
  }
}

export default function checkInRepoTest() {
  describe('CheckInRepository', () => {

    it('save_and_loadAll_round_trip', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save({ date: '2026-07-19', content: 'Rust学习', timestamp: 1 });
      const all = await repo.loadAll();
      expect(all.length).assertEqual(1);
      expect(all[0].date).assertEqual('2026-07-19');
      expect(all[0].content).assertEqual('Rust学习');
    });

    it('save_updates_existing_date', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save({ date: '2026-07-19', content: 'first', timestamp: 1 });
      await repo.save({ date: '2026-07-19', content: 'updated', timestamp: 2 });
      const all = await repo.loadAll();
      expect(all.length).assertEqual(1);
      expect(all[0].content).assertEqual('updated');
    });

    it('loadAll_returns_empty_when_no_data', 0, async () => {
      const repo = new MockCheckInRepo();
      const all = await repo.loadAll();
      expect(all.length).assertEqual(0);
    });

    it('loadByMonth_filters_correctly', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save({ date: '2026-07-15', content: 'July 15', timestamp: 1 });
      await repo.save({ date: '2026-07-20', content: 'July 20', timestamp: 2 });
      await repo.save({ date: '2026-08-01', content: 'August 1', timestamp: 3 });
      const july = await repo.loadByMonth(2026, 7);
      expect(july.length).assertEqual(2);
      const august = await repo.loadByMonth(2026, 8);
      expect(august.length).assertEqual(1);
      expect(august[0].date).assertEqual('2026-08-01');
    });

    it('loadByMonth_returns_empty_for_no_match', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save({ date: '2026-07-15', content: 'test', timestamp: 1 });
      const january = await repo.loadByMonth(2026, 1);
      expect(january.length).assertEqual(0);
    });

    it('multiple_checkins_different_dates', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save({ date: '2026-07-10', content: 'A', timestamp: 1 });
      await repo.save({ date: '2026-07-11', content: 'B', timestamp: 2 });
      await repo.save({ date: '2026-07-12', content: 'C', timestamp: 3 });
      const all = await repo.loadAll();
      expect(all.length).assertEqual(3);
    });

    it('clear_removes_all_checkins', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save({ date: '2026-07-10', content: 'A', timestamp: 1 });
      await repo.save({ date: '2026-08-11', content: 'B', timestamp: 2 });
      await repo.clear();
      expect((await repo.loadAll()).length).assertEqual(0);
      expect((await repo.loadByMonth(2026, 7)).length).assertEqual(0);
    });
  });
}
