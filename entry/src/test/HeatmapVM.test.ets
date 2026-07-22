import { describe, it, expect } from '@ohos/hypium';
import { ActivitySnapshot } from '../main/ets/domain/ActivitySnapshot';
import { CheckInResult } from '../main/ets/domain/CheckInResult';
import { HeatmapCell } from '../main/ets/domain/Streak';
import { SkinTheme, ThemePalette, ThemeResult } from '../main/ets/domain/SkinTheme';
import { HeatmapVM } from '../main/ets/viewmodels/HeatmapVM';
import {
  MockLoadActivity,
  MockLoadHeatmap,
  MockLoadPersistedTheme,
  MockPlaySound,
  MockProcessCheckIn,
  MockSwitchTheme,
} from './mocks/MockUseCases';

class TestHeatmapCell implements HeatmapCell {
  date: string;
  level: number;

  constructor(date: string, level: number) {
    this.date = date;
    this.level = level;
  }
}

class VMFixture {
  loadHeatmap: MockLoadHeatmap = new MockLoadHeatmap();
  loadActivity: MockLoadActivity = new MockLoadActivity();
  processCheckIn: MockProcessCheckIn = new MockProcessCheckIn();
  loadPersistedTheme: MockLoadPersistedTheme = new MockLoadPersistedTheme();
  switchTheme: MockSwitchTheme = new MockSwitchTheme();
  playSound: MockPlaySound = new MockPlaySound();
  vm: HeatmapVM = new HeatmapVM(
    this.loadHeatmap,
    this.loadActivity,
    this.processCheckIn,
    this.loadPersistedTheme,
    this.switchTheme,
    this.playSound
  );
}

export default function heatmapVMTest() {
  describe('HeatmapVM', () => {
    it('recordCheckIn_runs_detector_save_and_refresh', 0, async () => {
      const fixture = new VMFixture();
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('shader practice');
      expect(fixture.processCheckIn.capturedDate).assertEqual('2026-07-19');
      expect(fixture.processCheckIn.capturedContent).assertEqual('shader practice');
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
      fixture.processCheckIn.result = new CheckInResult(
        [], [], [], {
          keyword: '绘画', quote: 'PATTERN LOCKED // 绘画 x3',
          effectType: 'particle_rise', soundFile: 'level_up'
        }
      );
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('绘画');
      expect(fixture.vm.triggeredEgg !== null).assertEqual(true);
      expect(fixture.vm.showParticles).assertEqual(true);
      expect(fixture.vm.showBanner).assertEqual(true);
      expect(fixture.playSound.lastSoundFile).assertEqual('level_up');
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
      fixture.processCheckIn.result = new CheckInResult(
        [], [], [], {
          keyword: '绘画', quote: 'x3', effectType: 'particle_rise', soundFile: 'level_up'
        }
      );
      fixture.vm.selectDate('2026-07-19');
      await fixture.vm.doCheckIn('绘画');
      await fixture.vm.doCheckIn('绘画');
      expect(fixture.playSound.playCount).assertEqual(1);
      fixture.vm.dismissEgg();
      expect(fixture.vm.triggeredEgg === null).assertEqual(true);
      expect(fixture.vm.showParticles).assertEqual(false);
      expect(fixture.vm.showBanner).assertEqual(false);
    });

    it('loadPersistedSkin_restores_saved_theme', 0, async () => {
      const fixture = new VMFixture();
      fixture.loadPersistedTheme.result = new ThemeResult(SkinTheme.PINK, ThemePalette[SkinTheme.PINK]);
      await fixture.vm.loadPersistedSkin();
      expect(fixture.vm.currentSkin).assertEqual(SkinTheme.PINK);
      expect(fixture.vm.currentTokens.brandPrimary).assertEqual('#FF4D94');
    });

    it('switchSkin_updates_tokens_and_persists_theme', 0, async () => {
      const fixture = new VMFixture();
      fixture.switchTheme.resultTokens = ThemePalette[SkinTheme.DARK];
      const pendingSwitch = fixture.vm.switchSkin(SkinTheme.DARK);
      expect(fixture.vm.currentSkin).assertEqual(SkinTheme.DARK);
      expect(fixture.vm.currentTokens.brandPrimary).assertEqual('#3B82F6');
      await pendingSwitch;
      expect(fixture.vm.currentSkin).assertEqual(SkinTheme.DARK);
      expect(fixture.vm.currentTokens.brandPrimary).assertEqual('#3B82F6');
      expect(fixture.switchTheme.capturedTheme).assertEqual(SkinTheme.DARK);
    });
  });
}
