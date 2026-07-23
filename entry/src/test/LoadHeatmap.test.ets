import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { LoadHeatmap } from '../main/ets/usecases/LoadHeatmap';
import { MockCheckInRepo } from './mocks/MockCheckInRepo';

export default function loadHeatmapTest() {
  describe('LoadHeatmap', () => {

    it('returns_31_cells_for_july', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);
      expect(cells.length).assertEqual(31);
    });

    it('returns_30_cells_for_june', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 6);
      expect(cells.length).assertEqual(30);
    });

    it('returns_28_cells_for_february_2026', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 2);
      expect(cells.length).assertEqual(28);
    });

    it('marks_checked_dates_with_level_1', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const sampleCheckIn = new CheckIn('2026-07-15', 'test', 1);
      const samples: CheckIn[] = [sampleCheckIn];
      mockRepo.loadByMonthResult = samples;

      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);

      let foundChecked = false;
      for (let i = 0; i < cells.length; i++) {
        if (cells[i].date === '2026-07-15') {
          foundChecked = true;
          expect(cells[i].level).assertEqual(1);
          expect(cells[i].checkIn!.content).assertEqual('test');
        }
      }
      expect(foundChecked).assertEqual(true);
    });

    it('empty_dates_have_level_0_and_no_checkin', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);

      let emptyCell = cells[0]; // 2026-07-01
      expect(emptyCell.level).assertEqual(0);
      let noCheckIn: boolean = (emptyCell.checkIn === undefined);
      expect(noCheckIn).assertEqual(true);
    });

    it('first_and_last_cell_dates_are_correct', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);

      expect(cells[0].date).assertEqual('2026-07-01');
      expect(cells[30].date).assertEqual('2026-07-31');
    });

    it('all_cells_level_0_when_no_checkins', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);

      let allZero = true;
      for (let i = 0; i < cells.length; i++) {
        if (cells[i].level !== 0) {
          allZero = false;
        }
      }
      expect(allZero).assertEqual(true);
    });
  });
}
