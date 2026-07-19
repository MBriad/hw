import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { SkinTheme, SkinConfig } from '../main/ets/domain/SkinTheme';
import { StreakLevel, StreakInfo, HeatmapCell } from '../main/ets/domain/Streak';
import { EasterEggRule, EasterEgg } from '../main/ets/domain/EasterEgg';

export default function domainEntityTest() {
  describe('DomainEntity', () => {

    it('CheckIn_interface_is_creatable', 0, () => {
      const ci: CheckIn = { date: '2026-07-19', content: 'Rust学习', timestamp: 123456 };
      expect(ci.date).assertEqual('2026-07-19');
      expect(ci.content).assertEqual('Rust学习');
      expect(ci.timestamp).assertEqual(123456);
    });

    it('SkinTheme_enum_values_are_correct', 0, () => {
      // ArkTS strict mode does not allow Object.keys on enums.
      // Verify each enum value individually instead.
      expect(SkinTheme.EVA === 'EVA').assertEqual(true);
      expect(SkinTheme.MIKU === 'MIKU').assertEqual(true);
      expect(SkinTheme.CYBERPUNK === 'CYBERPUNK').assertEqual(true);
    });

    it('SkinConfig_interface_is_creatable', 0, () => {
      const config: SkinConfig = {
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
      };
      expect(config.id).assertEqual(SkinTheme.EVA);
      expect(config.primary).assertEqual('#FF6B35');
      expect(config.name).assertContain('EVA');
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

    it('EasterEggRule_defines_trigger_mapping', 0, () => {
      const rule: EasterEggRule = {
        keywords: ['Rust', 'rust', 'RUST'],
        quote: '世界线变动率：0.231492%',
        effectType: 'eva_at_field',
        soundFile: 'eva_alert.ogg'
      };
      expect(rule.keywords.length).assertEqual(3);
      expect(rule.keywords[0]).assertEqual('Rust');
    });

    it('domain_types_compile_and_resolve', 0, () => {
      const ci: CheckIn = { date: '2026-07-19', content: 'test', timestamp: 0 };
      let isValid: boolean = (ci !== null && ci !== undefined);
      expect(isValid).assertEqual(true);
      expect(ci.content).assertEqual('test');
    });
  });
}
