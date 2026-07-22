import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { PreferencesCheckInRepo } from '../adapters/PreferencesCheckInRepo';
import { PreferencesThemeRepository } from '../adapters/PreferencesThemeRepository';
import { SkinProviderImpl } from '../adapters/SkinProviderImpl';
import { SoundPlayerImpl } from '../adapters/SoundPlayerImpl';
import { FrequencyPatternEngine } from '../domain/FrequencyPatternEngine';
import { DetectEasterEgg } from '../usecases/DetectEasterEgg';
import { LoadActivity } from '../usecases/LoadActivity';
import { LoadHeatmap } from '../usecases/LoadHeatmap';
import { PlaySound } from '../usecases/PlaySound';
import { ProcessCheckIn } from '../usecases/ProcessCheckIn';
import { RecordCheckIn } from '../usecases/RecordCheckIn';
import { LoadPersistedTheme, SwitchTheme } from '../usecases/ThemeOperations';
import { HeatmapVM } from '../viewmodels/HeatmapVM';

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
    const patternEngine = new FrequencyPatternEngine();
    const skinProvider = new SkinProviderImpl();
    const themeRepo = new PreferencesThemeRepository(this.context);
    const loadHeatmap = new LoadHeatmap(repo);
    const loadActivity = new LoadActivity(repo, patternEngine);
    const viewModel = new HeatmapVM(
      loadHeatmap,
      loadActivity,
      new ProcessCheckIn(
        new DetectEasterEgg(repo, patternEngine),
        new RecordCheckIn(repo),
        loadHeatmap,
        loadActivity,
      ),
      new LoadPersistedTheme(skinProvider, themeRepo),
      new SwitchTheme(skinProvider, themeRepo),
      new PlaySound(new SoundPlayerImpl())
    );
    AppStorage.setOrCreate<HeatmapVM>('heatmapVM', viewModel);

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
