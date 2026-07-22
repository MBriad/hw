/** Subtle technical grid used as a non-interactive page background. */
import { DesignTokens } from '../../domain/SkinTheme';

@Component
export struct GridBackdrop {
  @Consume tokens: DesignTokens;

  private readonly verticalLines: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  private readonly horizontalLines: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

  build() {
    Stack() {
      ForEach(this.verticalLines, (index: number) => {
        Divider()
          .vertical(true)
          .height('100%')
          .strokeWidth(1)
          .color(this.tokens.borderColor)
          .opacity(0.32)
          .position({ x: `${index * 12.5}%`, y: 0 })
      }, (index: number) => `${index}_${this.tokens.borderColor}`)

      ForEach(this.horizontalLines, (index: number) => {
        Divider()
          .width('100%')
          .strokeWidth(1)
          .color(this.tokens.borderColor)
          .opacity(0.32)
          .position({ x: 0, y: `${index * 6.25}%` })
      }, (index: number) => `${index}_${this.tokens.borderColor}`)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }
}
