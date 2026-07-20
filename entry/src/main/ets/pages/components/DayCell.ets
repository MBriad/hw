/**
 * Humble View: A single day cell on the heatmap grid.
 * Consumes DesignTokens from ThemeProvider. Emits tap intent.
 */
import { HeatmapCell } from '../../domain/Streak';
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';

const CELL_SIZE = 40;

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
        .fontWeight(700)
        .fontColor(this.getTextColor())
        .fontFamily('monospace')
    }
    .width(CELL_SIZE)
    .height(CELL_SIZE)
    .padding({ left: Spacing.xxs, top: Spacing.xxs })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.getCellColor())
    .border({
      width: this.isSelected ? 2 : 1,
      color: this.isSelected ? this.tokens.brandAccent :
             (this.isToday ? this.tokens.textPrimary : this.tokens.borderColor),
    })
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.96, y: 0.96 })
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
   *   0 (empty)     → bgSurface
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
    return this.tokens.bgSurface;
  }

  private getTextColor(): ResourceColor {
    if (this.cell.level >= 2) return Color.White;
    if (this.cell.level >= 1) return this.tokens.textPrimary;
    return this.tokens.textMuted;
  }
}
