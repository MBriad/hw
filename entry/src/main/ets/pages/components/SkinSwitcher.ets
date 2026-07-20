/**
 * Humble View: Theme switcher with four compact color swatches.
 * Consumes DesignTokens + themeName from ThemeProvider.
 */
import { SkinTheme, DesignTokens, ThemeNames, ThemePalette } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct SkinSwitcher {
  @Consume tokens: DesignTokens;
  @Consume themeName: SkinTheme;
  onSwitch?: (theme: SkinTheme) => void;

  private readonly themes: SkinTheme[] = [
    SkinTheme.LIGHT, SkinTheme.DARK, SkinTheme.PINK, SkinTheme.PASTEL
  ];

  build() {
    Row() {
      Column() {
        Text('THEME PROFILE')
          .fontSize(10)
          .fontWeight(700)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')

        Text(ThemeNames[this.themeName])
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .margin({ top: Spacing.xxs })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row() {
        ForEach(this.themes, (theme: SkinTheme) => {
          this.skinButton(theme)
        })
      }
    }
    .height(52)
    .width('100%')
    .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
  }

  @Builder
  skinButton(theme: SkinTheme) {
    Column()
      .width(24)
      .height(24)
      .backgroundColor(ThemePalette[theme].brandPrimary)
      .border({
        width: this.themeName === theme ? 2 : 1,
        color: this.themeName === theme ? this.tokens.textPrimary : this.tokens.borderColor,
      })
    .margin({ left: Spacing.xs })
    .stateStyles({
      pressed: {
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
