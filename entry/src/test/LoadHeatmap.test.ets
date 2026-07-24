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

    it('aggregates_same_day_content_and_keeps_latest_checkin', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      mockRepo.loadByMonthResult = [
        new CheckIn('2026-07-15', '1234567890123456789', 1),
        new CheckIn('2026-07-15', '12345678901234567890', 2),
      ];

      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);
      const cell = cells[14];

      expect(cell.level).assertEqual(2);
      expect(cell.checkIn!.content).assertEqual('12345678901234567890');
    });

    it('maps_character_thresholds_to_progressive_levels', 0, async () => {
      const mockRepo = new MockCheckInRepo();
      mockRepo.loadByMonthResult = [
        new CheckIn('2026-07-01', 'a', 1),
        new CheckIn('2026-07-02', '12345678901234567890', 2),
        new CheckIn('2026-07-03', '12345678901234567890123456789012345678901234567890', 3),
        new CheckIn('2026-07-04', '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890', 4),
        new CheckIn('2026-07-05', '  1234567890123456789  ', 5),
      ];

      const usecase = new LoadHeatmap(mockRepo);
      const cells = await usecase.execute(2026, 7);

      expect(cells[0].level).assertEqual(1);
      expect(cells[1].level).assertEqual(2);
      expect(cells[2].level).assertEqual(3);
      expect(cells[3].level).assertEqual(4);
      expect(cells[4].level).assertEqual(1);
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
