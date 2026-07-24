import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';
import { DesignTokens } from '../../common/ThemeTokens';

@CustomDialog
export struct CommitDateSearchDialog {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  controller: CustomDialogController;
  initialDate: string = '';
  onConfirm?: (date: string) => void;
  @State private pickerDate: Date = new Date();

  aboutToAppear(): void {
    const parts = this.initialDate.split('-');
    if (parts.length === 3) {
      this.pickerDate = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    }
  }

  private selectedDateString(): string {
    return `${this.pickerDate.getFullYear()}-${String(this.pickerDate.getMonth() + 1).padStart(2, '0')}-${String(this.pickerDate.getDate()).padStart(2, '0')}`;
  }

  build() {
    Column() {
      Text(this.uiLabels.searchDate)
        .width('100%')
        .fontSize(13)
        .fontWeight(800)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('monospace')
        .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.md, bottom: Spacing.sm })

      Divider().color(this.tokens.borderColor).strokeWidth(1)

      DatePicker({
        start: new Date(1970, 0, 1),
        end: new Date(2100, 11, 31),
        selected: this.pickerDate,
      })
        .width('100%')
        .height(180)
        .onDateChange((value: Date) => {
          this.pickerDate = value;
        })
        .id('logs-date-picker')

      Row() {
        Text(this.uiLabels.searchCancel)
          .layoutWeight(1)
          .height(40)
          .fontSize(10)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .textAlign(TextAlign.Center)
          .backgroundColor(this.tokens.bgBase)
          .border({ width: 1, color: this.tokens.borderColor })
          .onClick(() => this.controller.close())
          .id('logs-date-cancel')

        Blank().width(Spacing.xs)

        Text(this.uiLabels.searchConfirm)
          .layoutWeight(1)
          .height(40)
          .fontSize(10)
          .fontWeight(800)
          .fontColor(this.tokens.brandText)
          .fontFamily('monospace')
          .textAlign(TextAlign.Center)
          .backgroundColor(this.tokens.brandPrimary)
          .borderRadius(Radius.none)
          .onClick(() => {
            const selected = this.selectedDateString();
            this.controller.close();
            if (this.onConfirm) {
              this.onConfirm(selected);
            }
          })
          .id('logs-date-confirm')
      }
      .width('100%')
      .padding({ left: Spacing.md, right: Spacing.md, bottom: Spacing.md })
    }
    .width('86%')
    .constraintSize({ maxWidth: 360 })
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: 1, color: this.tokens.borderColor })
    .borderRadius(Radius.none)
  }
}
