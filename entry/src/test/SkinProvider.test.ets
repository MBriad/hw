import { describe, it, expect } from '@ohos/hypium';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { SkinProviderImpl } from '../main/ets/adapters/SkinProviderImpl';

export default function skinProviderTest() {
  describe('SkinProvider', () => {

    it('returns_eva_skin_with_correct_primary', 0, () => {
      const provider = new SkinProviderImpl();
      const skin = provider.getSkin(SkinTheme.EVA);
      expect(skin.primary).assertEqual('#FF6B35');
      expect(skin.name).assertContain('EVA');
    });

    it('returns_miku_skin_with_correct_primary', 0, () => {
      const provider = new SkinProviderImpl();
      const skin = provider.getSkin(SkinTheme.MIKU);
      expect(skin.primary).assertEqual('#39C5BB');
      expect(skin.name).assertContain('初音');
    });

    it('returns_cyberpunk_skin_with_correct_primary', 0, () => {
      const provider = new SkinProviderImpl();
      const skin = provider.getSkin(SkinTheme.CYBERPUNK);
      expect(skin.primary).assertEqual('#00FFFF');
      expect(skin.name).assertContain('赛博');
    });

    it('listSkins_returns_all_three', 0, () => {
      const provider = new SkinProviderImpl();
      const all = provider.listSkins();
      expect(all.length).assertEqual(3);
    });

    it('all_skins_have_required_fields', 0, () => {
      const provider = new SkinProviderImpl();
      const all = provider.listSkins();
      for (let i = 0; i < all.length; i++) {
        let hasPrimary: boolean = (all[i].primary.length > 0);
        expect(hasPrimary).assertEqual(true);
        let hasSurface: boolean = (all[i].surface.length > 0);
        expect(hasSurface).assertEqual(true);
        let hasCellEmpty: boolean = (all[i].cellEmpty.length > 0);
        expect(hasCellEmpty).assertEqual(true);
      }
    });
  });
}
