/**
 * Adapter: Returns DesignTokens from the ThemePalette.
 * Implements SkinProvider port.
 */
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { SkinProvider } from '../domain/ports/SkinProvider';

export class SkinProviderImpl implements SkinProvider {
  getTokens(id: SkinTheme): DesignTokens {
    return ThemePalette[id];
  }

  listThemes(): SkinTheme[] {
    return [SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL];
  }
}
