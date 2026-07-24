import { describe, it, expect } from '@ohos/hypium';
import { labelsForLocale } from '../main/ets/common/UILabels';

export default function uiLabelsTest() {
  describe('UILabels', () => {
    it('returns_chinese_labels_for_zh', 0, () => {
      const labels = labelsForLocale('zh');
      expect(labels.searchCommits).assertEqual('搜索内容或 #序号');
      expect(labels.searchDate).assertEqual('按日期搜索');
      expect(labels.tabProfile).assertEqual('用户');
      expect(labels.devDebugPanel).assertEqual('开发调试面板');
      expect(labels.commitCountLabel).assertEqual('次提交');
    });

    it('returns_english_labels_for_en', 0, () => {
      const labels = labelsForLocale('en');
      expect(labels.searchCommits).assertEqual('CONTENT OR #INDEX');
      expect(labels.searchDate).assertEqual('SEARCH BY DATE');
      expect(labels.tabProfile).assertEqual('PROFILE');
      expect(labels.devDebugPanel).assertEqual('DEV DEBUG PANEL');
      expect(labels.patternCountLabel).assertEqual('PATTERNS');
    });

    it('falls_back_to_chinese_for_unsupported_locale', 0, () => {
      expect(labelsForLocale('invalid').tabCalendar).assertEqual('日历');
    });
  });
}
