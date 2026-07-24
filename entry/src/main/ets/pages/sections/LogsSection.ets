import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';
import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../common/ThemeTokens';
import { CommitContentText } from '../components/CommitContentText';
import { CommitIndexRail } from '../components/CommitIndexRail';
import { CommitSearchPopover } from '../components/CommitSearchPopover';

enum LogsSummaryKind {
  ACTIVITY = 'activity',
  STORAGE = 'storage',
  EMPTY = 'empty',
}

@Component
export struct LogsSection {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  @Prop checkIns: CheckIn[];
  @Prop totalCommitCount: number;
  @State private selectedCommitKey: string = '';
  private commitScroller: Scroller = new Scroller();

  private commitKey(checkIn: CheckIn): string {
    return `${checkIn.date}-${checkIn.timestamp}`;
  }

  private selectedCommitIndex(): number {
    if (this.checkIns.length === 0) {
      return -1;
    }
    const selectedIndex = this.checkIns.findIndex((checkIn: CheckIn) =>
      this.commitKey(checkIn) === this.selectedCommitKey);
    return selectedIndex >= 0 ? selectedIndex : 0;
  }

  private commitSequence(index: number): string {
    return String(this.checkIns.length - index).padStart(3, '0');
  }

  private selectCommit(index: number, scroll: boolean = true, smooth: boolean = true): void {
    if (index >= 0 && index < this.checkIns.length) {
      const key = this.commitKey(this.checkIns[index]);
      if (key !== this.selectedCommitKey) {
        this.selectedCommitKey = key;
      }
      if (scroll) {
        this.commitScroller.scrollToIndex(index, smooth, ScrollAlign.START);
      }
    }
  }

  private selectCommitKey(key: string): void {
    const index = this.checkIns.findIndex((checkIn: CheckIn) => this.commitKey(checkIn) === key);
    if (index >= 0) {
      this.selectCommit(index);
    }
  }

  private formatTimestamp(timestamp: number): string {
    const date = new Date(timestamp);
    const year = String(date.getFullYear());
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');
    return `${year}.${month}.${day} / ${hour}:${minute}`;
  }

  @Builder
  private sectionLabel(index: string, label: string) {
    Row() {
      Text(index)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text(label)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')
        .margin({ left: Spacing.xs })
    }
    .width('100%')
    .padding({ bottom: Spacing.xs })
  }

  @Builder
  private summaryRow(kind: LogsSummaryKind) {
    Row() {
      Column() {
        Text() {
          if (kind === LogsSummaryKind.ACTIVITY) {
            Span(this.uiLabels.activityStream)
          } else if (kind === LogsSummaryKind.STORAGE) {
            Span(this.uiLabels.storageMode)
          } else {
            Span(this.uiLabels.noCommitsYet)
          }
        }
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .maxLines(1)

        Text() {
          if (kind === LogsSummaryKind.ACTIVITY) {
            Span(this.uiLabels.localRecords)
          } else if (kind === LogsSummaryKind.STORAGE) {
            Span(this.uiLabels.privateAppData)
          } else {
            Span(this.uiLabels.awaitingCalendarInput)
          }
        }
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text() {
        if (kind === LogsSummaryKind.ACTIVITY) {
          Span(`${this.totalCommitCount}`)
        } else if (kind === LogsSummaryKind.STORAGE) {
          Span(this.uiLabels.onDevice)
        } else {
          Span('0')
        }
      }
        .fontSize(11)
        .fontWeight(800)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('monospace')
        .textAlign(TextAlign.End)
        .maxLines(1)
    }
    .width('100%')
    .height(62)
    .padding({ left: Spacing.md, right: Spacing.md })
  }

  @Builder
  private commitListItem(checkIn: CheckIn, index: number) {
    Column() {
      Row() {
        Text(`#${this.commitSequence(index)}`)
          .fontSize(11)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .id(`logs-commit-sequence-${index}`)

        Text(this.formatTimestamp(checkIn.timestamp))
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ left: Spacing.xs })
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .maxLines(1)
          .id(`logs-commit-timestamp-${index}`)
      }
      .width('100%')
      .padding({
        left: Spacing.md,
        right: Spacing.md + 40,
        top: Spacing.md,
        bottom: Spacing.sm,
      })

      CommitContentText({
        content: checkIn.content,
        sequence: `#${this.commitSequence(index)}`,
        timestamp: this.formatTimestamp(checkIn.timestamp),
        componentId: `logs-commit-content-${index}`,
      })
      .width('100%')
      .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.md })
    }
    .width('100%')
    .constraintSize({ minHeight: 92 })
    .backgroundColor(index === this.selectedCommitIndex() ? this.tokens.brandLight : this.tokens.bgSurface)
    .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
    .id(`logs-commit-item-${index}`)
  }

  @Builder
  private commitList() {
    List({ scroller: this.commitScroller }) {
      ForEach(this.checkIns, (checkIn: CheckIn, index: number) => {
        ListItem() {
          this.commitListItem(checkIn, index)
        }
      }, (checkIn: CheckIn) => this.commitKey(checkIn))
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
    .onScrollIndex((start: number) => {
      this.selectCommit(start, false);
    })
    .id('logs-commit-list')
  }

  build() {
    Column() {
      this.sectionLabel('01', this.uiLabels.summary)

      Column() {
        this.summaryRow(LogsSummaryKind.ACTIVITY)
        Divider().color(this.tokens.borderColor).strokeWidth(1)
        this.summaryRow(LogsSummaryKind.STORAGE)
      }
      .width('100%')
      .backgroundColor(this.tokens.bgSurface)
      .border({ width: 1, color: this.tokens.borderColor })
      .borderRadius(Radius.none)

      Blank().height(Spacing.lg)

      this.sectionLabel('02', this.uiLabels.commits)

      Stack() {
        if (this.checkIns.length === 0) {
          this.summaryRow(LogsSummaryKind.EMPTY)
        } else {
          Row() {
            CommitIndexRail({
              checkIns: this.checkIns,
              selectedIndex: this.selectedCommitIndex(),
              onPreview: (index: number) => this.selectCommit(index, true, false),
              onSelect: (index: number) => this.selectCommit(index),
            })

            Stack() {
              this.commitList()

              CommitSearchPopover({
                checkIns: this.checkIns,
                onSelect: (key: string) => this.selectCommitKey(key),
              })
            }
            .layoutWeight(1)
            .height('100%')
            .alignContent(Alignment.TopEnd)
          }
          .width('100%')
          .height('100%')
          .backgroundColor(this.tokens.bgSurface)
          .border({ width: 1, color: this.tokens.borderColor })
          .borderRadius(Radius.none)
          .id('logs-commit-detail')
        }
      }
      .width('100%')
      .layoutWeight(1)
      .constraintSize({ minHeight: 180 })
      .alignContent(Alignment.TopStart)
      .id('logs-commit-workspace')
    }
    .width('100%')
    .height('100%')
    .padding({ top: Spacing.lg, bottom: Spacing.xl })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}
