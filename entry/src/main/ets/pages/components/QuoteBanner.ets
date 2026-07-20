/**
 * Humble View: Semi-transparent quote banner for easter egg voicelines.
 * Slides up from bottom, stays 2.5s, auto-dismisses. Tap to dismiss early.
 */
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct QuoteBanner {
  @Consume tokens: DesignTokens;
  @Prop quote: string = '';
  @State private visible: boolean = false;
  @State private translateY: number = 100;

  aboutToAppear(): void {
    this.show();
  }

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
        Text('ACTRACE // SIGNAL RECEIVED')
          .fontSize(9)
          .fontWeight(700)
          .fontColor(this.tokens.brandAccent)
          .fontFamily('monospace')
          .width('100%')

        Text(this.quote)
          .fontSize(13)
          .fontWeight(600)
          .fontColor(this.tokens.bgSurface)
          .lineHeight(20)
          .margin({ top: Spacing.xs })
          .width('100%')
      }
      .width('100%')
      .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.sm })
      .backgroundColor(this.tokens.textPrimary)
      .border({ width: { top: 2 }, color: this.tokens.brandAccent })
      .position({ x: 0, y: '100%' })
      .markAnchor({ x: 0, y: '100%' })
      .translate({ y: this.translateY })
      .stateStyles({
        pressed: {
          .opacity(0.88)
        }
      })
      .onClick(() => {
        this.dismiss();
      })
    }
  }
}
