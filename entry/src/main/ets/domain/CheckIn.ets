/**
 * Domain entity: a single check-in record.
 * Pure interface — zero framework dependencies.
 */
export interface CheckIn {
  /** ISO date string, e.g. '2026-07-19' */
  date: string;
  /** User's check-in text content */
  content: string;
  /** Unix timestamp in milliseconds */
  timestamp: number;
}
