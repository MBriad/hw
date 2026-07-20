import { SkinTheme } from '../domain/SkinTheme';

/** Translucent surface colors kept outside the 13-field domain token contract. */
export class GlassTheme {
  static surface(theme: SkinTheme): ResourceColor {
    if (theme === SkinTheme.DARK) return 'rgba(22,27,34,0.76)';
    if (theme === SkinTheme.PINK) return 'rgba(255,255,255,0.70)';
    if (theme === SkinTheme.PASTEL) return 'rgba(255,255,255,0.68)';
    return 'rgba(255,255,255,0.74)';
  }

  static border(theme: SkinTheme): ResourceColor {
    if (theme === SkinTheme.DARK) return 'rgba(255,255,255,0.14)';
    if (theme === SkinTheme.PINK) return 'rgba(255,255,255,0.76)';
    if (theme === SkinTheme.PASTEL) return 'rgba(255,255,255,0.72)';
    return 'rgba(255,255,255,0.82)';
  }

  static shadow(theme: SkinTheme): ResourceColor {
    if (theme === SkinTheme.DARK) return 'rgba(0,0,0,0.34)';
    if (theme === SkinTheme.PINK) return 'rgba(190,24,93,0.12)';
    if (theme === SkinTheme.PASTEL) return 'rgba(107,140,232,0.14)';
    return 'rgba(15,23,42,0.10)';
  }
}
