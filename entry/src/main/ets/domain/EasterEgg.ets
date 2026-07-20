/** Domain entities for usage-driven feedback. Pure ArkTS. */

/** Result of matching a keyword against check-in text */
export interface EasterEgg {
  /** The user-derived pattern that reached a milestone. */
  keyword: string;
  /** Feedback text to display. */
  quote: string;
  /** Particle effect preset. */
  effectType: string;
  /** Synthesized sound preset. */
  soundFile: string;
}

export class UsagePattern {
  term: string;
  count: number;
  nextMilestone: number;

  constructor(term: string, count: number, nextMilestone: number) {
    this.term = term;
    this.count = count;
    this.nextMilestone = nextMilestone;
  }
}
