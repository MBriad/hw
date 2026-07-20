/**
 * Port: Sound effect playback.
 * Pure interface — zero framework dependencies.
 */
export interface SoundPlayer {
  /** Play a sound file by name (without extension). Returns true if played. */
  play(fileName: string): Promise<boolean>;
}
