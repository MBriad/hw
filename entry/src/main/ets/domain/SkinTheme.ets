/**
 * Design tokens and theme palette — Actrace Multi-Theme Design System.
 * Based on .agent/architecture/ui-design-system/design-tokens-and-component-patterns.md
 * Pure domain — zero framework dependencies.
 */

/** Supported theme identifiers */
export enum SkinTheme {
  LIGHT = 'light',
  DARK = 'dark',
  PINK = 'pink',
  PASTEL = 'pastel',
}

/** Theme display names */
export const ThemeNames: Record<SkinTheme, string> = {
  [SkinTheme.LIGHT]: '清爽浅蓝',
  [SkinTheme.DARK]: '深海暗夜',
  [SkinTheme.PINK]: '魔法少女粉',
  [SkinTheme.PASTEL]: '马卡龙幻梦',
} as Record<SkinTheme, string>;

/**
 * Complete set of design tokens for a single theme.
 * All colors are ResourceColor compatible.
 */
export class DesignTokens {
  // 基础表面
  bgBase: ResourceColor = '#F8FAFC';
  bgSurface: ResourceColor = '#FFFFFF';
  bgSurfacePressed: ResourceColor = '#E0F2FE';
  borderColor: ResourceColor = '#E2E8F0';

  // 文本
  textPrimary: ResourceColor = '#0F172A';
  textSecondary: ResourceColor = '#334155';
  textMuted: ResourceColor = '#64748B';
  textPlaceholder: ResourceColor = '#94A3B8';

  // 品牌色
  brandPrimary: ResourceColor = '#0EA5E9';
  brandActive: ResourceColor = '#0369A1';
  brandLight: ResourceColor = '#F0F9FF';
  brandText: ResourceColor = '#0284C7';
  brandAccent: ResourceColor = '#F59E0B';
}

/**
 * Complete color palette for all 4 themes.
 * Indexed by SkinTheme enum value.
 */
export const ThemePalette: Record<SkinTheme, DesignTokens> = {
  [SkinTheme.LIGHT]: {
    bgBase: '#F8FAFC',
    bgSurface: '#FFFFFF',
    bgSurfacePressed: '#E0F2FE',
    borderColor: '#E2E8F0',
    textPrimary: '#0F172A',
    textSecondary: '#334155',
    textMuted: '#64748B',
    textPlaceholder: '#94A3B8',
    brandPrimary: '#0EA5E9',
    brandActive: '#0369A1',
    brandLight: '#F0F9FF',
    brandText: '#0284C7',
    brandAccent: '#F59E0B',
  } as DesignTokens,

  [SkinTheme.DARK]: {
    bgBase: '#080C10',
    bgSurface: '#161B22',
    bgSurfacePressed: '#30363D',
    borderColor: '#30363D',
    textPrimary: '#F0F6FC',
    textSecondary: '#C9D1D9',
    textMuted: '#8B949E',
    textPlaceholder: '#6E7681',
    brandPrimary: '#3B82F6',
    brandActive: '#2563EB',
    brandLight: 'rgba(59,130,246,0.15)',
    brandText: '#93C5FD',
    brandAccent: '#F43F5E',
  } as DesignTokens,

  [SkinTheme.PINK]: {
    bgBase: '#FFF1F2',
    bgSurface: '#FFFFFF',
    bgSurfacePressed: '#FECDD3',
    borderColor: '#FECDD3',
    textPrimary: '#4C1D95',
    textSecondary: '#701A75',
    textMuted: '#9D174D',
    textPlaceholder: '#F472B6',
    brandPrimary: '#FF4D94',
    brandActive: '#BE185D',
    brandLight: '#FCE7F3',
    brandText: '#BE185D',
    brandAccent: '#FBBF24',
  } as DesignTokens,

  [SkinTheme.PASTEL]: {
    bgBase: '#FAFAFC',
    bgSurface: '#FFFFFF',
    bgSurfacePressed: '#F2F5FF',
    borderColor: '#EBF0F7',
    textPrimary: '#3D3E50',
    textSecondary: '#6E7085',
    textMuted: '#A3A5B8',
    textPlaceholder: '#C5C7D9',
    brandPrimary: '#85A3F7',
    brandActive: '#6B8CE8',
    brandLight: '#F2F5FF',
    brandText: '#6B8CE8',
    brandAccent: '#FF9BAD',
  } as DesignTokens,
} as Record<SkinTheme, DesignTokens>;

/** Result from LoadPersistedTheme usecase — named class for ArkTS strict mode */
export class ThemeResult {
  theme: SkinTheme = SkinTheme.LIGHT;
  tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];

  constructor(theme: SkinTheme, tokens: DesignTokens) {
    this.theme = theme;
    this.tokens = tokens;
  }
}
