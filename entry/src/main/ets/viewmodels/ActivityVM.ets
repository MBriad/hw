/**
 * ViewModel: Activity stream, usage patterns, learned patterns, and AI analysis.
 * @Observed — serves LogsSection and PatternsSection.
 */
import { CheckIn } from '../domain/CheckIn';
import { EasterEgg, UsagePattern } from '../domain/EasterEgg';
import { LearnedPattern, PatternSuggestion } from '../domain/LearnedPattern';
import { ILoadActivity } from '../domain/ports/ActivityUseCases';
import { PatternLearningApi } from '../domain/ports/PatternLearningApi';
import { AnalyzePendingObservations, AnalyzeResult } from '../usecases/AnalyzePendingObservations';

@Observed
export class ActivityVM {
  checkIns: CheckIn[] = [];
  usagePatterns: UsagePattern[] = [];
  learnedPatterns: LearnedPattern[] = [];
  pendingLearningObservations: number = 0;

  private loadActivity: ILoadActivity;
  private patternLearning: PatternLearningApi;
  private analyzeUseCase: AnalyzePendingObservations | null;

  constructor(
    loadActivity: ILoadActivity,
    patternLearning: PatternLearningApi,
    analyzeUseCase?: AnalyzePendingObservations,
  ) {
    this.loadActivity = loadActivity;
    this.patternLearning = patternLearning;
    this.analyzeUseCase = analyzeUseCase ?? null;
  }

  async refreshActivity(): Promise<void> {
    const snapshot = await this.loadActivity.execute();
    this.checkIns = snapshot.checkIns;
    this.usagePatterns = snapshot.patterns;
  }

  async refreshPatterns(): Promise<void> {
    this.learnedPatterns = await this.patternLearning.load();
  }

  async refreshObservationCount(): Promise<void> {
    this.pendingLearningObservations = await this.patternLearning.pendingObservationCount();
  }

  async refreshAll(): Promise<void> {
    await Promise.all([
      this.refreshActivity(),
      this.refreshPatterns(),
      this.refreshObservationCount(),
    ]);
  }

  async observeLearnedPattern(
    suggestion: PatternSuggestion,
    date: string,
    now: number,
  ): Promise<LearnedPattern> {
    const pattern = await this.patternLearning.observe(suggestion, date, now);
    await this.refreshPatterns();
    return pattern;
  }

  async matchLearnedPattern(content: string, now: number): Promise<EasterEgg | null> {
    const egg = await this.patternLearning.match(content, now);
    await this.refreshPatterns();
    return egg;
  }

  async resetLearnedPatterns(): Promise<void> {
    await this.patternLearning.clear();
    this.learnedPatterns = [];
    this.pendingLearningObservations = 0;
  }

  async triggerAiAnalysis(): Promise<string> {
    if (this.analyzeUseCase === null) {
      return 'FAIL | AiPatternAdvisor not configured';
    }
    try {
      const result: AnalyzeResult = await this.analyzeUseCase.execute(Date.now());
      await this.refreshAll();
      return `OK | analyzed=${result.analyzed} | patterns=${result.patternsCreated}`;
    } catch (error) {
      return `FAIL | ${JSON.stringify(error)}`;
    }
  }
}
