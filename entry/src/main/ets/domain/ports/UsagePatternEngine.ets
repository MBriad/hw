import { CheckIn } from '../CheckIn';
import { EasterEgg, UsagePattern } from '../EasterEgg';

/** Pure policy port. Trigger terms come from the user's own check-in history. */
export interface UsagePatternEngine {
  evaluate(content: string, history: CheckIn[]): EasterEgg | null;
  summarize(history: CheckIn[]): UsagePattern[];
}
