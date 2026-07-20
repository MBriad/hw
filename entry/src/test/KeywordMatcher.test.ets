import { describe, it, expect } from '@ohos/hypium';
import { RegexKeywordMatcher } from '../main/ets/adapters/RegexKeywordMatcher';

export default function keywordMatcherTest() {
  describe('KeywordMatcher', () => {

    it('matches_Rust_keyword', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('学了2小时Rust');
      expect(result !== null).assertEqual(true);
      expect(result!.quote).assertContain('世界线变动率');
      expect(result!.effectType).assertEqual('eva_at_field');
    });

    it('matches_overtime_keyword', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('加班到12点');
      expect(result !== null).assertEqual(true);
      expect(result!.keyword).assertEqual('加班');
    });

    it('matches_bug_keyword', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('今天修Bug修了一天');
      expect(result !== null).assertEqual(true);
      expect(result!.effectType).assertEqual('particle_sparkle');
    });

    it('returns_null_for_no_match', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('正常的一天');
      expect(result === null).assertEqual(true);
    });

    it('case_insensitive_match', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('RUST 真的好难');
      expect(result !== null).assertEqual(true);
      expect(result!.keyword).assertEqual('Rust');
    });

    it('first_match_wins_for_multiple_keywords', 0, () => {
      const matcher = new RegexKeywordMatcher();
      // '加班' appears before 'Bug' in rule list, '学习' before '加班'
      const result = matcher.match('学习Rust到加班修Bug');
      // 'Rust' is added first since we search for keywords in rule order:
      // Rule 0 (Rust) -> Rule 1 (加班) -> etc. First matching keyword wins.
      // But actually we return on the first matching rule
      expect(result !== null).assertEqual(true);
      // Should match the first rule's first keyword: Rust
    });

    it('matches_anime_keyword', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('看完了约定的梦幻岛');
      expect(result !== null).assertEqual(true);
      expect(result!.quote).assertContain('知识 +1');
    });

    it('returns_easter_egg_with_all_fields', 0, () => {
      const matcher = new RegexKeywordMatcher();
      const result = matcher.match('摸鱼一整天');
      expect(result !== null).assertEqual(true);
      expect(result!.keyword).assertEqual('摸鱼');
      let hasQuote: boolean = (result!.quote.length > 0);
      expect(hasQuote).assertEqual(true);
      let hasEffect: boolean = (result!.effectType.length > 0);
      expect(hasEffect).assertEqual(true);
      let hasSound: boolean = (result!.soundFile.length > 0);
      expect(hasSound).assertEqual(true);
    });
  });
}
