import { describe, it, expect } from '@ohos/hypium';
import { HeatmapVM } from '../main/ets/viewmodels/HeatmapVM';
import { SkinTheme } from '../main/ets/domain/SkinTheme';
import { EasterEgg } from '../main/ets/domain/EasterEgg';
import { SkinProviderImpl } from '../main/ets/adapters/SkinProviderImpl';
import { HeatmapCell } from '../main/ets/domain/Streak';
import { KeywordMatcher } from '../main/ets/domain/ports/KeywordMatcher';
import { SoundPlayer } from '../main/ets/domain/ports/SoundPlayer';
import { MockLoadHeatmap, MockRecordCheckIn } from './mocks/MockUseCases';

class MockKeywordMatcher implements KeywordMatcher {
  public shouldMatch: boolean = false;
  public matchedEgg: EasterEgg = {
    keyword: 'test', quote: 'mock quote',
    effectType: 'mock_effect', soundFile: 'mock_sound',
  };
  match(_text: string): EasterEgg | null {
    return this.shouldMatch ? this.matchedEgg : null;
  }
}

class MockSoundPlayer implements SoundPlayer {
  public lastPlayed: string = '';
  async play(fileName: string): Promise<boolean> {
    this.lastPlayed = fileName;
    return true;
  }
}

export default function heatmapVMTest() {
  describe('HeatmapVM', () => {

    it('recordCheckIn_delegates_to_usecase', 0, async () => {
      const ml = new MockLoadHeatmap();
      const mr = new MockRecordCheckIn();
      const sp = new SkinProviderImpl();
      const mm = new MockKeywordMatcher();
      const ms = new MockSoundPlayer();
      const vm = new HeatmapVM(ml, mr, sp, mm, ms);
      vm.selectDate('2026-07-19');
      await vm.doCheckIn('Rust学习');
      expect(mr.capturedDate).assertEqual('2026-07-19');
      expect(mr.capturedContent).assertEqual('Rust学习');
    });

    it('switchSkin_updates_currentTokens', 0, () => {
      const ml = new MockLoadHeatmap();
      const mr = new MockRecordCheckIn();
      const sp = new SkinProviderImpl();
      const mm = new MockKeywordMatcher();
      const ms = new MockSoundPlayer();
      const vm = new HeatmapVM(ml, mr, sp, mm, ms);
      vm.switchSkin(SkinTheme.DARK);
      expect(vm.currentSkin).assertEqual(SkinTheme.DARK);
      expect(vm.currentTokens.brandPrimary).assertEqual('#3B82F6');
    });

    it('doCheckIn_triggers_easter_egg_on_match', 0, async () => {
      const ml = new MockLoadHeatmap();
      const mr = new MockRecordCheckIn();
      const sp = new SkinProviderImpl();
      const mm = new MockKeywordMatcher();
      mm.shouldMatch = true;
      const ms = new MockSoundPlayer();
      const vm = new HeatmapVM(ml, mr, sp, mm, ms);
      vm.selectDate('2026-07-19');
      await vm.doCheckIn('加班到深夜');
      expect(vm.triggeredEgg !== null).assertEqual(true);
      expect(vm.showParticles).assertEqual(true);
      expect(vm.showBanner).assertEqual(true);
      expect(ms.lastPlayed).assertEqual('mock_sound');
    });

    it('doCheckIn_no_egg_on_no_match', 0, async () => {
      const ml = new MockLoadHeatmap();
      const mr = new MockRecordCheckIn();
      const sp = new SkinProviderImpl();
      const mm = new MockKeywordMatcher();
      mm.shouldMatch = false;
      const ms = new MockSoundPlayer();
      const vm = new HeatmapVM(ml, mr, sp, mm, ms);
      vm.selectDate('2026-07-19');
      await vm.doCheckIn('正常的一天');
      expect(vm.triggeredEgg === null).assertEqual(true);
      expect(vm.showParticles).assertEqual(false);
    });

    it('dismissEgg_clears_state', 0, async () => {
      const ml = new MockLoadHeatmap();
      const mr = new MockRecordCheckIn();
      const sp = new SkinProviderImpl();
      const mm = new MockKeywordMatcher();
      mm.shouldMatch = true;
      const ms = new MockSoundPlayer();
      const vm = new HeatmapVM(ml, mr, sp, mm, ms);
      vm.selectDate('2026-07-19');
      await vm.doCheckIn('加班');
      vm.dismissEgg();
      expect(vm.triggeredEgg === null).assertEqual(true);
      expect(vm.showParticles).assertEqual(false);
      expect(vm.showBanner).assertEqual(false);
    });

    it('default_skin_is_LIGHT', 0, () => {
      const ml = new MockLoadHeatmap();
      const mr = new MockRecordCheckIn();
      const sp = new SkinProviderImpl();
      const mm = new MockKeywordMatcher();
      const ms = new MockSoundPlayer();
      const vm = new HeatmapVM(ml, mr, sp, mm, ms);
      expect(vm.currentSkin).assertEqual(SkinTheme.LIGHT);
    });
  });
}
