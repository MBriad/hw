import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DesignTokens } from '../../domain/SkinTheme';

export enum EggDebugScenario {
  SPARKLE = 'SPARKLE',
  DARK = 'DARK',
  BUBBLE = 'BUBBLE',
  SAKURA = 'SAKURA',
  RISE = 'RISE',
  AT_FIELD = 'AT_FIELD',
  AUTO_DISMISS = 'AUTO_DISMISS',
  TAP_DISMISS = 'TAP_DISMISS',
  RETRIGGER_BLOCKED = 'RETRIGGER_BLOCKED',
  RAPID_TAPS = 'RAPID_TAPS',
  AFTER_END = 'AFTER_END',
}

@CustomDialog
export struct EasterEggLabDialog {
  @Consume tokens: DesignTokens;
  controller: CustomDialogController;
  onRun?: (scenario: EggDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text('EASTER EGG LAB')
            .fontSize(14)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('LIVE EFFECT PIPELINE')
            .fontSize(9)
            .fontWeight(600)
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
      .height(64)
      .padding({ left: Spacing.md, right: Spacing.xs })

      Divider()
        .color(this.tokens.borderColor)
        .strokeWidth(1)

      Scroll() {
        Column() {
          this.sectionLabel('01', 'PRESETS')

          Row() {
            this.labButton('SPARKLE', EggDebugScenario.SPARKLE)
            Blank().width(Spacing.xs)
            this.labButton('DARK', EggDebugScenario.DARK)
          }
          .width('100%')

          Row() {
            this.labButton('BUBBLE', EggDebugScenario.BUBBLE)
            Blank().width(Spacing.xs)
            this.labButton('SAKURA', EggDebugScenario.SAKURA)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.labButton('RISE', EggDebugScenario.RISE)
            Blank().width(Spacing.xs)
            this.labButton('AT FIELD', EggDebugScenario.AT_FIELD)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('02', 'LIFECYCLE')

          Row() {
            this.labButton('AUTO DISMISS', EggDebugScenario.AUTO_DISMISS)
            Blank().width(Spacing.xs)
            this.labButton('TAP DISMISS', EggDebugScenario.TAP_DISMISS)
          }
          .width('100%')

          Row() {
            this.labButton('RETRIGGER BLOCK', EggDebugScenario.RETRIGGER_BLOCKED)
            Blank().width(Spacing.xs)
            this.labButton('RAPID TAPS', EggDebugScenario.RAPID_TAPS)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.labButton('AFTER END', EggDebugScenario.AFTER_END)
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })
        }
        .width('100%')
        .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.lg })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
    .width('92%')
    .height(560)
    .constraintSize({ maxWidth: 420 })
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
  private labButton(label: string, scenario: EggDebugScenario) {
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
          .backgroundColor(this.tokens.bgSurfacePressed)
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
