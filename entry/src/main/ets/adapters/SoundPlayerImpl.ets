/**
 * Adapter: Sound effect playback via @ohos.multimedia.audio.
 * Falls back to no-op if audio unavailable (dev mode).
 */
import { SoundPlayer } from '../domain/ports/SoundPlayer';

export class SoundPlayerImpl implements SoundPlayer {
  async play(_fileName: string): Promise<boolean> {
    // TODO: Integrate @ohos.multimedia.audio.AVPlayer when audio files exist
    // For now: silent no-op — sound files are placeholder until Phase 2.4
    return true;
  }
}
