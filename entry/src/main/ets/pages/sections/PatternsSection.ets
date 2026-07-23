import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';
import { UsagePattern } from '../../domain/EasterEgg';
import { DesignTokens } from '../../domain/SkinTheme';

enum PatternsSectionKind {
  ENGINE = 'engine',
  MILESTONES = 'milestones',
  SIGNALS = 'signals',
}

enum PatternsSummaryKind {
  ENGINE = 'engine',
  LEARNED = 'learned',
  EMPTY = 'empty',
}

enum MilestoneKind {
  SIGNAL = 'signal',
  RHYTHM = 'rhythm',
  HABIT = 'habit',
  MASTERY = 'mastery',
}

@Component
export struct PatternsSection {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  @Prop usagePatterns: UsagePattern[];

  @Builder
  private sectionLabel(index: string, kind: PatternsSectionKind) {
    Row() {
      Text(index)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === PatternsSectionKind.ENGINE) {
          Span(this.uiLabels.engine)
        } else if (kind === PatternsSectionKind.MILESTONES) {
          Span(this.uiLabels.milestones)
        } else {
          Span(this.uiLabels.signals)
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
  private summaryRow(kind: PatternsSummaryKind) {
    Row() {
      Column() {
        Text() {
          if (kind === PatternsSummaryKind.ENGINE) {
            Span(this.uiLabels.patternEngine)
          } else if (kind === PatternsSummaryKind.LEARNED) {
            Span(this.uiLabels.learnedPatterns)
          } else {
            Span(this.uiLabels.noPatternsYet)
          }
        }
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .maxLines(1)

        Text() {
          if (kind === PatternsSummaryKind.ENGINE) {
            Span(this.uiLabels.localInference)
          } else if (kind === PatternsSummaryKind.LEARNED) {
            Span(this.uiLabels.activeTerms)
          } else {
            Span(this.uiLabels.awaitingLocalActivity)
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
        if (kind === PatternsSummaryKind.ENGINE) {
          Span(this.uiLabels.listening)
        } else if (kind === PatternsSummaryKind.LEARNED) {
          Span(`${this.usagePatterns.length}`)
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
  private milestone(value: string, kind: MilestoneKind) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(900)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === MilestoneKind.SIGNAL) {
          Span(this.uiLabels.signal)
        } else if (kind === MilestoneKind.RHYTHM) {
          Span(this.uiLabels.rhythm)
        } else if (kind === MilestoneKind.HABIT) {
          Span(this.uiLabels.habit)
        } else {
          Span(this.uiLabels.mastery)
        }
      }
        .fontSize(8)
        .fontWeight(700)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')
        .margin({ top: Spacing.xxs })
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private patternRow(pattern: UsagePattern) {
    Row() {
      Column() {
        Text(pattern.term.toUpperCase())
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(pattern.nextMilestone > 0 ? `${this.uiLabels.nextMilestone}${pattern.nextMilestone}` : this.uiLabels.milestoneComplete)
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(`x${pattern.count}`)
        .fontSize(14)
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
        this.sectionLabel('01', PatternsSectionKind.ENGINE)

        Column() {
          this.summaryRow(PatternsSummaryKind.ENGINE)

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.summaryRow(PatternsSummaryKind.LEARNED)
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('02', PatternsSectionKind.MILESTONES)

        Row() {
          this.milestone('03', MilestoneKind.SIGNAL)
          Divider().vertical(true).color(this.tokens.borderColor).strokeWidth(1)
          this.milestone('07', MilestoneKind.RHYTHM)
          Divider().vertical(true).color(this.tokens.borderColor).strokeWidth(1)
          this.milestone('14', MilestoneKind.HABIT)
          Divider().vertical(true).color(this.tokens.borderColor).strokeWidth(1)
          this.milestone('30', MilestoneKind.MASTERY)
        }
        .width('100%')
        .height(72)
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('03', PatternsSectionKind.SIGNALS)

        Column() {
          if (this.usagePatterns.length === 0) {
            this.summaryRow(PatternsSummaryKind.EMPTY)
          } else {
            ForEach(this.usagePatterns, (pattern: UsagePattern, index: number) => {
              if (index > 0) {
                Divider()
                  .color(this.tokens.borderColor)
                  .strokeWidth(1)
              }
              this.patternRow(pattern)
            }, (pattern: UsagePattern) => pattern.term)
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
