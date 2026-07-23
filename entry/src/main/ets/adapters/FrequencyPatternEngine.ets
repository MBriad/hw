import { CheckIn } from '../domain/CheckIn';
import { UsagePattern } from '../domain/EasterEgg';
import { UsagePatternEngine } from '../domain/ports/UsagePatternEngine';

const MILESTONES: number[] = [3, 7, 14, 30];

/** Local adapter that summarizes repeated terms without triggering feedback. */
export class FrequencyPatternEngine implements UsagePatternEngine {
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
}
