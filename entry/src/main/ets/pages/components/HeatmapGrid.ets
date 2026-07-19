/**
 * Humble View: 7-column calendar grid for a single month.
 * Renders day-of-week headers + Grid of DayCells.
 */
import { HeatmapCell } from '../../domain/Streak';
import { SkinConfig } from '../../domain/SkinTheme';
import { DayCell } from './DayCell';

@Component
export struct HeatmapGrid {
  @Prop cells: HeatmapCell[];
  @Prop skinConfig: SkinConfig;
  @Prop selectedDate: string;
  @Prop todayString: string;
  onCellTap?: (date: string) => void;

  private readonly dayLabels: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  build() {
    Column() {
      // Day-of-week header
      Row() {
        ForEach(this.dayLabels, (label: string, index: number) => {
          Text(label)
            .fontSize(10)
            .fontColor(this.skinConfig.textOnSurface)
            .width(40)
            .textAlign(TextAlign.Center)
            .opacity(0.6)
        })
      }
      .width('100%')
      .padding({ bottom: 4 })

      // Calendar grid
      Grid() {
        // Empty cells for month offset (weekday of 1st day, Monday=0)
        ForEach(this.getOffsetCells(), (_: number) => {
          GridItem() {
            Column().width(36).height(36)
          }
        })

        // Day cells
        ForEach(this.cells, (cell: HeatmapCell) => {
          GridItem() {
            DayCell({
              cell: cell,
              skinConfig: this.skinConfig,
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

  /**
   * Calculate empty padding cells before the 1st of month.
   * Monday = 0. E.g. if July 1 2026 is Wednesday, offset = 2.
   */
  private getOffsetCells(): number[] {
    if (this.cells.length === 0) return [];
    const firstDate = this.cells[0].date;
    const parts = firstDate.split('-');
    const year = parseInt(parts[0]);
    const month = parseInt(parts[1]);
    const day = parseInt(parts[2]);
    // getDay() returns 0=Sun, 1=Mon,... 6=Sat; we want Mon=0
    let jsDay = new Date(year, month - 1, day).getDay();
    let offset = (jsDay === 0) ? 6 : jsDay - 1;
    const result: number[] = [];
    for (let i = 0; i < offset; i++) {
      result.push(i);
    }
    return result;
  }
}
