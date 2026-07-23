/**
 * ViewModel: Easter egg display state (banner, particles, sound).
 * @Observed — shared complex component, used by ParticleOverlay and QuoteBanner.
 */
import { EasterEgg } from '../domain/EasterEgg';
import { SoundPlayer } from '../domain/ports/SoundPlayer';

const EGG_DISPLAY_MS = 2800;

@Observed
export class EasterEggVM {
  triggeredEgg: EasterEgg | null = null;
  showParticles: boolean = false;
  showBanner: boolean = false;
  soundFile: string = '';

  private soundPlayer: SoundPlayer;
  private eggRunId: number = 0;

  constructor(soundPlayer: SoundPlayer) {
    this.soundPlayer = soundPlayer;
  }

  present(egg: EasterEgg): void {
    if (this.triggeredEgg === null) {
      this.triggeredEgg = egg;
      this.showParticles = true;
      this.showBanner = true;
      this.soundFile = egg.soundFile;
      this.soundPlayer.play(egg.soundFile);
      const runId = ++this.eggRunId;
      setTimeout(() => {
        if (this.eggRunId === runId) {
          this.dismiss();
        }
      }, EGG_DISPLAY_MS);
    }
  }

  dismiss(): void {
    this.triggeredEgg = null;
    this.showParticles = false;
    this.showBanner = false;
  }
}
