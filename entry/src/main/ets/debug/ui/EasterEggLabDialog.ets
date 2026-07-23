import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DebugLabels } from '../../common/DebugLabels';
import { DesignTokens } from '../../domain/SkinTheme';
import { EggDebugScenario } from '../DebugRuntime';

@CustomDialog
export struct EasterEggLabDialog {
  @Consume tokens: DesignTokens;
  @Consume debugLabels: DebugLabels;
  controller: CustomDialogController;
  onRun?: (scenario: EggDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.debugLabels.easterEggLab)
            .fontSize(14)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text(this.debugLabels.liveEffectPipeline)
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
          this.sectionLabel('01', this.debugLabels.presets)

          Row() {
            this.labButton(this.debugLabels.sparkle, EggDebugScenario.SPARKLE)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.dark, EggDebugScenario.DARK)
          }
          .width('100%')

          Row() {
            this.labButton(this.debugLabels.bubble, EggDebugScenario.BUBBLE)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.sakura, EggDebugScenario.SAKURA)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.labButton(this.debugLabels.rise, EggDebugScenario.RISE)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.atField, EggDebugScenario.AT_FIELD)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('02', this.debugLabels.lifecycle)

          Row() {
            this.labButton(this.debugLabels.autoDismiss, EggDebugScenario.AUTO_DISMISS)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.tapDismiss, EggDebugScenario.TAP_DISMISS)
          }
          .width('100%')

          Row() {
            this.labButton(this.debugLabels.retriggerBlock, EggDebugScenario.RETRIGGER_BLOCKED)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.rapidTaps, EggDebugScenario.RAPID_TAPS)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.labButton(this.debugLabels.afterEnd, EggDebugScenario.AFTER_END)
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
