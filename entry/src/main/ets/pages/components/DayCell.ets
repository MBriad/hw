/**
 * Humble View: A single day cell on the heatmap grid.
 * Consumes page-provided DesignTokens. Emits tap intent.
 */
import { HeatmapCell } from '../../domain/Streak';
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';
import { ColorMetrics } from '@kit.ArkUI';

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
    .width(Spacing.calendarCell)
    .height(Spacing.calendarCell)
    .padding({ left: Spacing.xxs, top: Spacing.xxs })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.getCellColor())
    .border({
      width: this.isSelected ? 2 : 1,
      color: this.isSelected ? this.tokens.brandAccent : this.tokens.borderColor,
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
   *   1             → brandPrimary at 20% opacity
   *   2             → brandPrimary at 45% opacity
   *   3             → brandPrimary at 70% opacity
   *   4             → brandPrimary at 100% opacity
   */
  private getCellColor(): ResourceColor {
    if (this.cell.level >= 1) {
      const opacity = this.cell.level >= 4 ? 1 :
        this.cell.level >= 3 ? 0.7 :
        this.cell.level >= 2 ? 0.45 : 0.2;
      const primary: ColorMetrics = ColorMetrics.resourceColor(this.tokens.brandPrimary);
      return ColorMetrics.rgba(primary.red, primary.green, primary.blue, opacity).color;
    }
    if (this.isToday) return this.tokens.brandLight;
    return this.tokens.bgSurface;
  }

  private getTextColor(): ResourceColor {
    if (this.cell.level >= 3) return Color.White;
    if (this.cell.level >= 1) return this.tokens.textPrimary;
    if (this.isToday) return this.tokens.brandText;
    return this.tokens.textMuted;
  }
}
