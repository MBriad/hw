import { describe, it, expect } from '@ohos/hypium';
import { DetectEasterEgg } from '../main/ets/usecases/DetectEasterEgg';
import { KeywordMatcher } from '../main/ets/domain/ports/KeywordMatcher';
import { EasterEgg } from '../main/ets/domain/EasterEgg';

/**
 * Mock KeywordMatcher for isolated usecase testing.
 * ArkTS strict mode requires named class.
 */
class MockKeywordMatcher implements KeywordMatcher {
  public shouldMatch: boolean = true;
  public matchedEgg: EasterEgg = {
    keyword: 'test',
    quote: 'mock quote',
    effectType: 'mock_effect',
    soundFile: 'mock_sound',
  };

  match(_text: string): EasterEgg | null {
    return this.shouldMatch ? this.matchedEgg : null;
  }
}

export default function detectEasterEggTest() {
  describe('DetectEasterEgg', () => {

    it('delegates_to_KeywordMatcher_on_match', 0, () => {
      const mock = new MockKeywordMatcher();
      mock.shouldMatch = true;
      const usecase = new DetectEasterEgg(mock);
      const result = usecase.execute('Rust学习');
      expect(result !== null).assertEqual(true);
      expect(result!.keyword).assertEqual('test');
    });

    it('returns_null_when_no_match', 0, () => {
      const mock = new MockKeywordMatcher();
      mock.shouldMatch = false;
      const usecase = new DetectEasterEgg(mock);
      const result = usecase.execute('hello');
      expect(result === null).assertEqual(true);
    });

    it('returns_null_for_empty_text', 0, () => {
      const mock = new MockKeywordMatcher();
      mock.shouldMatch = true;
      const usecase = new DetectEasterEgg(mock);
      const result = usecase.execute('   ');
      expect(result === null).assertEqual(true);
    });

    it('trims_and_matches_whitespace_only', 0, () => {
      const mock = new MockKeywordMatcher();
      mock.shouldMatch = true;
      const usecase = new DetectEasterEgg(mock);
      const result = usecase.execute('');
      expect(result === null).assertEqual(true);
    });
  });
}
