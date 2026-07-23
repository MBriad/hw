import { SkinProviderImpl } from '../../main/ets/adapters/SkinProviderImpl';
import { SoundPlayer } from '../../main/ets/domain/ports/SoundPlayer';
import { HeatmapVM } from '../../main/ets/viewmodels/HeatmapVM';
import { PatternLearningApi } from '../../main/ets/domain/ports/PatternLearningApi';
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

export class VMFixture {
  loadHeatmap: MockLoadHeatmap = new MockLoadHeatmap();
  record: MockRecordCheckIn = new MockRecordCheckIn();
  clear: MockClearCheckIns = new MockClearCheckIns();
  loadActivity: MockLoadActivity = new MockLoadActivity();
  patternLearning: PatternLearningApi;
  sound: MockSoundPlayer = new MockSoundPlayer();
  vm: HeatmapVM;

  constructor(patternLearning?: PatternLearningApi) {
    this.patternLearning = patternLearning ?? new MockPatternLearning();
    this.vm = new HeatmapVM(
      this.loadHeatmap,
      this.record,
      this.clear,
      this.loadActivity,
      this.patternLearning,
      new SkinProviderImpl(),
      this.sound
    );
  }
}
