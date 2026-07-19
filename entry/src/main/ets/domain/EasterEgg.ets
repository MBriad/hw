/**
 * Domain entity: keyword-triggered easter egg.
 * Pure interface — zero framework dependencies.
 */

/** A single keyword → easter egg mapping rule */
export interface EasterEggRule {
  /** Array of trigger keywords (case-insensitive match) */
  keywords: string[];
  /** Anime voiceline to display */
  quote: string;
  /** Particle effect type identifier */
  effectType: string;
  /** Sound file name (in resources/rawfile/) */
  soundFile: string;
}

/** Result of matching a keyword against check-in text */
export interface EasterEgg {
  /** The matched keyword */
  keyword: string;
  /** Voiceline text to display */
  quote: string;
  /** Particle effect type */
  effectType: string;
  /** Sound file to play */
  soundFile: string;
}
