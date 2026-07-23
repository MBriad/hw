/**
 * Humble View: check-in input area. Consumes page-provided DesignTokens.
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
      Row() {
        Text('COMMIT TARGET')
          .fontSize(10)
          .fontWeight(700)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')

        Blank()

        Text(this.getDateLabel())
          .fontSize(10)
          .fontWeight(700)
          .fontColor(this.selectedDate.length > 0 ? this.tokens.textPrimary : this.tokens.textPlaceholder)
          .fontFamily('monospace')
      }
      .width('100%')
      .padding({ bottom: Spacing.xs })

      Row() {
        TextInput({ placeholder: 'LOG TODAY\'S PROGRESS', text: this.inputText })
          .layoutWeight(1)
          .height(48)
          .fontSize(14)
          .fontWeight(600)
          .fontColor(this.tokens.textPrimary)
          .placeholderColor(this.tokens.textPlaceholder)
          .backgroundColor(Color.Transparent)
          .borderRadius(Radius.none)
          .padding({ left: Spacing.xxs, right: Spacing.xs })
          .caretColor(this.tokens.brandPrimary)
          .onChange((value: string) => {
            this.inputText = value;
          })

        Button('COMMIT')
          .fontSize(13)
          .fontWeight(700)
          .fontFamily('monospace')
          .fontColor(this.canCommit() ? this.tokens.textPrimary : this.tokens.textPlaceholder)
          .backgroundColor(Color.Transparent)
          .borderRadius(Radius.none)
          .height(48)
          .padding({ left: Spacing.sm, right: Spacing.xxs })
          .enabled(this.inputText.trim().length > 0 && this.selectedDate.length > 0)
          .stateStyles({
            pressed: {
              .backgroundColor(this.tokens.bgSurfacePressed)
              .scale({ x: 0.94, y: 0.94 })
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
      .border({ width: { bottom: 2 }, color: this.tokens.textPrimary })
    }
    .width('100%')
  }

  private getDateLabel(): string {
    if (this.selectedDate.length === 0) {
      return 'NO DATE SELECTED';
    }
    return this.selectedDate.replace(/-/g, '.');
  }

  private canCommit(): boolean {
    return this.inputText.trim().length > 0 && this.selectedDate.length > 0;
  }
}
