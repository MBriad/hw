import { describe, it, expect } from '@ohos/hypium';
import { ActivitySnapshot } from '../main/ets/domain/ActivitySnapshot';
import { HeatmapCell } from '../main/ets/domain/Streak';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { VMFixture } from './mocks/VMFixture';

class TestHeatmapCell implements HeatmapCell {
  date: string;
  level: number;

  constructor(date: string, level: number) {
    this.date = date;
    this.level = level;
  }
}

export default function heatmapVMTest() {
  describe('HeatmapVM', () => {
    it('recordCheckIn_runs_detector_save_and_refresh', 0, async () => {
      const fixture = new VMFixture();
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('shader practice');
      expect(fixture.detect.capturedDate).assertEqual('2026-07-19');
      expect(fixture.detect.capturedContent).assertEqual('shader practice');
      expect(fixture.record.capturedDate).assertEqual('2026-07-19');
      expect(fixture.record.capturedContent).assertEqual('shader practice');
      expect(fixture.loadActivity.executeCount).assertEqual(1);
    });

    it('initialize_loads_month_and_activity', 0, async () => {
      const fixture = new VMFixture();
      fixture.loadActivity.result = new ActivitySnapshot([
        { date: '2026-07-01', content: '绘画', timestamp: 1 }
      ], []);
      await fixture.vm.initialize(2026, 7);
      expect(fixture.loadHeatmap.capturedYear).assertEqual(2026);
      expect(fixture.loadHeatmap.capturedMonth).assertEqual(7);
      expect(fixture.vm.totalCommitCount).assertEqual(1);
    });

    it('dashboard_metrics_are_derived_from_visible_month', 0, async () => {
      const fixture = new VMFixture();
      fixture.loadHeatmap.resultCells = [
        new TestHeatmapCell('2026-07-01', 1),
        new TestHeatmapCell('2026-07-02', 1),
        new TestHeatmapCell('2026-07-03', 0),
        new TestHeatmapCell('2026-07-04', 1),
        new TestHeatmapCell('2026-07-05', 1),
        new TestHeatmapCell('2026-07-06', 1),
      ];
      await fixture.vm.loadMonth(2026, 7);
      expect(fixture.vm.monthCode).assertEqual('2026.07');
      expect(fixture.vm.monthCommitCount).assertEqual(5);
      expect(fixture.vm.longestMonthStreak).assertEqual(3);
    });

    it('doCheckIn_shows_usage_milestone_feedback', 0, async () => {
      const fixture = new VMFixture();
      fixture.detect.result = {
        keyword: '绘画', quote: 'PATTERN LOCKED // 绘画 x3',
        effectType: 'particle_rise', soundFile: 'level_up'
      };
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('绘画');
      expect(fixture.vm.triggeredEgg !== null).assertEqual(true);
      expect(fixture.vm.showParticles).assertEqual(true);
      expect(fixture.vm.showBanner).assertEqual(true);
      expect(fixture.sound.lastPlayed).assertEqual('level_up');
    });

    it('doCheckIn_has_no_feedback_without_milestone', 0, async () => {
      const fixture = new VMFixture();
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('ordinary note');
      expect(fixture.vm.triggeredEgg === null).assertEqual(true);
      expect(fixture.vm.showParticles).assertEqual(false);
    });

    it('active_feedback_does_not_stack_and_can_be_dismissed', 0, async () => {
      const fixture = new VMFixture();
      fixture.detect.result = {
        keyword: '绘画', quote: 'x3', effectType: 'particle_rise', soundFile: 'level_up'
      };
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('绘画');
      await fixture.vm.doCheckIn('绘画');
      expect(fixture.sound.playCount).assertEqual(1);
      fixture.vm.dismissEgg();
      expect(fixture.vm.triggeredEgg === null).assertEqual(true);
      expect(fixture.vm.showParticles).assertEqual(false);
      expect(fixture.vm.showBanner).assertEqual(false);
    });

    it('switchSkin_updates_currentTokens', 0, () => {
      const fixture = new VMFixture();
      fixture.vm.switchSkin(SkinTheme.DARK);
      expect(fixture.vm.currentSkin).assertEqual(SkinTheme.DARK);
      expect(fixture.vm.currentTokens.brandPrimary).assertEqual('#3B82F6');
    });

    it('clearAllRecords_clears_and_refreshes_visible_state', 0, async () => {
      const fixture = new VMFixture();
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.loadMonth(2026, 7);
      await fixture.vm.clearAllRecords();
      expect(fixture.clear.executeCount).assertEqual(1);
      expect(fixture.vm.selectedDate).assertEqual('');
      expect(fixture.loadHeatmap.capturedYear).assertEqual(2026);
      expect(fixture.loadHeatmap.capturedMonth).assertEqual(7);
      expect(fixture.loadActivity.executeCount).assertEqual(1);
    });
  });
}
