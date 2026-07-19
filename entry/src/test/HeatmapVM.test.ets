import { describe, it, expect } from '@ohos/hypium';
import { HeatmapVM } from '../main/ets/viewmodels/HeatmapVM';
import { SkinTheme, DesignTokens } from '../main/ets/domain/SkinTheme';
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

    it('switchSkin_updates_currentTokens', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      vm.switchSkin(SkinTheme.DARK);
      expect(vm.currentSkin).assertEqual(SkinTheme.DARK);
      expect(vm.currentTokens.brandPrimary).assertEqual('#3B82F6');
      expect(vm.currentTokens.bgBase).assertEqual('#080C10');
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

      expect(vm.cells.length).assertEqual(1);
      expect(vm.cells[0].level).assertEqual(1);
    });

    it('default_skin_is_LIGHT', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      expect(vm.currentSkin).assertEqual(SkinTheme.LIGHT);
      expect(vm.currentTokens.brandPrimary).assertEqual('#0EA5E9');
    });

    it('switchSkin_all_4_themes_work', 0, () => {
      const mockLoad = new MockLoadHeatmap();
      const mockRecord = new MockRecordCheckIn();
      const skinProvider = new SkinProviderImpl();
      const vm = new HeatmapVM(mockLoad, mockRecord, skinProvider);

      vm.switchSkin(SkinTheme.DARK);
      expect(vm.currentSkin).assertEqual(SkinTheme.DARK);

      vm.switchSkin(SkinTheme.PINK);
      expect(vm.currentSkin).assertEqual(SkinTheme.PINK);

      vm.switchSkin(SkinTheme.PASTEL);
      expect(vm.currentSkin).assertEqual(SkinTheme.PASTEL);

      vm.switchSkin(SkinTheme.LIGHT);
      expect(vm.currentSkin).assertEqual(SkinTheme.LIGHT);
    });
  });
}
