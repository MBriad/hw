/**
 * ViewModel: Theme state and persistence.
 * @Observed — serves ProfileSection and SkinSwitcher.
 */
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { SkinProvider } from '../domain/ports/SkinProvider';

@Observed
export class ThemeVM {
  currentSkin: SkinTheme = SkinTheme.LIGHT;
  currentTokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];

  private skinProvider: SkinProvider;

  constructor(skinProvider: SkinProvider) {
    this.skinProvider = skinProvider;
  }

  async initialize(): Promise<void> {
    const persistedTheme = await this.skinProvider.loadPersisted();
    this.applySkin(persistedTheme);
  }

  async switchSkin(theme: SkinTheme): Promise<void> {
    this.applySkin(theme);
    return this.skinProvider.persist(theme);
  }

  async loadLocale(): Promise<string> {
    return this.skinProvider.loadLocale();
  }

  async persistLocale(locale: string): Promise<void> {
    return this.skinProvider.persistLocale(locale);
  }

  private applySkin(theme: SkinTheme): void {
    this.currentSkin = theme;
    this.currentTokens = this.skinProvider.getTokens(theme);
  }
}
