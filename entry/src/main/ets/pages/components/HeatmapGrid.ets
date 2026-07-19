/**
 * Humble View: 7-column calendar grid for a single month.
 * Consumes DesignTokens from ThemeProvider.
 */
import { HeatmapCell } from '../../domain/Streak';
import { DesignTokens } from '../../domain/SkinTheme';
import { DayCell } from './DayCell';

@Component
export struct HeatmapGrid {
  @Consume tokens: DesignTokens;
  @Prop cells: HeatmapCell[];
  @Prop selectedDate: string;
  @Prop todayString: string;
  onCellTap?: (date: string) => void;

  private readonly dayLabels: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  build() {
    Column() {
      // Day-of-week header
      Row() {
        ForEach(this.dayLabels, (label: string, _index: number) => {
          Text(label)
            .fontSize(10)
            .fontColor(this.tokens.textMuted)
            .width(40)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding({ bottom: 4 })

      // Calendar grid
      Grid() {
        ForEach(this.getOffsetCells(), (_: number) => {
          GridItem() {
            Column().width(36).height(36)
          }
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
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(2)
      .columnsGap(2)
      .width('100%')
    }
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
