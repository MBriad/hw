import { CheckIn } from '../CheckIn';
import { UsagePattern } from '../EasterEgg';

/** Summarizes terms learned from the user's check-in history. */
export interface UsagePatternEngine {
  summarize(history: CheckIn[]): UsagePattern[];
}
