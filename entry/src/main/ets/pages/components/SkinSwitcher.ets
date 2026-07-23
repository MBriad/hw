/**
 * Humble View: Theme switcher with four compact color swatches.
 * Consumes DesignTokens + themeName provided by the entry page.
 */
import { SkinTheme, DesignTokens, ThemePalette } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct SkinSwitcher {
  @Consume tokens: DesignTokens;
  @Consume themeName: SkinTheme;
  onSwitch?: (theme: SkinTheme) => void;

  private readonly themes: SkinTheme[] = [
    SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL
  ];

  private themeLabel(theme: SkinTheme): string {
    if (theme === SkinTheme.DARK) {
      return 'DARK';
    }
    if (theme === SkinTheme.PINK) {
      return 'PINK';
    }
    if (theme === SkinTheme.PASTEL) {
      return 'PASTEL';
    }
    return 'LIGHT';
  }

  build() {
    Row() {
      ForEach(this.themes, (theme: SkinTheme) => {
        this.skinButton(theme)
      })
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

      Text(this.themeLabel(theme))
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
    .onClick(() => {
      if (this.onSwitch) {
        this.onSwitch(theme);
      }
    })
  }
}
