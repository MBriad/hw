/**
 * Port: Theme configuration provider.
 * Returns DesignTokens for a given theme.
 * Pure interface — zero framework dependencies.
 */
import { SkinTheme, DesignTokens } from '../SkinTheme';

export interface SkinProvider {
  /** Get full DesignTokens for a specific theme */
  getTokens(id: SkinTheme): DesignTokens;

  /** List all available themes */
  listThemes(): SkinTheme[];

  /** Load the persisted theme, falling back to LIGHT. */
  loadPersisted(): Promise<SkinTheme>;

  /** Persist the selected theme. */
  persist(id: SkinTheme): Promise<void>;

  /** Load persisted locale, falling back to 'zh'. */
  loadLocale(): Promise<string>;

  /** Persist locale preference. */
  persistLocale(locale: string): Promise<void>;
}
