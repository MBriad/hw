import { describe, it, expect } from '@ohos/hypium';
import { CalendarDebugScenario, DebugRuntime } from '../main/ets/debug/DebugRuntime';
import { VMFixture } from './mocks/VMFixture';

export default function debugRuntimeTest() {
  describe('DebugRuntime', () => {
    it('quickTests_call_live_viewmodel_workflows', 0, async () => {
      const fixture = new VMFixture();
      const runtime = new DebugRuntime(fixture.vm);
      const heatmapResult = await runtime.loadHeatmap();
      const activityResult = await runtime.loadActivity();
      expect(heatmapResult.startsWith('OK | cells=')).assertEqual(true);
      expect(activityResult).assertEqual('OK | checkIns=0 | patterns=0');
      expect(fixture.loadHeatmap.capturedYear).assertEqual(2026);
      expect(fixture.loadHeatmap.capturedMonth).assertEqual(7);
      expect(fixture.loadActivity.executeCount).assertEqual(1);
    });

    it('clearRecords_calls_live_clear_api', 0, async () => {
      const fixture = new VMFixture();
      const runtime = new DebugRuntime(fixture.vm);
      fixture.vm.selectDate('2026-07-19');
      const result = await runtime.clearRecords();
      expect(result).assertEqual('OK | records cleared');
      expect(fixture.clear.executeCount).assertEqual(1);
      expect(fixture.vm.selectedDate).assertEqual('');
    });

    it('playEasterEgg_uses_live_feedback_pipeline', 0, () => {
      const fixture = new VMFixture();
      const runtime = new DebugRuntime(fixture.vm);
      runtime.playEasterEgg('particle_sakura', 'anime_sparkle', 'DEBUG // SAKURA SIGNAL');
      expect(fixture.vm.triggeredEgg !== null).assertEqual(true);
      expect(fixture.vm.showParticles).assertEqual(true);
      expect(fixture.vm.showBanner).assertEqual(true);
      expect(fixture.sound.lastPlayed).assertEqual('anime_sparkle');
      if (fixture.vm.triggeredEgg !== null) {
        expect(fixture.vm.triggeredEgg.effectType).assertEqual('particle_sakura');
        expect(fixture.vm.triggeredEgg.quote).assertEqual('DEBUG // SAKURA SIGNAL');
      }
    });

    it('blockedRetrigger_keeps_first_signal', 0, () => {
      const fixture = new VMFixture();
      const runtime = new DebugRuntime(fixture.vm);
      runtime.playBlockedRetrigger();
      expect(fixture.sound.playCount).assertEqual(1);
      if (fixture.vm.triggeredEgg !== null) {
        expect(fixture.vm.triggeredEgg.effectType).assertEqual('particle_dark');
        expect(fixture.vm.triggeredEgg.quote).assertEqual('DEBUG // FIRST SIGNAL');
      }
    });

    it('rapidTaps_does_not_stack_feedback', 0, () => {
      const fixture = new VMFixture();
      const runtime = new DebugRuntime(fixture.vm);
      runtime.playRapidTaps();
      expect(fixture.sound.playCount).assertEqual(1);
      if (fixture.vm.triggeredEgg !== null) {
        expect(fixture.vm.triggeredEgg.effectType).assertEqual('particle_rise');
      }
    });

    it('calendarLab_runs_standard_and_cross_year_workflows', 0, async () => {
      const fixture = new VMFixture();
      const runtime = new DebugRuntime(fixture.vm);
      await fixture.vm.loadMonth(2026, 7);

      const previous = await runtime.runCalendarScenario(CalendarDebugScenario.PREVIOUS_MONTH);
      expect(previous.startsWith('OK | month=2026.06')).assertEqual(true);

      const forwardBoundary = await runtime.runCalendarScenario(CalendarDebugScenario.DECEMBER_TO_JANUARY);
      expect(forwardBoundary.startsWith('OK | month=2027.01')).assertEqual(true);

      const backwardBoundary = await runtime.runCalendarScenario(CalendarDebugScenario.JANUARY_TO_DECEMBER);
      expect(backwardBoundary.startsWith('OK | month=2025.12')).assertEqual(true);
    });
  });
}
