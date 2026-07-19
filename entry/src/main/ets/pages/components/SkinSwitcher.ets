/**
 * Humble View: Theme switcher — 4 circular buttons.
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
      ForEach(this.themes, (theme: SkinTheme) => {
        this.skinButton(theme)
      })
    }
    .justifyContent(FlexAlign.Center)
    .padding({ top: Spacing.xs, bottom: Spacing.xs })
    .width('100%')
  }

  @Builder
  skinButton(theme: SkinTheme) {
    Column() {
      Column()
        .width(24)
        .height(24)
        .borderRadius(12)
        .backgroundColor(ThemePalette[theme].brandPrimary)
        .border({
          width: this.themeName === theme ? 3 : 0,
          color: this.tokens.textPrimary,
        })

      Text(ThemeNames[theme])
        .fontSize(9)
        .fontColor(this.tokens.textMuted)
        .margin({ top: 2 })
        .maxLines(1)
    }
    .alignItems(HorizontalAlign.Center)
    .margin({ left: Spacing.xs, right: Spacing.xs })
    .stateStyles({
      pressed: {
        .scale({ x: 0.92, y: 0.92 })
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
