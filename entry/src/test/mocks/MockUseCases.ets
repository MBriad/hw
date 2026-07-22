import { HeatmapCell } from '../../main/ets/domain/Streak';
import { ActivitySnapshot } from '../../main/ets/domain/ActivitySnapshot';
import { EasterEgg } from '../../main/ets/domain/EasterEgg';
import { SkinTheme, DesignTokens, ThemePalette, ThemeResult } from '../../main/ets/domain/SkinTheme';
import { IDetectEasterEgg, ILoadActivity, IPlaySound } from '../../main/ets/domain/ports/ActivityUseCases';
import { CheckInResult } from '../../main/ets/domain/CheckInResult';
import { ILoadHeatmap, IRecordCheckIn } from '../../main/ets/domain/ports/HeatmapUseCases';
import { IProcessCheckIn } from '../../main/ets/domain/ports/CheckInUseCase';
import { ILoadPersistedTheme, ISwitchTheme } from '../../main/ets/domain/ports/ThemeUseCases';

/**
 * Mock usecases for ViewModel testing.
 * Implements the same interfaces as real usecases (DIP).
 */
export class MockLoadHeatmap implements ILoadHeatmap {
  public capturedYear: number = 0;
  public capturedMonth: number = 0;
  public resultCells: HeatmapCell[] = [];

  async execute(year: number, month: number): Promise<HeatmapCell[]> {
    this.capturedYear = year;
    this.capturedMonth = month;
    return this.resultCells;
  }
}

export class MockRecordCheckIn implements IRecordCheckIn {
  public capturedDate: string = '';
  public capturedContent: string = '';

  async execute(date: string, content: string): Promise<void> {
    this.capturedDate = date;
    this.capturedContent = content;
  }
}

export class MockLoadActivity implements ILoadActivity {
  public result: ActivitySnapshot = new ActivitySnapshot([], []);
  public executeCount: number = 0;

  async execute(): Promise<ActivitySnapshot> {
    this.executeCount++;
    return this.result;
  }
}

export class MockDetectEasterEgg implements IDetectEasterEgg {
  public result: EasterEgg | null = null;
  public capturedDate: string = '';
  public capturedContent: string = '';

  async execute(date: string, content: string): Promise<EasterEgg | null> {
    this.capturedDate = date;
    this.capturedContent = content;
    return this.result;
  }
}

export class MockLoadPersistedTheme implements ILoadPersistedTheme {
  public result: ThemeResult = new ThemeResult(SkinTheme.LIGHT, ThemePalette[SkinTheme.LIGHT]);

  async execute(): Promise<ThemeResult> {
    return this.result;
  }
}

export class MockSwitchTheme implements ISwitchTheme {
  public capturedTheme: SkinTheme = SkinTheme.LIGHT;
  public resultTokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];

  async execute(theme: SkinTheme): Promise<DesignTokens> {
    this.capturedTheme = theme;
    return this.resultTokens;
  }
}

export class MockPlaySound implements IPlaySound {
  public lastSoundFile: string = '';
  public playCount: number = 0;

  async execute(soundFile: string): Promise<boolean> {
    this.lastSoundFile = soundFile;
    this.playCount++;
    return true;
  }
}

export class MockProcessCheckIn implements IProcessCheckIn {
  public capturedDate: string = '';
  public capturedContent: string = '';
  public result: CheckInResult = new CheckInResult([], [], [], null);

  async execute(date: string, content: string, _year: number, _month: number): Promise<CheckInResult> {
    this.capturedDate = date;
    this.capturedContent = content;
    return this.result;
  }
}
