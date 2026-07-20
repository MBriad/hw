import { describe, it, expect } from '@ohos/hypium';
import { SoundPlayer } from '../main/ets/domain/ports/SoundPlayer';

/**
 * Mock SoundPlayer for testing.
 */
class MockSoundPlayer implements SoundPlayer {
  public lastPlayed: string = '';
  public playCount: number = 0;

  async play(fileName: string): Promise<boolean> {
    this.lastPlayed = fileName;
    this.playCount++;
    return true;
  }
}

export default function soundPlayerTest() {
  describe('SoundPlayer', () => {

    it('mock_play_records_file_name', 0, async () => {
      const player = new MockSoundPlayer();
      const result = await player.play('eva_alert');
      expect(result).assertEqual(true);
      expect(player.lastPlayed).assertEqual('eva_alert');
    });

    it('mock_play_counts_calls', 0, async () => {
      const player = new MockSoundPlayer();
      await player.play('wind_chime');
      await player.play('jojo_menace');
      expect(player.playCount).assertEqual(2);
    });

    it('returns_true_on_success', 0, async () => {
      const player = new MockSoundPlayer();
      const result = await player.play('healing_bell');
      expect(result).assertEqual(true);
    });
  });
}
