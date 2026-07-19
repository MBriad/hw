/**
 * Humble View: Check-in input area. Consumes DesignTokens from ThemeProvider.
 * Uses design system patterns: PrimaryButton + ThemedInput + stateStyles.
 */
import { DesignTokens } from '../../domain/SkinTheme';
import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';

@Component
export struct CheckInInput {
  @Consume tokens: DesignTokens;
  @Prop selectedDate: string;
  @State inputText: string = '';
  onLightUp?: (text: string) => void;

  build() {
    Column() {
      // Selected date label
      Text(this.getDateLabel())
        .fontSize(14)
        .fontColor(this.tokens.textSecondary)
        .padding({ bottom: Spacing.xs })

      // Input row
      Row() {
        TextInput({ placeholder: '今天做了什么？', text: this.inputText })
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor(this.tokens.textPrimary)
          .placeholderColor(this.tokens.textPlaceholder)
          .backgroundColor(this.tokens.bgSurface)
          .borderRadius(Radius.md)
          .border({ width: 1, color: this.tokens.borderColor })
          .padding({ left: Spacing.md, right: Spacing.md })
          .caretColor(this.tokens.brandPrimary)
          .stateStyles({
            focused: {
              .border({ width: 1.5, color: this.tokens.brandPrimary })
            }
          })
          .onChange((value: string) => {
            this.inputText = value;
          })

        Button('点亮')
          .fontSize(14)
          .fontWeight(600)
          .fontColor(Color.White)
          .backgroundColor(this.tokens.brandPrimary)
          .borderRadius(Radius.md)
          .height(44)
          .padding({ left: Spacing.md, right: Spacing.md })
          .margin({ left: Spacing.xs })
          .enabled(this.inputText.trim().length > 0 && this.selectedDate.length > 0)
          .stateStyles({
            pressed: {
              .backgroundColor(this.tokens.brandActive)
              .scale({ x: 0.97, y: 0.97 })
            }
          })
          .animation({ duration: 100 })
          .onClick(() => {
            if (this.onLightUp && this.inputText.trim().length > 0) {
              this.onLightUp(this.inputText.trim());
              this.inputText = '';
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Spacing.md)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: { top: 0.5 }, color: this.tokens.borderColor })
    .borderRadius({ topLeft: Radius.lg, topRight: Radius.lg })
  }

  private getDateLabel(): string {
    if (this.selectedDate.length === 0) {
      return '请选择日期';
    }
    const parts = this.selectedDate.split('-');
    if (parts.length === 3) {
      return `${parts[0]}年 ${parseInt(parts[1])}月 ${parseInt(parts[2])}日`;
    }
    return this.selectedDate;
  }
}
