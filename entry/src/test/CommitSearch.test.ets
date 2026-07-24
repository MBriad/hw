import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { CommitSearch } from '../main/ets/pages/support/CommitSearch';

function records(): CheckIn[] {
  return [
    new CheckIn('2026-07-24', 'Newest progress', 400),
    new CheckIn('2026-07-24', 'Earlier progress', 350),
    new CheckIn('2026-07-23', 'Refactor logs', 300),
    new CheckIn('2026-07-22', 'Calendar cleanup', 200),
  ];
}

export default function commitSearchTest() {
  describe('CommitSearch', () => {
    it('matches_content_case_insensitively', 0, () => {
      expect(CommitSearch.contentOrSequenceIndexes(records(), 'PROGRESS')).assertDeepEquals([0, 1]);
      expect(CommitSearch.contentOrSequenceIndexes(records(), 'REFACTOR')).assertDeepEquals([2]);
    });

    it('matches_exact_date_in_existing_order', 0, () => {
      expect(CommitSearch.dateIndexes(records(), '2026-07-24')).assertDeepEquals([0, 1]);
      expect(CommitSearch.dateIndexes(records(), '2026-07')).assertDeepEquals([]);
    });

    it('jumps_by_display_sequence', 0, () => {
      expect(CommitSearch.contentOrSequenceIndexes(records(), '#004')).assertDeepEquals([0]);
      expect(CommitSearch.contentOrSequenceIndexes(records(), '#001')).assertDeepEquals([3]);
    });

    it('returns_empty_for_unknown_query', 0, () => {
      expect(CommitSearch.contentOrSequenceIndexes(records(), '')).assertDeepEquals([]);
      expect(CommitSearch.contentOrSequenceIndexes(records(), '#999')).assertDeepEquals([]);
      expect(CommitSearch.contentOrSequenceIndexes(records(), '#invalid')).assertDeepEquals([]);
      expect(CommitSearch.contentOrSequenceIndexes(records(), '2026-07-24')).assertDeepEquals([]);
      expect(CommitSearch.contentOrSequenceIndexes(records(), 'missing')).assertDeepEquals([]);
    });
  });
}
