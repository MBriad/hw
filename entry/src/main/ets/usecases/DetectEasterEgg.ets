/**
 * UseCase: Detect easter egg trigger from check-in text.
 * Depends on KeywordMatcher (port).
 */
import { EasterEgg } from '../domain/EasterEgg';
import { KeywordMatcher } from '../domain/ports/KeywordMatcher';

export class DetectEasterEgg {
  private matcher: KeywordMatcher;

  constructor(matcher: KeywordMatcher) {
    this.matcher = matcher;
  }

  execute(text: string): EasterEgg | null {
    if (text.trim().length === 0) {
      return null;
    }
    return this.matcher.match(text);
  }
}
