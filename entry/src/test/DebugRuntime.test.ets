import { describe, it, expect } from '@ohos/hypium';
import { CalendarDebugScenario, DebugRuntime, PatternDebugScenario } from '../main/ets/debug/DebugRuntime';
import { LearnedPatternPolicy } from '../main/ets/domain/LearnedPatternPolicy';
import { ManageLearnedPatterns } from '../main/ets/usecases/ManageLearnedPatterns';
import { MockLearnedPatternRepo } from './mocks/MockLearnedPatternRepo';
import { MockLearningObservationRepo } from './mocks/MockLearningObservationRepo';
import { VMFixture } from './mocks/VMFixture';
import { MockPatternLearning } from './mocks/MockUseCases';

function makeRuntime(fixture: VMFixture): DebugRuntime {
  return new DebugRuntime(fixture.calendarVM, fixture.activityVM, fixture.easterEggVM);
}

export default function debugRuntimeTest() {
  describe('DebugRuntime', () => {
    it('quickTests_call_live_viewmodel_workflows', 0, async () => {
      const fixture = new VMFixture();
      const runtime = makeRuntime(fixture);
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
      const runtime = makeRuntime(fixture);
      fixture.calendarVM.selectDate('2026-07-19');
      const result = await runtime.clearRecords();
      expect(result).assertEqual('OK | records cleared');
      expect(fixture.clear.executeCount).assertEqual(1);
      expect(fixture.calendarVM.selectedDate).assertEqual('');
    });

    it('playEasterEgg_uses_live_feedback_pipeline', 0, () => {
      const fixture = new VMFixture();
      const runtime = makeRuntime(fixture);
      runtime.playEasterEgg('particle_sakura', 'anime_sparkle', 'DEBUG // SAKURA SIGNAL');
      expect(fixture.easterEggVM.triggeredEgg !== null).assertEqual(true);
      expect(fixture.easterEggVM.showParticles).assertEqual(true);
      expect(fixture.easterEggVM.showBanner).assertEqual(true);
      expect(fixture.sound.lastPlayed).assertEqual('anime_sparkle');
      if (fixture.easterEggVM.triggeredEgg !== null) {
        expect(fixture.easterEggVM.triggeredEgg.effectType).assertEqual('particle_sakura');
        expect(fixture.easterEggVM.triggeredEgg.quote).assertEqual('DEBUG // SAKURA SIGNAL');
      }
    });

    it('blockedRetrigger_keeps_first_signal', 0, () => {
      const fixture = new VMFixture();
      const runtime = makeRuntime(fixture);
      runtime.playBlockedRetrigger();
      expect(fixture.sound.playCount).assertEqual(1);
      if (fixture.easterEggVM.triggeredEgg !== null) {
        expect(fixture.easterEggVM.triggeredEgg.effectType).assertEqual('particle_dark');
        expect(fixture.easterEggVM.triggeredEgg.quote).assertEqual('DEBUG // FIRST SIGNAL');
      }
    });

    it('rapidTaps_does_not_stack_feedback', 0, () => {
      const fixture = new VMFixture();
      const runtime = makeRuntime(fixture);
      runtime.playRapidTaps();
      expect(fixture.sound.playCount).assertEqual(1);
      if (fixture.easterEggVM.triggeredEgg !== null) {
        expect(fixture.easterEggVM.triggeredEgg.effectType).assertEqual('particle_rise');
      }
    });

    it('patternLab_reaches_observing_candidate_and_mature_through_live_usecase', 0, async () => {
      const repo = new MockLearnedPatternRepo();
      const observations = new MockLearningObservationRepo();
      const fixture = new VMFixture(new ManageLearnedPatterns(repo, new LearnedPatternPolicy(), observations));
      const runtime = makeRuntime(fixture);
      expect(await runtime.runPatternScenario(PatternDebugScenario.OBSERVING))
        .assertEqual('OK | stage=OBSERVING | count=1 | days=1');
      expect(await runtime.runPatternScenario(PatternDebugScenario.CANDIDATE))
        .assertEqual('OK | stage=CANDIDATE | count=3 | days=3');
      expect(await runtime.runPatternScenario(PatternDebugScenario.MATURE))
        .assertEqual('OK | stage=MATURE | count=5 | days=5');
    });

    it('patternLab_similar_match_uses_live_feedback_pipeline', 0, async () => {
      const repo = new MockLearnedPatternRepo();
      const observations = new MockLearningObservationRepo();
      const fixture = new VMFixture(new ManageLearnedPatterns(repo, new LearnedPatternPolicy(), observations));
      const runtime = makeRuntime(fixture);
      const result = await runtime.runPatternScenario(PatternDebugScenario.SIMILAR_MATCH);
      expect(result).assertEqual('OK | matched=creative flow');
      expect(fixture.easterEggVM.triggeredEgg !== null).assertEqual(true);
      expect(fixture.sound.lastPlayed).assertEqual('level_up');
    });

    it('patternLab_no_match_cooldown_and_reset_are_real_state_changes', 0, async () => {
      const repo = new MockLearnedPatternRepo();
      const observations = new MockLearningObservationRepo();
      const fixture = new VMFixture(new ManageLearnedPatterns(repo, new LearnedPatternPolicy(), observations));
      const runtime = makeRuntime(fixture);
      fixture.calendarVM.selectDate('2026-07-20');
      await fixture.calendarVM.doCheckIn('captured note');
      const status = await runtime.runPatternScenario(PatternDebugScenario.OBSERVATION_STATUS);
      expect(status).assertEqual('OK | pending=1');
      const noMatch = await runtime.runPatternScenario(PatternDebugScenario.NO_MATCH);
      expect(noMatch).assertEqual('OK | no match | stage=MATURE');
      const cooldown = await runtime.runPatternScenario(PatternDebugScenario.COOLDOWN);
      expect(cooldown.startsWith('OK | stage=COOLDOWN')).assertEqual(true);
      const reset = await runtime.runPatternScenario(PatternDebugScenario.RESET_SAMPLE);
      expect(reset).assertEqual('OK | patterns=0 | pending=0');
      expect(repo.patterns.length).assertEqual(0);
      expect(observations.observations.length).assertEqual(0);
    });

    it('calendarLab_runs_standard_and_cross_year_workflows', 0, async () => {
      const fixture = new VMFixture();
      const runtime = makeRuntime(fixture);
      await fixture.calendarVM.loadMonth(2026, 7);

      const previous = await runtime.runCalendarScenario(CalendarDebugScenario.PREVIOUS_MONTH);
      expect(previous.startsWith('OK | month=2026.06')).assertEqual(true);

      const forwardBoundary = await runtime.runCalendarScenario(CalendarDebugScenario.DECEMBER_TO_JANUARY);
      expect(forwardBoundary.startsWith('OK | month=2027.01')).assertEqual(true);

      const backwardBoundary = await runtime.runCalendarScenario(CalendarDebugScenario.JANUARY_TO_DECEMBER);
      expect(backwardBoundary.startsWith('OK | month=2025.12')).assertEqual(true);
    });
  });
}
