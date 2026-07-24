import { describe, it, expect } from '@ohos/hypium';
import { CommitIndexMath } from '../main/ets/pages/support/CommitIndexMath';

export default function commitIndexMathTest() {
  describe('CommitIndexMath', () => {
    it('maps positions to bounded indexes', 0, () => {
      expect(CommitIndexMath.indexForPosition(-1, 100, 10)).assertEqual(0);
      expect(CommitIndexMath.indexForPosition(50, 100, 10)).assertEqual(5);
      expect(CommitIndexMath.indexForPosition(101, 100, 10)).assertEqual(9);
    });

    it('handles large data without invalid bucket ranges', 0, () => {
      const bucketCount = CommitIndexMath.bucketCount(10000, 192);
      expect(bucketCount).assertEqual(192);
      const first = CommitIndexMath.bucketStart(0, 10000, bucketCount);
      const last = CommitIndexMath.bucketEnd(bucketCount - 1, 10000, bucketCount);
      expect(first).assertEqual(0);
      expect(last).assertEqual(9999);
    });

    it('maps records back to compressed buckets', 0, () => {
      expect(CommitIndexMath.bucketForIndex(-1, 10000, 192)).assertEqual(0);
      expect(CommitIndexMath.bucketForIndex(5000, 10000, 192)).assertEqual(96);
      expect(CommitIndexMath.bucketForIndex(9999, 10000, 192)).assertEqual(191);
      expect(CommitIndexMath.bucketForIndex(0, 0, 0)).assertEqual(-1);
    });
  });
}
