import { describe, it, expect } from '@ohos/hypium';
import { HeatmapVM } from '../main/ets/viewmodels/HeatmapVM';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { SkinProviderImpl } from '../main/ets/adapters/SkinProviderImpl';
import { HeatmapCell } from '../main/ets/domain/Streak';
import { MockLoadHeatmap, MockRecordCheckIn } from './mocks/MockUseCases';

export default function heatmapVMTest() {
  describe('HeatmapVM', () => {

    it('recordCheckIn_delegates_to_usecase', 0, async () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      vm.selectDate('2026-07-19');
      await vm.doCheckIn('Rust学习');

      expect(mockRecord.capturedDate).assertEqual('2026-07-19');
      expect(mockRecord.capturedContent).assertEqual('Rust学习');
    });

    it('switchSkin_updates_currentSkin', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      vm.switchSkin(SkinTheme.MIKU);
      expect(vm.currentSkin).assertEqual(SkinTheme.MIKU);
      expect(vm.currentSkinConfig.primary).assertEqual('#39C5BB');
    });

    it('selectDate_updates_selectedDate', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      vm.selectDate('2026-07-15');
      expect(vm.selectedDate).assertEqual('2026-07-15');
    });

    it('loadMonth_delegates_and_updates_cells', 0, async () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();

      const sampleCells: HeatmapCell[] = [
        { date: '2026-07-01', level: 0 },
        { date: '2026-07-02', level: 1, checkIn: { date: '2026-07-02', content: 'test', timestamp: 1 } },
      ];
      mockLoad.resultCells = sampleCells;

      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);
      await vm.loadMonth(2026, 7);

      expect(mockLoad.capturedYear).assertEqual(2026);
      expect(mockLoad.capturedMonth).assertEqual(7);
      expect(vm.cells.length).assertEqual(2);
    });

    it('doCheckIn_reloads_month_after_save', 0, async () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();

      const afterCells: HeatmapCell[] = [
        { date: '2026-07-19', level: 1, checkIn: { date: '2026-07-19', content: 'Rust', timestamp: 1 } },
      ];
      mockLoad.resultCells = afterCells;

      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);
      vm.selectDate('2026-07-19');
      await vm.doCheckIn('Rust');

      // After doCheckIn, loadMonth should have been called and cells updated
      expect(vm.cells.length).assertEqual(1);
      expect(vm.cells[0].level).assertEqual(1);
    });

    it('default_skin_is_EVA', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      expect(vm.currentSkin).assertEqual(SkinTheme.EVA);
      expect(vm.currentSkinConfig.primary).assertEqual('#FF6B35');
    });

    it('switchSkin_three_times_updates_correctly', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      vm.switchSkin(SkinTheme.MIKU);
      expect(vm.currentSkin).assertEqual(SkinTheme.MIKU);

      vm.switchSkin(SkinTheme.CYBERPUNK);
      expect(vm.currentSkin).assertEqual(SkinTheme.CYBERPUNK);

      vm.switchSkin(SkinTheme.EVA);
      expect(vm.currentSkin).assertEqual(SkinTheme.EVA);
    });
  });
}
