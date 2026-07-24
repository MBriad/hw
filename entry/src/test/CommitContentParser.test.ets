import { describe, it, expect } from '@ohos/hypium';
import { CommitContentParser } from '../main/ets/pages/components/CommitContentText';

export default function commitContentParserTest() {
  describe('CommitContentParser', () => {
    it('keeps_mixed_text_and_urls_in_order', 0, () => {
      const segments = CommitContentParser.segments(
        '中文 https://example.com/a?x=1 and http://example.org/end',
      );
      expect(segments.length).assertEqual(4);
      expect(segments[0].text).assertEqual('中文 ');
      expect(segments[1].url).assertEqual('https://example.com/a?x=1');
      expect(segments[2].text).assertEqual(' and ');
      expect(segments[3].url).assertEqual('http://example.org/end');
    });

    it('keeps_plain_and_empty_content_readable', 0, () => {
      expect(CommitContentParser.segments('普通内容')[0].text).assertEqual('普通内容');
      expect(CommitContentParser.segments('')[0].text).assertEqual('');
    });
  });
}
