import { EasterEgg } from '../domain/EasterEgg';
import { LearningObservation } from '../domain/LearningObservation';
import { LearnedPattern, PatternMatchResult, PatternSuggestion } from '../domain/LearnedPattern';
import { LearnedPatternPolicy } from '../domain/LearnedPatternPolicy';
import { LearningObservationRepository } from '../domain/ports/LearningObservationRepository';
import { LearnedPatternRepository } from '../domain/ports/LearnedPatternRepository';
import { PatternLearningApi } from '../domain/ports/PatternLearningApi';

export class ManageLearnedPatterns implements PatternLearningApi {
  private repo: LearnedPatternRepository;
  private observationRepo: LearningObservationRepository;
  private policy: LearnedPatternPolicy;

  constructor(
    repo: LearnedPatternRepository,
    policy: LearnedPatternPolicy,
    observationRepo: LearningObservationRepository,
  ) {
    this.repo = repo;
    this.policy = policy;
    this.observationRepo = observationRepo;
  }

  async load(): Promise<LearnedPattern[]> {
    return this.repo.loadAll();
  }

  async captureInput(content: string, date: string, now: number): Promise<void> {
    const normalized = content.trim();
    if (normalized.length === 0) {
      return;
    }
    await this.observationRepo.save(new LearningObservation(date, normalized, now));
  }

  async pendingObservationCount(): Promise<number> {
    const observations = await this.observationRepo.loadPending();
    return observations.length;
  }

  async observe(suggestion: PatternSuggestion, date: string, now: number): Promise<LearnedPattern> {
    const patterns = await this.repo.loadAll();
    const id = suggestion.topic.trim().toLowerCase();
    const existing = patterns.find((pattern: LearnedPattern) => pattern.id === id) ?? null;
    const updated = this.policy.observe(existing, suggestion, date, now);
    await this.repo.save(updated);
    return updated;
  }

  async match(content: string, now: number): Promise<EasterEgg | null> {
    const patterns = await this.repo.loadAll();
    patterns.sort((left: LearnedPattern, right: LearnedPattern) => right.confidence - left.confidence);
    for (let i = 0; i < patterns.length; i++) {
      const beforeStage = patterns[i].stage;
      const beforeCooldown = patterns[i].cooldownUntil;
      const result: PatternMatchResult = this.policy.match(patterns[i], content, now);
      if (result.pattern.stage !== beforeStage || result.pattern.cooldownUntil !== beforeCooldown) {
        await this.repo.save(result.pattern);
      }
      if (result.egg !== null) {
        return result.egg;
      }
    }
    return null;
  }

  async clear(): Promise<void> {
    await Promise.all([this.repo.clear(), this.observationRepo.clear()]);
  }
}
