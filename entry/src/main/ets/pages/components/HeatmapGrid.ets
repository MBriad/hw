/**
 * Humble View: 7-column calendar grid for a single month.
 * Consumes page-provided DesignTokens.
 */
import { HeatmapCell } from '../../domain/Streak';
import { UILabels, labelsForLocale } from '../../common/UILabels';
import { DesignTokens } from '../../domain/SkinTheme';
import { DayCell } from './DayCell';
import { Spacing } from '../../common/SpacingTokens';

const CALENDAR_ROWS = 6;

@Component
export struct HeatmapGrid {
  @Consume tokens: DesignTokens;
  @Consume locale: string;
  @Prop cells: HeatmapCell[];
  @Prop selectedDate: string;
  @Prop todayString: string;
  onCellTap?: (date: string) => void;

  private labels(): UILabels {
    return labelsForLocale(this.locale);
  }

  private get dayLabels(): string[] {
    return [this.labels().dayMo, this.labels().dayTu, this.labels().dayWe, this.labels().dayTh,
            this.labels().dayFr, this.labels().daySa, this.labels().daySu];
  }

  build() {
    Column() {
      // Day-of-week header
      Row() {
        ForEach(this.dayLabels, (label: string, _index: number) => {
          Text(label)
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textSecondary)
            .fontFamily('monospace')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding({ bottom: Spacing.xs })

      // Calendar grid
      Grid() {
        ForEach(this.getOffsetCells(), (_: number) => {
          GridItem() {
            Column().width(Spacing.calendarCell).height(Spacing.calendarCell)
          }
          .align(Alignment.Center)
        })

        ForEach(this.cells, (cell: HeatmapCell) => {
          GridItem() {
            DayCell({
              cell: cell,
              isSelected: cell.date === this.selectedDate,
              isToday: cell.date === this.todayString,
              onTap: () => {
                if (this.onCellTap) {
                  this.onCellTap(cell.date);
                }
              }
            })
          }
          .align(Alignment.Center)
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(Spacing.xxs)
      .rowsGap(Spacing.xxs)
      .height(CALENDAR_ROWS * Spacing.calendarCell + (CALENDAR_ROWS - 1) * Spacing.xxs)
      .width('100%')
    }
    .width('100%')
  }

  private getOffsetCells(): number[] {
    if (this.cells.length === 0) return [];
    const firstDate = this.cells[0].date;
    const parts = firstDate.split('-');
    const year = parseInt(parts[0]);
    const month = parseInt(parts[1]);
    const day = parseInt(parts[2]);
    let jsDay = new Date(year, month - 1, day).getDay();
    let offset = (jsDay === 0) ? 6 : jsDay - 1;
    const result: number[] = [];
    for (let i = 0; i < offset; i++) {
      result.push(i);
    }
    return result;
  }
}
