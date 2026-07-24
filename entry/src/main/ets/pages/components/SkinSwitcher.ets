/**
 * Humble View: Theme switcher with four compact color swatches.
 * Consumes DesignTokens + themeName provided by the entry page.
 */
import { SkinTheme } from '../../domain/SkinTheme';
import { DesignTokens, ThemePalette } from '../../common/ThemeTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';

@Component
export struct SkinSwitcher {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  @Consume themeName: SkinTheme;
  onSwitch?: (theme: SkinTheme) => void;

  build() {
    Row() {
      this.skinButton(SkinTheme.LIGHT)
      this.skinButton(SkinTheme.DARK)
      this.skinButton(SkinTheme.PINK)
      this.skinButton(SkinTheme.PASTEL)
    }
    .height(64)
    .width('100%')
  }

  @Builder
  skinButton(theme: SkinTheme) {
    Column() {
      Column()
        .width(22)
        .height(22)
        .backgroundColor(ThemePalette[theme].brandPrimary)
        .border({
          width: this.themeName === theme ? 2 : 1,
          color: this.themeName === theme ? this.tokens.textPrimary : this.tokens.borderColor,
        })

      Text() {
        if (theme === SkinTheme.LIGHT) {
          Span(this.uiLabels.light)
        } else if (theme === SkinTheme.DARK) {
          Span(this.uiLabels.darkTheme)
        } else if (theme === SkinTheme.PINK) {
          Span(this.uiLabels.pink)
        } else {
          Span(this.uiLabels.pastel)
        }
      }
        .fontSize(8)
        .fontWeight(this.themeName === theme ? 800 : 600)
        .fontColor(this.themeName === theme ? this.tokens.textPrimary : this.tokens.textMuted)
        .fontFamily('monospace')
        .margin({ top: Spacing.xxs })
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeName === theme ? this.tokens.brandLight : this.tokens.bgSurface)
    .stateStyles({
      normal: {
        .backgroundColor(this.themeName === theme ? this.tokens.brandLight : this.tokens.bgSurface)
        .scale({ x: 1, y: 1 })
      },
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.88, y: 0.88 })
      }
    })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .id(`theme-${theme}`)
    .onClick(() => {
      if (this.onSwitch) {
        this.onSwitch(theme);
      }
    })
  }
}
