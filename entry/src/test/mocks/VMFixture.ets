import { DesignTokens, SkinTheme, ThemePalette } from '../../main/ets/domain/SkinTheme';
import { SkinProvider } from '../../main/ets/domain/ports/SkinProvider';
import { SoundPlayer } from '../../main/ets/domain/ports/SoundPlayer';
import { PatternLearningApi } from '../../main/ets/domain/ports/PatternLearningApi';
import { CalendarVM } from '../../main/ets/viewmodels/CalendarVM';
import { ActivityVM } from '../../main/ets/viewmodels/ActivityVM';
import { ThemeVM } from '../../main/ets/viewmodels/ThemeVM';
import { EasterEggVM } from '../../main/ets/viewmodels/EasterEggVM';
import {
  MockClearCheckIns,
  MockLoadActivity,
  MockLoadHeatmap,
  MockPatternLearning,
  MockRecordCheckIn,
} from './MockUseCases';

export class MockSoundPlayer implements SoundPlayer {
  public lastPlayed: string = '';
  public playCount: number = 0;

  async play(fileName: string): Promise<boolean> {
    this.lastPlayed = fileName;
    this.playCount++;
    return true;
  }
}

export class MockSkinProvider implements SkinProvider {
  persistedTheme: SkinTheme = SkinTheme.LIGHT;
  persistedCount: number = 0;

  getTokens(id: SkinTheme): DesignTokens {
    return ThemePalette[id];
  }

  listThemes(): SkinTheme[] {
    return [SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL];
  }

  async loadPersisted(): Promise<SkinTheme> {
    return this.persistedTheme;
  }

  async persist(id: SkinTheme): Promise<void> {
    this.persistedTheme = id;
    this.persistedCount++;
  }
}

export class VMFixture {
  loadHeatmap: MockLoadHeatmap = new MockLoadHeatmap();
  record: MockRecordCheckIn = new MockRecordCheckIn();
  clear: MockClearCheckIns = new MockClearCheckIns();
  loadActivity: MockLoadActivity = new MockLoadActivity();
  patternLearning: PatternLearningApi;
  skin: MockSkinProvider = new MockSkinProvider();
  sound: MockSoundPlayer = new MockSoundPlayer();
  calendarVM: CalendarVM;
  activityVM: ActivityVM;
  themeVM: ThemeVM;
  easterEggVM: EasterEggVM;

  constructor(patternLearning?: PatternLearningApi) {
    this.patternLearning = patternLearning ?? new MockPatternLearning();
    this.calendarVM = new CalendarVM(
      this.loadHeatmap,
      this.record,
      this.clear,
      this.patternLearning,
    );
    this.activityVM = new ActivityVM(
      this.loadActivity,
      this.patternLearning,
    );
    this.themeVM = new ThemeVM(
      this.skin,
    );
    this.easterEggVM = new EasterEggVM(
      this.sound,
    );
  }
}
