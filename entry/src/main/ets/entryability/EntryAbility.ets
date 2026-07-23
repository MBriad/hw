import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { PreferencesCheckInRepo } from '../adapters/PreferencesCheckInRepo';
import { PreferencesLearnedPatternRepo } from '../adapters/PreferencesLearnedPatternRepo';
import { PreferencesLearningObservationRepo } from '../adapters/PreferencesLearningObservationRepo';
import { StubAiPatternAdvisor } from '../adapters/StubAiPatternAdvisor';
import { FrequencyPatternEngine } from '../adapters/FrequencyPatternEngine';
import { SkinProviderImpl } from '../adapters/SkinProviderImpl';
import { SoundPlayerImpl } from '../adapters/SoundPlayerImpl';
import { LearnedPatternPolicy } from '../domain/LearnedPatternPolicy';
import { ClearCheckIns } from '../usecases/ClearCheckIns';
import { LoadActivity } from '../usecases/LoadActivity';
import { LoadHeatmap } from '../usecases/LoadHeatmap';
import { RecordCheckIn } from '../usecases/RecordCheckIn';
import { ManageLearnedPatterns } from '../usecases/ManageLearnedPatterns';
import { AnalyzePendingObservations } from '../usecases/AnalyzePendingObservations';
import { CalendarVM } from '../viewmodels/CalendarVM';
import { ActivityVM } from '../viewmodels/ActivityVM';
import { ThemeVM } from '../viewmodels/ThemeVM';
import { EasterEggVM } from '../viewmodels/EasterEggVM';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    // === Composition Root — Wire dependencies here (Phase 1.5+) ===
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    const repo = new PreferencesCheckInRepo(this.context);
    const learnedPatternRepo = new PreferencesLearnedPatternRepo(this.context);
    const learningObservationRepo = new PreferencesLearningObservationRepo(this.context);
    const patternEngine = new FrequencyPatternEngine();
    const manageLearnedPatterns = new ManageLearnedPatterns(
      learnedPatternRepo, new LearnedPatternPolicy(), learningObservationRepo);
    const aiAdvisor = new StubAiPatternAdvisor();
    const analyzeUseCase = new AnalyzePendingObservations(manageLearnedPatterns, aiAdvisor);

    // Per-page ViewModels (ISP — split from fat HeatmapVM)
    const calendarVM = new CalendarVM(
      new LoadHeatmap(repo),
      new RecordCheckIn(repo),
      new ClearCheckIns(repo),
      manageLearnedPatterns,
    );
    const activityVM = new ActivityVM(
      new LoadActivity(repo, patternEngine),
      manageLearnedPatterns,
      analyzeUseCase,
    );
    const themeVM = new ThemeVM(
      new SkinProviderImpl(this.context),
    );
    const easterEggVM = new EasterEggVM(
      new SoundPlayerImpl(),
    );

    AppStorage.setOrCreate<CalendarVM>('calendarVM', calendarVM);
    AppStorage.setOrCreate<ActivityVM>('activityVM', activityVM);
    AppStorage.setOrCreate<ThemeVM>('themeVM', themeVM);
    AppStorage.setOrCreate<EasterEggVM>('easterEggVM', easterEggVM);

    windowStage.loadContent('pages/HeatmapPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
