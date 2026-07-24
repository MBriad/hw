import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../common/ThemeTokens';
import { CommitIndexMath } from '../support/CommitIndexMath';

const RAIL_WIDTH = 28;
const TICK_HEIGHT = 1;
const TICK_PITCH = 8;
const IDLE_TICK_WIDTH = 6;
const ACTIVE_TICK_WIDTH = 16;

/** Floating minimap rail for direct navigation across a large commit history. */
@Component
export struct CommitIndexRail {
  @Consume tokens: DesignTokens;
  @Prop checkIns: CheckIn[];
  @Prop selectedIndex: number;
  onPreview?: (index: number) => void;
  onSelect?: (index: number) => void;
  @State private railHeight: number = 240;
  @State private hoveredIndex: number = -1;

  private visibleIndexes(): number[] {
    const count = CommitIndexMath.bucketCount(this.checkIns.length, Math.floor(this.railHeight / TICK_PITCH));
    const indexes: number[] = [];
    for (let bucket = 0; bucket < count; bucket++) {
      indexes.push(CommitIndexMath.bucketStart(bucket, this.checkIns.length, count));
    }
    return indexes;
  }

  private bucketCount(): number {
    return CommitIndexMath.bucketCount(this.checkIns.length, Math.floor(this.railHeight / TICK_PITCH));
  }

  private hoveredBucket(): number {
    return CommitIndexMath.bucketForIndex(this.hoveredIndex, this.checkIns.length, this.bucketCount());
  }

  private selectedBucket(): number {
    return CommitIndexMath.bucketForIndex(this.selectedIndex, this.checkIns.length, this.bucketCount());
  }

  private activeBucket(): number {
    return this.hoveredIndex >= 0 ? this.hoveredBucket() : this.selectedBucket();
  }

  private previewIndex(index: number): void {
    if (index < 0 || index >= this.checkIns.length) {
      return;
    }
    if (index === this.hoveredIndex) {
      return;
    }
    this.hoveredIndex = index;
    if (this.onPreview) {
      this.onPreview(index);
    }
  }

  private previewAt(position: number): void {
    const index = CommitIndexMath.indexForPosition(position, this.railHeight, this.checkIns.length);
    this.previewIndex(index);
  }

  private selectIndex(index: number): void {
    if (index >= 0 && index < this.checkIns.length && this.onSelect) {
      this.onSelect(index);
    }
  }

  build() {
    Stack() {
      Column() {
        ForEach(this.visibleIndexes(), (recordIndex: number, tickIndex: number) => {
          Stack() {
            Row()
              .width(tickIndex === this.activeBucket() ? ACTIVE_TICK_WIDTH : IDLE_TICK_WIDTH)
              .height(tickIndex === this.activeBucket() ? 2 : TICK_HEIGHT)
              .backgroundColor(tickIndex === this.activeBucket() ?
                this.hoveredIndex >= 0 ? '#000000' : this.tokens.textPrimary : '#E0E0E0')
              .id(tickIndex === this.activeBucket() ?
                'logs-commit-index-marker' : `logs-commit-index-line-${tickIndex}`)
          }
          .width('100%')
          .layoutWeight(1)
          .alignContent(Alignment.Center)
          .onHover((isHover: boolean) => {
            if (isHover) {
              this.previewIndex(recordIndex);
            }
          })
          .onMouse((event: MouseEvent) => {
            if (event.action === MouseAction.Move && recordIndex !== this.hoveredIndex) {
              this.previewIndex(recordIndex);
            }
          })
          .onClick(() => {
            this.selectIndex(recordIndex);
          })
          .id(`logs-commit-index-tick-${tickIndex}`)
        }, (recordIndex: number) => String(recordIndex))
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

    }
    .width(RAIL_WIDTH)
    .height('100%')
    .alignContent(Alignment.TopStart)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: { right: 1 }, color: this.tokens.borderColor })
    .onHover((isHover: boolean) => {
      if (!isHover) {
        this.hoveredIndex = -1;
      }
    })
    .onMouse((event: MouseEvent) => {
      if (event.action === MouseAction.Move) {
        this.previewAt(event.y);
      }
    })
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      if (typeof newValue.height === 'number') {
        this.railHeight = newValue.height;
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.touches.length === 0) {
        return;
      }
      const touch = event.touches[0];
      if (touch.type === TouchType.Down || touch.type === TouchType.Move) {
        this.previewAt(touch.y);
      } else if (touch.type === TouchType.Up) {
        const index = CommitIndexMath.indexForPosition(touch.y, this.railHeight, this.checkIns.length);
        this.selectIndex(index);
        this.hoveredIndex = -1;
      }
    })
    .id('logs-commit-index-rail')
  }
}
