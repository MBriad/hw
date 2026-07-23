import { describe, it, expect } from '@ohos/hypium';
import { ActivitySnapshot } from '../main/ets/domain/ActivitySnapshot';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { EasterEgg } from '../main/ets/domain/EasterEgg';
import { HeatmapCell } from '../main/ets/domain/Streak';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { VMFixture } from './mocks/VMFixture';
import { MockPatternLearning } from './mocks/MockUseCases';

export default function heatmapVMTest() {
  describe('CalendarVM', () => {
    it('recordCheckIn_runs_pattern_match_save_and_refresh', 0, async () => {
      const fixture = new VMFixture();
      fixture.calendarVM.selectDate('2026-07-19');
      await fixture.calendarVM.doCheckIn('shader practice');
      const learning = fixture.patternLearning as MockPatternLearning;
      expect(learning.capturedContent).assertEqual('shader practice');
      expect(learning.capturedObservationContent).assertEqual('shader practice');
      expect(learning.capturedObservationDate).assertEqual('2026-07-19');
      expect(fixture.record.capturedDate).assertEqual('2026-07-19');
      expect(fixture.record.capturedContent).assertEqual('shader practice');
    });

    it('dashboard_metrics_are_derived_from_visible_month', 0, async () => {
      const fixture = new VMFixture();
      fixture.loadHeatmap.resultCells = [
        new HeatmapCell('2026-07-01', 1),
        new HeatmapCell('2026-07-02', 1),
        new HeatmapCell('2026-07-03', 0),
        new HeatmapCell('2026-07-04', 1),
        new HeatmapCell('2026-07-05', 1),
        new HeatmapCell('2026-07-06', 1),
      ];
      await fixture.calendarVM.loadMonth(2026, 7);
      expect(fixture.calendarVM.monthCode).assertEqual('2026.07');
      expect(fixture.calendarVM.monthCommitCount).assertEqual(5);
      expect(fixture.calendarVM.longestMonthStreak).assertEqual(3);
    });

    it('month_navigation_moves_within_year_and_clears_selection', 0, async () => {
      const fixture = new VMFixture();
      await fixture.calendarVM.loadMonth(2026, 7);
      fixture.calendarVM.selectDate('2026-07-19');
      await fixture.calendarVM.previousMonth();
      expect(fixture.calendarVM.monthCode).assertEqual('2026.06');
      expect(fixture.calendarVM.selectedDate).assertEqual('');
      await fixture.calendarVM.nextMonth();
      expect(fixture.calendarVM.monthCode).assertEqual('2026.07');
    });

    it('month_navigation_handles_both_year_boundaries', 0, async () => {
      const fixture = new VMFixture();
      await fixture.calendarVM.loadMonth(2026, 12);
      await fixture.calendarVM.nextMonth();
      expect(fixture.calendarVM.monthCode).assertEqual('2027.01');
      expect(fixture.loadHeatmap.capturedYear).assertEqual(2027);
      expect(fixture.loadHeatmap.capturedMonth).assertEqual(1);

      await fixture.calendarVM.previousMonth();
      expect(fixture.calendarVM.monthCode).assertEqual('2026.12');
      await fixture.calendarVM.loadMonth(2026, 1);
      await fixture.calendarVM.previousMonth();
      expect(fixture.calendarVM.monthCode).assertEqual('2025.12');
    });

    it('returnToCurrentMonth_loads_supplied_date_and_selects_today', 0, async () => {
      const fixture = new VMFixture();
      await fixture.calendarVM.loadMonth(2025, 12);
      await fixture.calendarVM.returnToCurrentMonth(new Date(2026, 6, 22));
      expect(fixture.calendarVM.monthCode).assertEqual('2026.07');
      expect(fixture.calendarVM.selectedDate).assertEqual('2026-07-22');
      expect(fixture.calendarVM.isMonthLoading).assertEqual(false);
    });

    it('month_navigation_failure_preserves_visible_state', 0, async () => {
      const fixture = new VMFixture();
      await fixture.calendarVM.loadMonth(2026, 7);
      fixture.calendarVM.selectDate('2026-07-19');
      fixture.loadHeatmap.shouldFail = true;
      let failed = false;
      try {
        await fixture.calendarVM.nextMonth();
      } catch (_error) {
        failed = true;
      }
      expect(failed).assertEqual(true);
      expect(fixture.calendarVM.monthCode).assertEqual('2026.07');
      expect(fixture.calendarVM.selectedDate).assertEqual('2026-07-19');
      expect(fixture.calendarVM.isMonthLoading).assertEqual(false);
    });

    it('doCheckIn_returns_egg_when_pattern_matches', 0, async () => {
      const fixture = new VMFixture();
      const learning = fixture.patternLearning as MockPatternLearning;
      learning.matchResult = new EasterEgg(
        '绘画', 'PATTERN LOCKED // 绘画 x3', 'particle_rise', 'level_up'
      );
      fixture.calendarVM.selectDate('2026-07-19');
      const egg = await fixture.calendarVM.doCheckIn('绘画');
      expect(egg !== null).assertEqual(true);
      if (egg !== null) {
        expect(egg.keyword).assertEqual('绘画');
      }
    });

    it('doCheckIn_returns_null_without_match', 0, async () => {
      const fixture = new VMFixture();
      fixture.calendarVM.selectDate('2026-07-19');
      const egg = await fixture.calendarVM.doCheckIn('ordinary note');
      expect(egg === null).assertEqual(true);
    });

    it('clearAllRecords_clears_and_reloads_month', 0, async () => {
      const fixture = new VMFixture();
      fixture.calendarVM.selectDate('2026-07-19');
      await fixture.calendarVM.loadMonth(2026, 7);
      await fixture.calendarVM.clearAllRecords();
      expect(fixture.clear.executeCount).assertEqual(1);
      expect(fixture.calendarVM.selectedDate).assertEqual('');
      expect(fixture.loadHeatmap.capturedYear).assertEqual(2026);
      expect(fixture.loadHeatmap.capturedMonth).assertEqual(7);
    });
  });

  describe('ActivityVM', () => {
    it('refreshActivity_loads_checkins_and_patterns', 0, async () => {
      const fixture = new VMFixture();
      fixture.loadActivity.result = new ActivitySnapshot([
        new CheckIn('2026-07-01', '绘画', 1)
      ], []);
      await fixture.activityVM.refreshActivity();
      expect(fixture.activityVM.checkIns.length).assertEqual(1);
    });

    it('refreshAll_loads_all_data_streams', 0, async () => {
      const fixture = new VMFixture();
      await fixture.activityVM.refreshAll();
      expect(fixture.loadActivity.executeCount).assertEqual(1);
    });
  });

  describe('ThemeVM', () => {
    it('switchSkin_updates_tokens_and_persists', 0, async () => {
      const fixture = new VMFixture();
      await fixture.themeVM.switchSkin(SkinTheme.DARK);
      expect(fixture.themeVM.currentSkin).assertEqual(SkinTheme.DARK);
      expect(fixture.themeVM.currentTokens.brandPrimary).assertEqual('#3B82F6');
      expect(fixture.skin.persistedTheme).assertEqual(SkinTheme.DARK);
      expect(fixture.skin.persistedCount).assertEqual(1);
    });

    it('initialize_restores_persisted_theme', 0, async () => {
      const fixture = new VMFixture();
      fixture.skin.persistedTheme = SkinTheme.PINK;
      await fixture.themeVM.initialize();
      expect(fixture.themeVM.currentSkin).assertEqual(SkinTheme.PINK);
      expect(fixture.themeVM.currentTokens.brandPrimary).assertEqual('#FF4D94');
    });
  });

  describe('EasterEggVM', () => {
    it('present_shows_feedback_and_plays_sound', 0, () => {
      const fixture = new VMFixture();
      const egg = new EasterEgg('绘画', 'x3', 'particle_rise', 'level_up');
      fixture.easterEggVM.present(egg);
      expect(fixture.easterEggVM.triggeredEgg !== null).assertEqual(true);
      expect(fixture.easterEggVM.showParticles).assertEqual(true);
      expect(fixture.easterEggVM.showBanner).assertEqual(true);
      expect(fixture.sound.lastPlayed).assertEqual('level_up');
    });

    it('present_does_not_stack_and_dismiss_clears', 0, () => {
      const fixture = new VMFixture();
      const egg = new EasterEgg('绘画', 'x3', 'particle_rise', 'level_up');
      fixture.easterEggVM.present(egg);
      fixture.easterEggVM.present(egg);
      expect(fixture.sound.playCount).assertEqual(1);
      fixture.easterEggVM.dismiss();
      expect(fixture.easterEggVM.triggeredEgg === null).assertEqual(true);
      expect(fixture.easterEggVM.showParticles).assertEqual(false);
      expect(fixture.easterEggVM.showBanner).assertEqual(false);
    });
  });
}
