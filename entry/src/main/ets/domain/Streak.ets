/**
 * Domain entity: streak and streak levels.
 * Pure interface — zero framework dependencies.
 */

/** Streak visual evolution levels */
export enum StreakLevel {
  /** Less than 3 consecutive days — normal rendering */
  NONE = 'NONE',
  /** 3-6 days: glowing cell animation */
  L1_GLOW = 'L1_GLOW',
  /** 7-29 days: A.T. Field hexagonal halo */
  L2_ATFIELD = 'L2_ATFIELD',
  /** 30+ days: full panel awakened theme */
  L3_AWAKENED = 'L3_AWAKENED',
}

/** Streak calculation result */
export interface StreakInfo {
  /** Current consecutive-day streak count */
  current: number;
  /** All-time longest streak */
  longest: number;
  /** Visual level derived from current streak */
  level: StreakLevel;
}

/** A cell on the heatmap grid */
export interface HeatmapCell {
  /** ISO date string, e.g. '2026-07-19' */
  date: string;
  /** Intensity level 0-4 (0 = no check-in, 4 = most check-ins) */
  level: number;
  /** Optional check-in data for this cell */
  checkIn?: import('./CheckIn').CheckIn;
}
