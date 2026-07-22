import { SkinTheme, DesignTokens, ThemeResult } from '../domain/SkinTheme';
import { SkinProvider } from '../domain/ports/SkinProvider';
import { ThemePreferenceRepository } from '../domain/ports/ThemePreferenceRepository';
import { ILoadPersistedTheme, ISwitchTheme } from '../domain/ports/ThemeUseCases';

export class LoadPersistedTheme implements ILoadPersistedTheme {
  private skinProvider: SkinProvider;
  private themeRepo: ThemePreferenceRepository;

  constructor(skinProvider: SkinProvider, themeRepo: ThemePreferenceRepository) {
    this.skinProvider = skinProvider;
    this.themeRepo = themeRepo;
  }

  async execute(): Promise<ThemeResult> {
    const theme = await this.themeRepo.loadTheme();
    const tokens = this.skinProvider.getTokens(theme);
    return new ThemeResult(theme, tokens);
  }
}

export class SwitchTheme implements ISwitchTheme {
  private skinProvider: SkinProvider;
  private themeRepo: ThemePreferenceRepository;

  constructor(skinProvider: SkinProvider, themeRepo: ThemePreferenceRepository) {
    this.skinProvider = skinProvider;
    this.themeRepo = themeRepo;
  }

  async execute(theme: SkinTheme): Promise<DesignTokens> {
    await this.themeRepo.saveTheme(theme);
    return this.skinProvider.getTokens(theme);
  }
}
