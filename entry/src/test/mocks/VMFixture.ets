import { SkinProviderImpl } from '../../main/ets/adapters/SkinProviderImpl';
import { SoundPlayer } from '../../main/ets/domain/ports/SoundPlayer';
import { HeatmapVM } from '../../main/ets/viewmodels/HeatmapVM';
import {
  MockClearCheckIns,
  MockDetectEasterEgg,
  MockLoadActivity,
  MockLoadHeatmap,
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
  detect: MockDetectEasterEgg = new MockDetectEasterEgg();
  sound: MockSoundPlayer = new MockSoundPlayer();
  vm: HeatmapVM = new HeatmapVM(
    this.loadHeatmap,
    this.record,
    this.clear,
    this.loadActivity,
    this.detect,
    new SkinProviderImpl(),
    this.sound
  );
}
