/**
 * Port: Keyword-to-easter-egg matching.
 * Pure interface — zero framework dependencies.
 */
import { EasterEgg } from '../EasterEgg';

export interface KeywordMatcher {
  /**
   * Match check-in text against known keyword rules.
   * Returns the first matching easter egg, or null if no match.
   */
  match(text: string): EasterEgg | null;
}
