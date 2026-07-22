import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DesignTokens } from '../../domain/SkinTheme';
import { CalendarDebugScenario } from '../DebugRuntime';

@CustomDialog
export struct CalendarLabDialog {
  @Consume tokens: DesignTokens;
  controller: CustomDialogController;
  onRun?: (scenario: CalendarDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text('CALENDAR LAB')
            .fontSize(24)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('sans-serif')
            .maxLines(1)

          Text('SYSTEM / MONTH NAVIGATION')
            .fontSize(8)
            .fontWeight(800)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .margin({ top: Spacing.xxs })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('[X]')
          .width(44)
          .height(44)
          .fontSize(11)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .textAlign(TextAlign.Center)
          .stateStyles({
            normal: {
              .backgroundColor(this.tokens.bgSurface)
            },
            pressed: {
              .backgroundColor(this.tokens.bgSurfacePressed)
              .scale({ x: 0.94, y: 0.94 })
            }
          })
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .height(84)
      .padding({ left: Spacing.lg, right: Spacing.sm })

      Divider()
        .color(this.tokens.borderColor)
        .strokeWidth(1)

      Column() {
        this.sectionLabel('01', 'STANDARD')

        Row() {
          this.labButton('PREVIOUS', CalendarDebugScenario.PREVIOUS_MONTH)
          Blank().width(Spacing.xs)
          this.labButton('NEXT', CalendarDebugScenario.NEXT_MONTH)
        }
        .width('100%')

        Row() {
          this.labButton('CURRENT', CalendarDebugScenario.CURRENT_MONTH)
          Blank().width(Spacing.xs)
          Blank().layoutWeight(1)
        }
        .width('100%')
        .margin({ top: Spacing.xs })

        this.sectionLabel('02', 'YEAR BOUNDARIES')

        Row() {
          this.labButton('DEC > JAN', CalendarDebugScenario.DECEMBER_TO_JANUARY)
          Blank().width(Spacing.xs)
          this.labButton('JAN > DEC', CalendarDebugScenario.JANUARY_TO_DECEMBER)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.xl })
    }
    .width('92%')
    .constraintSize({ minHeight: 360, maxWidth: 420 })
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: 1, color: this.tokens.borderColor })
    .borderRadius(Radius.none)
  }

  @Builder
  private sectionLabel(index: string, label: string) {
    Row() {
      Text(index)
        .fontSize(8)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text(label)
        .fontSize(8)
        .fontWeight(800)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')
        .margin({ left: Spacing.xs })
    }
    .width('100%')
    .padding({ top: Spacing.sm, bottom: Spacing.xs })
  }

  @Builder
  private labButton(label: string, scenario: CalendarDebugScenario) {
    Text(label)
      .layoutWeight(1)
      .height(44)
      .fontSize(9)
      .fontWeight(800)
      .fontColor(this.tokens.textPrimary)
      .fontFamily('monospace')
      .textAlign(TextAlign.Center)
      .backgroundColor(this.tokens.bgBase)
      .border({ width: 1, color: this.tokens.borderColor })
      .stateStyles({
        normal: {
          .backgroundColor(this.tokens.bgBase)
          .scale({ x: 1, y: 1 })
        },
        pressed: {
          .backgroundColor(this.tokens.brandPrimary)
          .fontColor(this.tokens.brandText)
          .scale({ x: 0.96, y: 0.96 })
        }
      })
      .animation({ duration: 100, curve: Curve.EaseOut })
      .onClick(() => {
        this.controller.close();
        setTimeout(() => {
          if (this.onRun) {
            this.onRun(scenario);
          }
        }, 160);
      })
  }
}
