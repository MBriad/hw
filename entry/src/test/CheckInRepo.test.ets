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
      await repo.save(new CheckIn('2026-07-19', 'Rust学习', 1));
      const all = await repo.loadAll();
      expect(all.length).assertEqual(1);
      expect(all[0].date).assertEqual('2026-07-19');
      expect(all[0].content).assertEqual('Rust学习');
    });

    it('save_updates_existing_date', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save(new CheckIn('2026-07-19', 'first', 1));
      await repo.save(new CheckIn('2026-07-19', 'updated', 2));
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
      await repo.save(new CheckIn('2026-07-15', 'July 15', 1));
      await repo.save(new CheckIn('2026-07-20', 'July 20', 2));
      await repo.save(new CheckIn('2026-08-01', 'August 1', 3));
      const july = await repo.loadByMonth(2026, 7);
      expect(july.length).assertEqual(2);
      const august = await repo.loadByMonth(2026, 8);
      expect(august.length).assertEqual(1);
      expect(august[0].date).assertEqual('2026-08-01');
    });

    it('loadByMonth_returns_empty_for_no_match', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save(new CheckIn('2026-07-15', 'test', 1));
      const january = await repo.loadByMonth(2026, 1);
      expect(january.length).assertEqual(0);
    });

    it('multiple_checkins_different_dates', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save(new CheckIn('2026-07-10', 'A', 1));
      await repo.save(new CheckIn('2026-07-11', 'B', 2));
      await repo.save(new CheckIn('2026-07-12', 'C', 3));
      const all = await repo.loadAll();
      expect(all.length).assertEqual(3);
    });

    it('clear_removes_all_checkins', 0, async () => {
      const repo = new MockCheckInRepo();
      await repo.save(new CheckIn('2026-07-10', 'A', 1));
      await repo.save(new CheckIn('2026-08-11', 'B', 2));
      await repo.clear();
      expect((await repo.loadAll()).length).assertEqual(0);
      expect((await repo.loadByMonth(2026, 7)).length).assertEqual(0);
    });
  });
}
