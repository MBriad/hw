import { describe, it, expect } from '@ohos/hypium';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { SkinProviderImpl } from '../main/ets/adapters/SkinProviderImpl';

export default function skinProviderTest() {
  describe('SkinProvider', () => {

    it('getTokens_returns_light_with_correct_brandPrimary', 0, () => {
      const provider = new SkinProviderImpl();
      const tokens = provider.getTokens(SkinTheme.LIGHT);
      expect(tokens.brandPrimary).assertEqual('#0EA5E9');
      expect(tokens.bgBase).assertEqual('#F8FAFC');
    });

    it('getTokens_returns_dark_with_correct_values', 0, () => {
      const provider = new SkinProviderImpl();
      const tokens = provider.getTokens(SkinTheme.DARK);
      expect(tokens.brandPrimary).assertEqual('#3B82F6');
      expect(tokens.bgBase).assertEqual('#080C10');
      expect(tokens.brandAccent).assertEqual('#F43F5E');
    });

    it('getTokens_returns_pink_with_correct_values', 0, () => {
      const provider = new SkinProviderImpl();
      const tokens = provider.getTokens(SkinTheme.PINK);
      expect(tokens.brandPrimary).assertEqual('#FF4D94');
    });

    it('getTokens_returns_pastel_with_correct_values', 0, () => {
      const provider = new SkinProviderImpl();
      const tokens = provider.getTokens(SkinTheme.PASTEL);
      expect(tokens.brandPrimary).assertEqual('#85A3F7');
      expect(tokens.brandAccent).assertEqual('#FF9BAD');
    });

    it('listThemes_returns_all_4', 0, () => {
      const provider = new SkinProviderImpl();
      const themes = provider.listThemes();
      expect(themes.length).assertEqual(4);
    });

    it('all_tokens_have_13_fields', 0, () => {
      const provider = new SkinProviderImpl();
      const themes = provider.listThemes();
      for (let i = 0; i < themes.length; i++) {
        const t = provider.getTokens(themes[i]);
        // Verify key fields exist (DesignTokens has 13 required fields)
        let hasCore: boolean = (
          (t.bgBase as string).length > 0 &&
          (t.bgSurface as string).length > 0 &&
          (t.borderColor as string).length > 0 &&
          (t.textPrimary as string).length > 0 &&
          (t.brandPrimary as string).length > 0 &&
          (t.brandActive as string).length > 0
        );
        expect(hasCore).assertEqual(true);
      }
    });
  });
}
