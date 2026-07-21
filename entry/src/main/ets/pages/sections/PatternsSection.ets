import { Spacing } from '../../common/SpacingTokens';
import { UsagePattern } from '../../domain/EasterEgg';
import { DesignTokens } from '../../domain/SkinTheme';

@Component
export struct PatternsSection {
  @Consume tokens: DesignTokens;
  @Prop usagePatterns: UsagePattern[];

  build() {
    Scroll() {
      Column() {
        Column() {
          Text('USAGE_CORE')
            .fontSize(28)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('LOCAL PATTERN ENGINE // NO FIXED KEYWORDS')
            .fontSize(9)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        Row() {
          Column() {
            Text('LEARNED PATTERNS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.usagePatterns.length}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('MILESTONES')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text('03 / 07 / 14 / 30')
              .fontSize(12)
              .fontWeight(700)
              .fontColor(this.tokens.textPrimary)
              .fontFamily('monospace')
              .margin({ top: Spacing.sm })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.md, bottom: Spacing.md })
        .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })

        if (this.usagePatterns.length === 0) {
          Text('SIGNAL: LISTENING...')
            .width('100%')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .padding({ top: Spacing.xl, bottom: Spacing.xl })
        } else {
          ForEach(this.usagePatterns, (pattern: UsagePattern) => {
            Row() {
              Column() {
                Text(pattern.term.toUpperCase())
                  .fontSize(15)
                  .fontWeight(800)
                  .fontColor(this.tokens.textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(pattern.nextMilestone > 0 ? `NEXT // ${pattern.nextMilestone}` : 'LEVEL // MAX')
                  .fontSize(9)
                  .fontWeight(700)
                  .fontColor(this.tokens.textMuted)
                  .fontFamily('monospace')
                  .margin({ top: Spacing.xxs })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(`x${pattern.count}`)
                .fontSize(24)
                .fontWeight(900)
                .fontColor(this.tokens.brandPrimary)
                .fontFamily('monospace')
            }
            .width('100%')
            .padding({ top: Spacing.sm, bottom: Spacing.sm })
            .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
          }, (pattern: UsagePattern) => pattern.term)
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
