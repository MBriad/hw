/**
 * Port: Check-in persistence abstraction.
 * Pure interface — zero framework dependencies.
 * Implemented by adapters using @ohos.data.preferences or similar.
 */
import { CheckIn } from '../CheckIn';

export interface CheckInRepository {
  /** Persist a single check-in record */
  save(checkIn: CheckIn): Promise<void>;

  /** Load all check-in records ever created */
  loadAll(): Promise<CheckIn[]>;

  /** Load check-ins for a specific month (1-indexed) */
  loadByMonth(year: number, month: number): Promise<CheckIn[]>;

  /** Remove all persisted check-in records */
  clear(): Promise<void>;
}
