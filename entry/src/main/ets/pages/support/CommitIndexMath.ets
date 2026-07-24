/** Pure presentation math for the Logs minimap. */
export class CommitIndexMath {
  static indexForPosition(position: number, height: number, count: number): number {
    if (count <= 0) {
      return -1;
    }
    if (height <= 0 || position <= 0) {
      return 0;
    }
    if (position >= height) {
      return count - 1;
    }
    return Math.min(count - 1, Math.floor((position / height) * count));
  }

  static bucketCount(count: number, height: number): number {
    if (count <= 0 || height <= 0) {
      return 0;
    }
    return Math.min(count, Math.max(1, Math.floor(height)));
  }

  static bucketStart(bucket: number, count: number, bucketCount: number): number {
    return Math.floor((bucket * count) / bucketCount);
  }

  static bucketEnd(bucket: number, count: number, bucketCount: number): number {
    return Math.max(
      CommitIndexMath.bucketStart(bucket, count, bucketCount),
      Math.floor(((bucket + 1) * count) / bucketCount) - 1,
    );
  }

  static bucketForIndex(index: number, count: number, bucketCount: number): number {
    if (count <= 0 || bucketCount <= 0) {
      return -1;
    }
    const boundedIndex = Math.max(0, Math.min(index, count - 1));
    return Math.min(bucketCount - 1, Math.floor((boundedIndex * bucketCount) / count));
  }
}
