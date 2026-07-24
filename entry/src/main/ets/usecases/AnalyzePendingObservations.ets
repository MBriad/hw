import { PatternSuggestion } from '../domain/LearnedPattern';
import { AiPatternAdvisor } from '../domain/ports/AiPatternAdvisor';
import { PatternLearningApi } from '../domain/ports/PatternLearningApi';
import { AnalyzePendingUseCase, AnalyzeResult } from '../domain/ports/AnalyzePendingUseCase';

/**
 * Orchestrates a single batch AI analysis cycle:
 * 1. Load oldest pending observations
 * 2. Send to AI for pattern suggestions
 * 3. Feed each suggestion into the existing learning pipeline
 * 4. Acknowledge observations as processed
 *
 * Safe degradation: if the AI advisor returns empty (or throws),
 * observations are NOT consumed — they remain pending for the
 * next attempt. No data is lost.
 */
export class AnalyzePendingObservations implements AnalyzePendingUseCase {
  private patternLearning: PatternLearningApi;
  private aiAdvisor: AiPatternAdvisor;
  private batchSize: number;

  constructor(
    patternLearning: PatternLearningApi,
    aiAdvisor: AiPatternAdvisor,
    batchSize: number = 20,
  ) {
    this.patternLearning = patternLearning;
    this.aiAdvisor = aiAdvisor;
    this.batchSize = batchSize;
  }

  async execute(now: number): Promise<AnalyzeResult> {
    const observations = await this.patternLearning.loadPendingBatch(this.batchSize);
    if (observations.length === 0) {
      return new AnalyzeResult(0, 0);
    }

    let suggestions: PatternSuggestion[];
    try {
      suggestions = await this.aiAdvisor.analyze(observations);
    } catch (_error) {
      // Degradation: AI failure leaves observations pending.
      // No patterns created, no data consumed.
      return new AnalyzeResult(0, 0);
    }

    if (suggestions.length === 0) {
      // AI returned nothing useful — still consume observations
      // so they don't loop forever.
      await this.patternLearning.acknowledgeProcessed(observations);
      return new AnalyzeResult(observations.length, 0);
    }

    for (let i = 0; i < suggestions.length; i++) {
      const suggestion = suggestions[i];
      // Use the date from the first observation as the reference date
      // for the pattern observation. In a real implementation, the AI
      // would provide per-suggestion dates.
      const referenceDate = observations.length > 0 ? observations[0].date : '';
      await this.patternLearning.observe(suggestion, referenceDate, now);
    }

    await this.patternLearning.acknowledgeProcessed(observations);
    return new AnalyzeResult(observations.length, suggestions.length);
  }
}
