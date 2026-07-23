import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';
import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../domain/SkinTheme';

enum LogsSectionKind {
  SUMMARY = 'summary',
  COMMITS = 'commits',
}

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

  @Builder
  private sectionLabel(index: string, kind: LogsSectionKind) {
    Row() {
      Text(index)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === LogsSectionKind.SUMMARY) {
          Span(this.uiLabels.summary)
        } else {
          Span(this.uiLabels.commits)
        }
      }
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
  private commitRow(checkIn: CheckIn, sequence: number) {
    Row() {
      Column() {
        Text(checkIn.content)
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(checkIn.date.replace(/-/g, '.'))
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(String(sequence).padStart(3, '0'))
        .fontSize(11)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')
    }
    .width('100%')
    .height(62)
    .padding({ left: Spacing.md, right: Spacing.md })
  }

  build() {
    Scroll() {
      Column() {
        this.sectionLabel('01', LogsSectionKind.SUMMARY)

        Column() {
          this.summaryRow(LogsSummaryKind.ACTIVITY)

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.summaryRow(LogsSummaryKind.STORAGE)
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('02', LogsSectionKind.COMMITS)

        Column() {
          if (this.checkIns.length === 0) {
            this.summaryRow(LogsSummaryKind.EMPTY)
          } else {
            ForEach(this.checkIns, (checkIn: CheckIn, index: number) => {
              if (index > 0) {
                Divider()
                  .color(this.tokens.borderColor)
                  .strokeWidth(1)
              }
              this.commitRow(checkIn, this.checkIns.length - index)
            }, (checkIn: CheckIn) => `${checkIn.date}-${checkIn.timestamp}`)
          }
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ top: Spacing.lg, bottom: Spacing.xl })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
