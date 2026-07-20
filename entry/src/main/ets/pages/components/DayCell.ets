/**
 * Humble View: A single day cell on the heatmap grid.
 * Consumes DesignTokens from ThemeProvider. Emits tap intent.
 */
import { HeatmapCell } from '../../domain/Streak';
import { DesignTokens } from '../../domain/SkinTheme';
import { Radius } from '../../common/RadiusTokens';

const CELL_SIZE = 44;

@Component
export struct DayCell {
  @Consume tokens: DesignTokens;
  @Prop cell: HeatmapCell;
  @Prop isSelected: boolean = false;
  @Prop isToday: boolean = false;
  onTap?: () => void;

  build() {
    Column() {
      Text(this.cell.date.split('-')[2])
        .fontSize(12)
        .fontWeight(500)
        .fontColor(this.isSelected ? Color.White : this.tokens.textSecondary)
        .textAlign(TextAlign.Center)
    }
    .width(CELL_SIZE)
    .height(CELL_SIZE)
    .borderRadius(Radius.md)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getCellColor())
    .border({
      width: this.isSelected ? 2 : (this.isToday ? 1 : 0),
      color: this.isSelected ? this.tokens.brandAccent :
             (this.isToday ? this.tokens.borderColor : Color.Transparent),
    })
    .opacity(this.cell.level > 0 ? 1.0 : 0.5)
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.92, y: 0.92 })
      }
    })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }

  /**
   * Map heatmap level to design tokens:
   *   0 (empty)     → bgSurfacePressed
   *   1             → brandLight
   *   2             → brandPrimary (50% opacity)
   *   3             → brandPrimary
   *   4             → brandActive
   */
  private getCellColor(): ResourceColor {
    if (this.cell.level >= 4) return this.tokens.brandActive;
    if (this.cell.level >= 3) return this.tokens.brandPrimary;
    if (this.cell.level >= 2) return this.tokens.brandText;
    if (this.cell.level >= 1) return this.tokens.brandLight;
    return this.tokens.bgSurfacePressed;
  }
}
