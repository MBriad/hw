import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UsagePattern } from '../../domain/EasterEgg';
import { DesignTokens } from '../../domain/SkinTheme';

@Component
export struct PatternsSection {
  @Consume tokens: DesignTokens;
  @Prop usagePatterns: UsagePattern[];

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
  private summaryRow(title: string, subtitle: string, value: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .maxLines(1)

        Text(subtitle)
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(value)
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
  private milestone(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(900)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('monospace')

      Text(label)
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

        Text(pattern.nextMilestone > 0 ? `NEXT MILESTONE // ${pattern.nextMilestone}` : 'MILESTONE // COMPLETE')
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
        this.sectionLabel('01', 'ENGINE')

        Column() {
          this.summaryRow('PATTERN ENGINE', 'LOCAL INFERENCE', 'LISTENING')

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.summaryRow('LEARNED PATTERNS', 'ACTIVE TERMS', `${this.usagePatterns.length}`)
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('02', 'MILESTONES')

        Row() {
          this.milestone('03', 'SIGNAL')
          Divider().vertical(true).color(this.tokens.borderColor).strokeWidth(1)
          this.milestone('07', 'RHYTHM')
          Divider().vertical(true).color(this.tokens.borderColor).strokeWidth(1)
          this.milestone('14', 'HABIT')
          Divider().vertical(true).color(this.tokens.borderColor).strokeWidth(1)
          this.milestone('30', 'MASTERY')
        }
        .width('100%')
        .height(72)
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('03', 'SIGNALS')

        Column() {
          if (this.usagePatterns.length === 0) {
            this.summaryRow('NO PATTERNS YET', 'AWAITING LOCAL ACTIVITY', '0')
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
