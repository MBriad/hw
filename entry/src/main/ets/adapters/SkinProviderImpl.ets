/**
 * Adapter: Provides color configurations for 3 anime-themed skins.
 * Implements SkinProvider port.
 */
import { SkinTheme, SkinConfig } from '../domain/SkinTheme';
import { SkinProvider } from '../domain/ports/SkinProvider';

export class SkinProviderImpl implements SkinProvider {
  private skins: Map<SkinTheme, SkinConfig> = new Map();

  constructor() {
    this.skins.set(SkinTheme.EVA, {
      id: SkinTheme.EVA,
      name: 'EVA 绝对领域',
      primary: '#FF6B35',
      primaryDark: '#CC5528',
      surface: '#1A1A2E',
      surfaceSecondary: '#16213E',
      accent: '#7B2D8E',
      textOnPrimary: '#FFFFFF',
      textOnSurface: '#E0E0E0',
      cellEmpty: '#2A2A3E',
      border: '#3A3A5E',
    });

    this.skins.set(SkinTheme.MIKU, {
      id: SkinTheme.MIKU,
      name: '初音ミク',
      primary: '#39C5BB',
      primaryDark: '#2A9D8F',
      surface: '#F0F9F8',
      surfaceSecondary: '#E0F5F2',
      accent: '#86EFAC',
      textOnPrimary: '#FFFFFF',
      textOnSurface: '#1A3A3A',
      cellEmpty: '#D0E8E4',
      border: '#B0D0CC',
    });

    this.skins.set(SkinTheme.CYBERPUNK, {
      id: SkinTheme.CYBERPUNK,
      name: '赛博朋克霓虹',
      primary: '#00FFFF',
      primaryDark: '#00CCCC',
      surface: '#0A0A0F',
      surfaceSecondary: '#12121A',
      accent: '#FF00FF',
      textOnPrimary: '#0A0A0F',
      textOnSurface: '#E0E0FF',
      cellEmpty: '#1A1A2A',
      border: '#2A2A4A',
    });
  }

  getSkin(id: SkinTheme): SkinConfig {
    return this.skins.get(id)!;
  }

  listSkins(): SkinConfig[] {
    return [
      this.skins.get(SkinTheme.EVA)!,
      this.skins.get(SkinTheme.MIKU)!,
      this.skins.get(SkinTheme.CYBERPUNK)!,
    ];
  }
}
