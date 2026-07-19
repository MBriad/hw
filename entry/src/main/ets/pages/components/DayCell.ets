/**
 * Humble View: A single day cell on the heatmap grid.
 * Renders level-based color from the skin config. Emits tap intent.
 */
import { HeatmapCell } from '../../domain/Streak';
import { SkinConfig } from '../../domain/SkinTheme';

@Component
export struct DayCell {
  @Prop cell: HeatmapCell;
  @Prop skinConfig: SkinConfig;
  @Prop isSelected: boolean = false;
  @Prop isToday: boolean = false;
  onTap?: () => void;

  build() {
    Column() {
      Text(this.cell.date.split('-')[2]) // Day number only
        .fontSize(9)
        .fontColor(this.isSelected ? this.skinConfig.textOnPrimary : this.skinConfig.textOnSurface)
        .textAlign(TextAlign.Center)
    }
    .width(36)
    .height(36)
    .borderRadius(6)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getCellColor())
    .border({
      width: this.isSelected ? 2 : (this.isToday ? 1 : 0),
      color: this.isSelected ? this.skinConfig.accent :
             (this.isToday ? this.skinConfig.border : Color.Transparent),
    })
    .opacity(this.cell.level > 0 ? 1.0 : 0.5)
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }

  private getCellColor(): string {
    if (this.cell.level >= 4) return this.skinConfig.primaryDark;
    if (this.cell.level >= 3) return this.skinConfig.primary;
    if (this.cell.level >= 2) return this.skinConfig.accent;
    if (this.cell.level >= 1) return this.skinConfig.surfaceSecondary;
    return this.skinConfig.cellEmpty;
  }
}
