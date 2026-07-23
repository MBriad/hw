import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';
import { DesignTokens } from '../../domain/SkinTheme';
import { HeatmapCell } from '../../domain/Streak';
import { HeatmapGrid } from '../components/HeatmapGrid';

@Component
export struct CalendarSection {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  @Prop cells: HeatmapCell[];
  @Prop selectedDate: string;
  @Prop todayString: string;
  @Prop longestMonthStreak: number;
  @Prop monthCommitCount: number;
  onCellTap?: (date: string) => void;

  build() {
    Scroll() {
      Column() {
        Row() {
          Text(this.uiLabels.calendarView)
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Blank()

          Text(`${this.cells.length} ${this.uiLabels.daysUnit}`)
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .height(38)
        .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })

        HeatmapGrid({
          cells: this.cells,
          selectedDate: this.selectedDate,
          todayString: this.todayString,
          onCellTap: (date: string) => {
            if (this.onCellTap) {
              this.onCellTap(date);
            }
          }
        })
          .width('100%')
          .margin({ top: Spacing.sm })

        Row() {
          Column() {
            Text(this.uiLabels.bestRun)
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')

            Row() {
              Text(`${this.longestMonthStreak}`)
                .fontSize(42)
                .fontWeight(900)
                .fontColor(this.tokens.textPrimary)

              Text(this.uiLabels.daysUnit)
                .fontSize(10)
                .fontWeight(700)
                .fontColor(this.tokens.textMuted)
                .fontFamily('monospace')
                .margin({ left: Spacing.xxs, bottom: Spacing.xs })
            }
            .alignItems(VerticalAlign.Bottom)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text(this.uiLabels.monthCommits)
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')

            Text(`${this.monthCommitCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.sm, bottom: Spacing.lg })
        .margin({ top: Spacing.sm })
        .border({ width: { top: 1 }, color: this.tokens.textPrimary })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
