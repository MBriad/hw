/**
 * Humble View: Check-in input area at the bottom of the heatmap page.
 * Shows selected date, text input, and "点亮" button.
 */
import { SkinConfig, SkinTheme } from '../../domain/SkinTheme';

@Component
export struct CheckInInput {
  @Prop selectedDate: string;
  @Prop skinConfig: SkinConfig;
  @State inputText: string = '';
  onLightUp?: (text: string) => void;

  build() {
    Column() {
      // Selected date label
      Text(this.getDateLabel())
        .fontSize(14)
        .fontColor(this.skinConfig.textOnSurface)
        .padding({ bottom: 8 })

      // Input row
      Row() {
        TextInput({ placeholder: '今天做了什么？', text: this.inputText })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.skinConfig.surfaceSecondary)
          .borderRadius(8)
          .fontColor(this.skinConfig.textOnSurface)
          .onChange((value: string) => {
            this.inputText = value;
          })

        Button('点亮')
          .fontSize(14)
          .fontColor(this.skinConfig.textOnPrimary)
          .backgroundColor(this.skinConfig.primary)
          .borderRadius(8)
          .height(44)
          .padding({ left: 16, right: 16 })
          .margin({ left: 8 })
          .enabled(this.inputText.trim().length > 0 && this.selectedDate.length > 0)
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
    .padding(16)
    .backgroundColor(this.skinConfig.surface)
    .borderRadius({ topLeft: 16, topRight: 16 })
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
