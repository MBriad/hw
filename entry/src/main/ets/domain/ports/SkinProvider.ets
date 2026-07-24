import { SkinTheme } from '../SkinTheme';

/** Port for persisted theme and locale preferences. */
export interface SkinProvider {
  listThemes(): SkinTheme[];
  loadPersisted(): Promise<SkinTheme>;
  persist(id: SkinTheme): Promise<void>;
  loadLocale(): Promise<string>;
  persistLocale(locale: string): Promise<void>;
}
