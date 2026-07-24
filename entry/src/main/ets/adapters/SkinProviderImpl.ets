/** Adapter: theme palette lookup and preferences persistence. */
import { preferences } from '@kit.ArkData';
import { SkinTheme } from '../domain/SkinTheme';
import { SkinProvider } from '../domain/ports/SkinProvider';

const STORE_NAME = 'app_settings';
const KEY_THEME = 'theme';
const KEY_LOCALE = 'locale';

export class SkinProviderImpl implements SkinProvider {
  private context: Context | null;

  constructor(context: Context | null) {
    this.context = context;
  }

  listThemes(): SkinTheme[] {
    return [SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL];
  }

  async loadPersisted(): Promise<SkinTheme> {
    if (this.context === null) {
      return SkinTheme.LIGHT;
    }
    try {
      const store = await preferences.getPreferences(this.context, STORE_NAME);
      const value = await store.get(KEY_THEME, SkinTheme.LIGHT);
      return this.isSupported(value as string) ? value as SkinTheme : SkinTheme.LIGHT;
    } catch (_error) {
      return SkinTheme.LIGHT;
    }
  }

  async persist(id: SkinTheme): Promise<void> {
    if (this.context === null) {
      return;
    }
    try {
      const store = await preferences.getPreferences(this.context, STORE_NAME);
      await store.put(KEY_THEME, id);
      await store.flush();
    } catch (_error) {
    }
  }

  async loadLocale(): Promise<string> {
    if (this.context === null) {
      return 'zh';
    }
    try {
      const store = await preferences.getPreferences(this.context, STORE_NAME);
      const value = await store.get(KEY_LOCALE, 'zh');
      return (value === 'zh' || value === 'en') ? value as string : 'zh';
    } catch (_error) {
      return 'zh';
    }
  }

  async persistLocale(locale: string): Promise<void> {
    if (this.context === null) {
      return;
    }
    try {
      const store = await preferences.getPreferences(this.context, STORE_NAME);
      await store.put(KEY_LOCALE, locale);
      await store.flush();
    } catch (_error) {
    }
  }

  private isSupported(value: string): boolean {
    return value === SkinTheme.LIGHT || value === SkinTheme.DARK ||
      value === SkinTheme.PINK || value === SkinTheme.PASTEL;
  }
}
