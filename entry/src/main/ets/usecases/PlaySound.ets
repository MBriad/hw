import { SoundPlayer } from '../domain/ports/SoundPlayer';
import { IPlaySound } from '../domain/ports/ActivityUseCases';

export class PlaySound implements IPlaySound {
  private soundPlayer: SoundPlayer;

  constructor(soundPlayer: SoundPlayer) {
    this.soundPlayer = soundPlayer;
  }

  async execute(soundFile: string): Promise<boolean> {
    return this.soundPlayer.play(soundFile);
  }
}
