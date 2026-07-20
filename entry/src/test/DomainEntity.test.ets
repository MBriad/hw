import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { SkinTheme, DesignTokens, ThemePalette, ThemeNames } from '../main/ets/domain/SkinTheme';
import { StreakLevel, StreakInfo, HeatmapCell } from '../main/ets/domain/Streak';
import { EasterEgg, UsagePattern } from '../main/ets/domain/EasterEgg';

export default function domainEntityTest() {
  describe('DomainEntity', () => {

    it('CheckIn_interface_is_creatable', 0, () => {
      const ci: CheckIn = { date: '2026-07-19', content: 'Rust学习', timestamp: 123456 };
      expect(ci.date).assertEqual('2026-07-19');
      expect(ci.content).assertEqual('Rust学习');
      expect(ci.timestamp).assertEqual(123456);
    });

    it('SkinTheme_enum_has_4_values', 0, () => {
      expect(SkinTheme.LIGHT === 'light').assertEqual(true);
      expect(SkinTheme.DARK === 'dark').assertEqual(true);
      expect(SkinTheme.PINK === 'pink').assertEqual(true);
      expect(SkinTheme.PASTEL === 'pastel').assertEqual(true);
    });

    it('ThemeNames_has_labels_for_all_themes', 0, () => {
      expect(ThemeNames[SkinTheme.LIGHT]).assertEqual('清爽浅蓝');
      expect(ThemeNames[SkinTheme.DARK]).assertEqual('深海暗夜');
      expect(ThemeNames[SkinTheme.PINK]).assertEqual('魔法少女粉');
      expect(ThemeNames[SkinTheme.PASTEL]).assertEqual('马卡龙幻梦');
    });

    it('DesignTokens_class_is_creatable', 0, () => {
      const tokens = new DesignTokens();
      tokens.bgBase = '#F8FAFC';
      tokens.brandPrimary = '#0EA5E9';
      expect(tokens.bgBase).assertEqual('#F8FAFC');
      expect(tokens.brandPrimary).assertEqual('#0EA5E9');
    });

    it('ThemePalette_light_has_correct_brand_primary', 0, () => {
      const light = ThemePalette[SkinTheme.LIGHT];
      expect(light.brandPrimary).assertEqual('#0EA5E9');
      expect(light.bgBase).assertEqual('#F8FAFC');
      expect(light.bgSurface).assertEqual('#FFFFFF');
    });

    it('ThemePalette_dark_has_correct_tokens', 0, () => {
      const dark = ThemePalette[SkinTheme.DARK];
      expect(dark.brandPrimary).assertEqual('#3B82F6');
      expect(dark.bgBase).assertEqual('#080C10');
      expect(dark.brandAccent).assertEqual('#F43F5E');
    });

    it('ThemePalette_pink_has_correct_tokens', 0, () => {
      const pink = ThemePalette[SkinTheme.PINK];
      expect(pink.brandPrimary).assertEqual('#FF4D94');
      expect(pink.textPrimary).assertEqual('#4C1D95');
    });

    it('ThemePalette_pastel_has_correct_tokens', 0, () => {
      const pastel = ThemePalette[SkinTheme.PASTEL];
      expect(pastel.brandPrimary).assertEqual('#85A3F7');
      expect(pastel.brandAccent).assertEqual('#FF9BAD');
    });

    it('all_4_themes_have_required_token_fields', 0, () => {
      const themes = [SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL];
      for (let i = 0; i < themes.length; i++) {
        const t = ThemePalette[themes[i]];
        let hasTokens: boolean = (
          (t.bgBase as string).length > 0 &&
          (t.brandPrimary as string).length > 0 &&
          (t.textPrimary as string).length > 0
        );
        expect(hasTokens).assertEqual(true);
      }
    });

    it('StreakLevel_enum_values_are_correct', 0, () => {
      expect(StreakLevel.NONE === 'NONE').assertEqual(true);
      expect(StreakLevel.L1_GLOW === 'L1_GLOW').assertEqual(true);
      expect(StreakLevel.L2_ATFIELD === 'L2_ATFIELD').assertEqual(true);
      expect(StreakLevel.L3_AWAKENED === 'L3_AWAKENED').assertEqual(true);
    });

    it('StreakInfo_interface_is_creatable', 0, () => {
      const info: StreakInfo = { current: 5, longest: 10, level: StreakLevel.L1_GLOW };
      expect(info.current).assertEqual(5);
      expect(info.longest).assertEqual(10);
      expect(info.level).assertEqual(StreakLevel.L1_GLOW);
    });

    it('HeatmapCell_differentiates_levels', 0, () => {
      const empty: HeatmapCell = { date: '2026-07-01', level: 0 };
      const filled: HeatmapCell = {
        date: '2026-07-15',
        level: 3,
        checkIn: { date: '2026-07-15', content: 'Rust学习', timestamp: 1 }
      };
      expect(empty.level).assertEqual(0);
      let hasNoCheckIn: boolean = (empty.checkIn === undefined);
      expect(hasNoCheckIn).assertEqual(true);
      expect(filled.level).assertEqual(3);
      expect(filled.checkIn!.content).assertEqual('Rust学习');
    });

    it('EasterEgg_interface_is_creatable', 0, () => {
      const egg: EasterEgg = {
        keyword: 'Rust',
        quote: '检测到 Rustacean Commit',
        effectType: 'eva_at_field',
        soundFile: 'eva_alert.ogg'
      };
      expect(egg.keyword).assertEqual('Rust');
      expect(egg.quote).assertContain('Rustacean');
    });

    it('UsagePattern_tracks_learned_frequency', 0, () => {
      const pattern = new UsagePattern('绘画', 3, 7);
      expect(pattern.term).assertEqual('绘画');
      expect(pattern.count).assertEqual(3);
      expect(pattern.nextMilestone).assertEqual(7);
    });

    it('domain_types_compile_and_resolve', 0, () => {
      const ci: CheckIn = { date: '2026-07-19', content: 'test', timestamp: 0 };
      let isValid: boolean = (ci !== null && ci !== undefined);
      expect(isValid).assertEqual(true);
      expect(ci.content).assertEqual('test');
    });
  });
}
