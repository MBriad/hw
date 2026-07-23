/** Domain entities for usage-driven feedback. Pure ArkTS. */

/** Result of matching a learned pattern against check-in text. */
export class EasterEgg {
  keyword: string;
  quote: string;
  effectType: string;
  soundFile: string;

  constructor(keyword: string, quote: string, effectType: string, soundFile: string) {
    this.keyword = keyword;
    this.quote = quote;
    this.effectType = effectType;
    this.soundFile = soundFile;
  }
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
