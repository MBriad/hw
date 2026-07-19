/**
 * Humble View: Skin theme switcher — 3 circular buttons.
 */
import { SkinTheme, SkinConfig } from '../../domain/SkinTheme';

@Component
export struct SkinSwitcher {
  @Prop skinConfig: SkinConfig;
  @Prop currentSkin: SkinTheme;
  onSwitch?: (theme: SkinTheme) => void;

  build() {
    Row() {
      this.skinButton(SkinTheme.EVA, '#FF6B35')
      this.skinButton(SkinTheme.MIKU, '#39C5BB')
      this.skinButton(SkinTheme.CYBERPUNK, '#00FFFF')
    }
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 8 })
    .width('100%')
  }

  @Builder
  skinButton(theme: SkinTheme, color: string) {
    Column()
      .width(24)
      .height(24)
      .borderRadius(12)
      .backgroundColor(color)
      .border({
        width: this.currentSkin === theme ? 3 : 0,
        color: this.skinConfig.textOnSurface,
      })
      .margin({ left: 8, right: 8 })
      .onClick(() => {
        if (this.onSwitch) {
          this.onSwitch(theme);
        }
      })
  }
}
