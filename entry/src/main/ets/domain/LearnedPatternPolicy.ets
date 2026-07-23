import {
  LearnedPattern,
  PatternMatchResult,
  PatternStage,
  PatternSuggestion,
} from './LearnedPattern';

const CANDIDATE_OCCURRENCES = 3;
const CANDIDATE_DATES = 2;
const CANDIDATE_CONFIDENCE = 0.55;
const MATURE_OCCURRENCES = 5;
const MATURE_DATES = 3;
const MATURE_CONFIDENCE = 0.8;
const COOLDOWN_MS = 24 * 60 * 60 * 1000;

export class LearnedPatternPolicy {
  observe(
    existing: LearnedPattern | null,
    suggestion: PatternSuggestion,
    date: string,
    now: number,
  ): LearnedPattern {
    const id = this.normalize(suggestion.topic);
    const pattern = existing === null ? new LearnedPattern(id, suggestion.topic.trim()) : existing;
    pattern.occurrenceCount++;
    if (!pattern.observedDates.includes(date)) {
      pattern.observedDates.push(date);
    }
    pattern.distinctDateCount = pattern.observedDates.length;
    pattern.confidence = Math.max(pattern.confidence, suggestion.confidence);
    pattern.aliases = this.mergeAliases(pattern.aliases, suggestion.aliases);
    pattern.quote = suggestion.quote;
    pattern.effectType = suggestion.effectType;
    pattern.soundFile = suggestion.soundFile;
    pattern.updatedAt = now;
    this.advanceStage(pattern);
    return pattern;
  }

  match(pattern: LearnedPattern, content: string, now: number): PatternMatchResult {
    if (pattern.stage === PatternStage.COOLDOWN && now >= pattern.cooldownUntil) {
      pattern.stage = PatternStage.MATURE;
      pattern.cooldownUntil = 0;
      pattern.updatedAt = now;
    }
    if (pattern.stage !== PatternStage.MATURE || !this.matches(pattern, content)) {
      return new PatternMatchResult(pattern, null);
    }
    pattern.stage = PatternStage.COOLDOWN;
    pattern.cooldownUntil = now + COOLDOWN_MS;
    pattern.lastMatchedAt = now;
    pattern.updatedAt = now;
    return new PatternMatchResult(pattern, {
      keyword: pattern.topic,
      quote: pattern.quote,
      effectType: pattern.effectType,
      soundFile: pattern.soundFile,
    });
  }

  private advanceStage(pattern: LearnedPattern): void {
    if (pattern.stage === PatternStage.COOLDOWN) {
      return;
    }
    if (pattern.occurrenceCount >= MATURE_OCCURRENCES &&
        pattern.distinctDateCount >= MATURE_DATES &&
        pattern.confidence >= MATURE_CONFIDENCE) {
      pattern.stage = PatternStage.MATURE;
    } else if (pattern.occurrenceCount >= CANDIDATE_OCCURRENCES &&
               pattern.distinctDateCount >= CANDIDATE_DATES &&
               pattern.confidence >= CANDIDATE_CONFIDENCE) {
      pattern.stage = PatternStage.CANDIDATE;
    }
  }

  private matches(pattern: LearnedPattern, content: string): boolean {
    const normalized = this.normalize(content);
    if (normalized.length === 0) {
      return false;
    }
    const terms: string[] = [pattern.topic, ...pattern.aliases];
    for (let i = 0; i < terms.length; i++) {
      const term = this.normalize(terms[i]);
      if (term.length >= 2 && normalized.includes(term)) {
        return true;
      }
    }
    return false;
  }

  private mergeAliases(current: string[], incoming: string[]): string[] {
    const merged: string[] = [];
    const all: string[] = [...current, ...incoming];
    all.forEach((alias: string) => {
      const normalized = this.normalize(alias);
      if (normalized.length >= 2 && !merged.includes(normalized)) {
        merged.push(normalized);
      }
    });
    return merged;
  }

  private normalize(value: string): string {
    return value.trim().toLowerCase();
  }
}
