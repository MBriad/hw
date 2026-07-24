import { describe, it, expect } from '@ohos/hypium';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { SkinProviderImpl } from '../main/ets/adapters/SkinProviderImpl';

export default function skinProviderTest() {
  describe('SkinProvider', () => {
    it('lists_all_supported_themes', 0, () => {
      const themes = new SkinProviderImpl(null).listThemes();
      expect(themes.length).assertEqual(4);
      expect(themes[0]).assertEqual(SkinTheme.LIGHT);
      expect(themes[3]).assertEqual(SkinTheme.PASTEL);
    });

    it('falls_back_without_a_preferences_context', 0, async () => {
      const provider = new SkinProviderImpl(null);
      expect(await provider.loadPersisted()).assertEqual(SkinTheme.LIGHT);
      expect(await provider.loadLocale()).assertEqual('zh');
    });

    it('accepts_no_context_persistence_calls', 0, async () => {
      const provider = new SkinProviderImpl(null);
      await provider.persist(SkinTheme.DARK);
      await provider.persistLocale('en');
      expect(true).assertTrue();
    });
  });
}
