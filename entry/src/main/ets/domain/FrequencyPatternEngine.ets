import { CheckIn } from './CheckIn';
import { EasterEgg, UsagePattern } from './EasterEgg';
import { UsagePatternEngine } from './ports/UsagePatternEngine';

const MILESTONES: number[] = [3, 7, 14, 30];
const EFFECTS: string[] = [
  'particle_sparkle',
  'particle_dark',
  'particle_bubble',
  'particle_sakura',
  'particle_rise',
  'eva_at_field',
];
const SOUNDS: string[] = [
  'level_up',
  'wind_chime',
  'healing_bell',
  'anime_sparkle',
  'jojo_menace',
  'eva_alert',
];

/**
 * Learns repeated terms locally. There is no built-in trigger vocabulary:
 * feedback fires only when one of the user's own terms reaches a milestone.
 */
export class FrequencyPatternEngine implements UsagePatternEngine {
  evaluate(content: string, history: CheckIn[]): EasterEgg | null {
    const terms = this.extractTerms(content);
    let selectedTerm = '';
    let selectedCount = 0;

    terms.forEach((term: string) => {
      const count = this.countTerm(term, history) + 1;
      if (MILESTONES.includes(count) &&
          (count > selectedCount || (count === selectedCount && term.length > selectedTerm.length))) {
        selectedTerm = term;
        selectedCount = count;
      }
    });

    if (selectedTerm.length === 0) {
      return null;
    }

    const presetIndex = this.stableIndex(selectedTerm, EFFECTS.length);
    return {
      keyword: selectedTerm,
      quote: `PATTERN LOCKED // ${selectedTerm.toUpperCase()} x${selectedCount}`,
      effectType: EFFECTS[presetIndex],
      soundFile: SOUNDS[presetIndex],
    };
  }

  summarize(history: CheckIn[]): UsagePattern[] {
    const counts: Map<string, number> = new Map<string, number>();
    history.forEach((checkIn: CheckIn) => {
      this.extractTerms(checkIn.content).forEach((term: string) => {
        counts.set(term, (counts.get(term) ?? 0) + 1);
      });
    });

    const patterns: UsagePattern[] = [];
    counts.forEach((count: number, term: string) => {
      if (count >= 2) {
        patterns.push(new UsagePattern(term, count, this.nextMilestone(count)));
      }
    });
    patterns.sort((left: UsagePattern, right: UsagePattern) => {
      if (right.count !== left.count) {
        return right.count - left.count;
      }
      return right.term.length - left.term.length;
    });
    return patterns.slice(0, 8);
  }

  private countTerm(term: string, history: CheckIn[]): number {
    let count = 0;
    history.forEach((checkIn: CheckIn) => {
      if (this.extractTerms(checkIn.content).includes(term)) {
        count++;
      }
    });
    return count;
  }

  private extractTerms(content: string): string[] {
    const normalized = content.toLowerCase().trim();
    if (normalized.length === 0) {
      return [];
    }

    const terms: string[] = [];
    if (this.isUseful(normalized)) {
      terms.push(normalized);
    }
    const chunks = normalized.split(/[\s,，。.!！?？;；:：/\\|()[\]{}"'“”‘’]+/);
    chunks.forEach((chunk: string) => {
      if (this.isUseful(chunk) && !terms.includes(chunk)) {
        terms.push(chunk);
      }
    });

    const codeTerms = normalized.match(/[a-z][a-z0-9+#._-]{1,19}/g);
    if (codeTerms !== null) {
      codeTerms.forEach((term: string) => {
        if (this.isUseful(term) && !terms.includes(term)) {
          terms.push(term);
        }
      });
    }
    return terms;
  }

  private isUseful(term: string): boolean {
    if (term.length < 2 || term.length > 24) {
      return false;
    }
    return !/^\d+$/.test(term);
  }

  private nextMilestone(count: number): number {
    for (let i = 0; i < MILESTONES.length; i++) {
      if (MILESTONES[i] > count) {
        return MILESTONES[i];
      }
    }
    return 0;
  }

  private stableIndex(term: string, size: number): number {
    let hash = 0;
    for (let i = 0; i < term.length; i++) {
      hash = (hash * 31 + term.charCodeAt(i)) & 0x7fffffff;
    }
    return hash % size;
  }
}
