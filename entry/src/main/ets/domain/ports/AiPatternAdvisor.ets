import { LearningObservation } from '../LearningObservation';
import { PatternSuggestion } from '../LearnedPattern';

/**
 * Port for AI-powered pattern analysis.
 *
 * Minimum surface: accepts a batch of pending observations, returns
 * structured pattern suggestions. Adapters are responsible for
 * HTTP/network concerns, timeout, and response validation.
 *
 * Degradation contract: on any failure (timeout, network error,
 * invalid response), implementations MUST return an empty array.
 * Callers never crash on AI unavailability.
 */
export interface AiPatternAdvisor {
  analyze(observations: LearningObservation[]): Promise<PatternSuggestion[]>;
}
