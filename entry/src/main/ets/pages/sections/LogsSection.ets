import { Spacing } from '../../common/SpacingTokens';
import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../domain/SkinTheme';

@Component
export struct LogsSection {
  @Consume tokens: DesignTokens;
  @Prop checkIns: CheckIn[];
  @Prop totalCommitCount: number;

  build() {
    Scroll() {
      Column() {
        Row() {
          Column() {
            Text('COMMIT_LOG')
              .fontSize(28)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
              .fontFamily('monospace')

            Text('LOCAL ACTIVITY STREAM')
              .fontSize(9)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(`${this.totalCommitCount}`)
            .fontSize(38)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
        }
        .width('100%')
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        if (this.checkIns.length === 0) {
          Text('AWAITING FIRST COMMIT...')
            .width('100%')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .padding({ top: Spacing.xl, bottom: Spacing.xl })
        } else {
          ForEach(this.checkIns, (checkIn: CheckIn, index: number) => {
            Row() {
              Column() {
                Text(checkIn.date.replace(/-/g, '.'))
                  .fontSize(10)
                  .fontWeight(700)
                  .fontColor(this.tokens.textMuted)
                  .fontFamily('monospace')

                Text(checkIn.content)
                  .fontSize(15)
                  .fontWeight(600)
                  .fontColor(this.tokens.textPrimary)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: Spacing.xxs })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(String(this.checkIns.length - index).padStart(3, '0'))
                .fontSize(12)
                .fontWeight(700)
                .fontColor(this.tokens.brandPrimary)
                .fontFamily('monospace')
            }
            .width('100%')
            .padding({ top: Spacing.sm, bottom: Spacing.sm })
            .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
          }, (checkIn: CheckIn) => `${checkIn.date}-${checkIn.timestamp}`)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
