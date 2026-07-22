import { preferences } from '@kit.ArkData';
import { SkinTheme } from '../domain/SkinTheme';
import { ThemePreferenceRepository } from '../domain/ports/ThemePreferenceRepository';

const STORE_NAME = 'app_settings';
const KEY_THEME = 'theme';

export class PreferencesThemeRepository implements ThemePreferenceRepository {
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  private async getStore(): Promise<preferences.Preferences> {
    return preferences.getPreferences(this.context, STORE_NAME);
  }

  async loadTheme(): Promise<SkinTheme> {
    try {
      const store = await this.getStore();
      const saved = await store.get(KEY_THEME, SkinTheme.LIGHT);
      if (saved === SkinTheme.LIGHT || saved === SkinTheme.DARK ||
          saved === SkinTheme.PINK || saved === SkinTheme.PASTEL) {
        return saved as SkinTheme;
      }
    } catch (_error) {
    }
    return SkinTheme.LIGHT;
  }

  async saveTheme(theme: SkinTheme): Promise<void> {
    try {
      const store = await this.getStore();
      await store.put(KEY_THEME, theme);
      await store.flush();
    } catch (_error) {
    }
  }
}
