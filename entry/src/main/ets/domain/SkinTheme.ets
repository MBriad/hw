/**
 * Domain entity: anime-themed skin definitions.
 * Pure interface — zero framework dependencies.
 */

export enum SkinTheme {
  EVA = 'EVA',
  MIKU = 'MIKU',
  CYBERPUNK = 'CYBERPUNK',
}

/** Color + visual configuration for a single skin */
export interface SkinConfig {
  /** Skin identifier */
  id: SkinTheme;
  /** Display name */
  name: string;
  /** Primary brand color (hex, e.g. '#FF6B35') */
  primary: string;
  /** Darker shade for grid cell level 4 */
  primaryDark: string;
  /** Surface/background color */
  surface: string;
  /** Card/secondary surface color */
  surfaceSecondary: string;
  /** Accent/highlight color */
  accent: string;
  /** Text color on primary backgrounds */
  textOnPrimary: string;
  /** Text color on surface backgrounds */
  textOnSurface: string;
  /** Empty cell color (no check-in) */
  cellEmpty: string;
  /** Subtle border color */
  border: string;
}
