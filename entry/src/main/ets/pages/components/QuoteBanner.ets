/**
 * Humble View: Semi-transparent quote banner for easter egg voicelines.
 * Slides up from bottom, stays 2.5s, auto-dismisses. Tap to dismiss early.
 */
import { DesignTokens } from '../../domain/SkinTheme';
import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct QuoteBanner {
  @Consume tokens: DesignTokens;
  @Prop quote: string = '';
  @State private visible: boolean = false;
  @State private translateY: number = 100;

  show(): void {
    this.visible = true;
    this.translateY = 100;
    // Animate in
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.translateY = 0;
    });
    // Auto-dismiss
    setTimeout(() => {
      this.dismiss();
    }, 2500);
  }

  private dismiss(): void {
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.translateY = 100;
    });
    setTimeout(() => {
      this.visible = false;
    }, 250);
  }

  build() {
    if (this.visible) {
      Column() {
        Row() {
          Text(this.quote)
            .fontSize(13)
            .fontColor(this.tokens.textPrimary)
            .fontStyle(FontStyle.Italic)
            .lineHeight(20)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.sm })
        .backgroundColor('rgba(0,0,0,0.75)')
        .borderRadius({ topLeft: Radius.lg, topRight: Radius.lg })
      }
      .width('100%')
      .position({ x: 0, y: '100%' })
      .translate({ y: this.translateY })
      .onClick(() => {
        this.dismiss();
      })
    }
  }
}
