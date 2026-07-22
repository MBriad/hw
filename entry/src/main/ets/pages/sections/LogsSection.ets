import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../domain/SkinTheme';

@Component
export struct LogsSection {
  @Consume tokens: DesignTokens;
  @Prop checkIns: CheckIn[];
  @Prop totalCommitCount: number;

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
        this.sectionLabel('01', 'SUMMARY')

        Column() {
          this.summaryRow('ACTIVITY STREAM', 'LOCAL RECORDS', `${this.totalCommitCount}`)

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.summaryRow('STORAGE MODE', 'PRIVATE APP DATA', 'ON DEVICE')
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('02', 'COMMITS')

        Column() {
          if (this.checkIns.length === 0) {
            this.summaryRow('NO COMMITS YET', 'AWAITING CALENDAR INPUT', '0')
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
