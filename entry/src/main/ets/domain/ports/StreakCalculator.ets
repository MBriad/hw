/**
 * Port: Streak calculation from check-in history.
 * Pure interface — zero framework dependencies.
 */
import { CheckIn } from '../CheckIn';
import { StreakInfo } from '../Streak';

export interface StreakCalculator {
  /**
   * Calculate streak from a set of check-in records.
   * Returns current streak, longest streak, and visual evolution level.
   */
  calculate(records: CheckIn[]): StreakInfo;
}
