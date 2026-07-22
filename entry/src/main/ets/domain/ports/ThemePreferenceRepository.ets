import { SkinTheme } from '../SkinTheme';

export interface ThemePreferenceRepository {
  loadTheme(): Promise<SkinTheme>;
  saveTheme(theme: SkinTheme): Promise<void>;
}
