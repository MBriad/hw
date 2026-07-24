import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { UILabels } from '../../common/UILabels';
import { DesignTokens } from '../../common/ThemeTokens';
import { EggDebugScenario } from '../DebugRuntime';

enum EggLabSectionKind {
  PRESETS = 'presets',
  LIFECYCLE = 'lifecycle',
}

@CustomDialog
export struct EasterEggLabDialog {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  controller: CustomDialogController;
  onRun?: (scenario: EggDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.uiLabels.easterEggLab)
            .fontSize(14)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text(this.uiLabels.liveEffectPipeline)
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
          this.sectionLabel('01', EggLabSectionKind.PRESETS)

          Row() {
            this.labButton(EggDebugScenario.SPARKLE)
            Blank().width(Spacing.xs)
            this.labButton(EggDebugScenario.DARK)
          }
          .width('100%')

          Row() {
            this.labButton(EggDebugScenario.BUBBLE)
            Blank().width(Spacing.xs)
            this.labButton(EggDebugScenario.SAKURA)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.labButton(EggDebugScenario.RISE)
            Blank().width(Spacing.xs)
            this.labButton(EggDebugScenario.AT_FIELD)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('02', EggLabSectionKind.LIFECYCLE)

          Row() {
            this.labButton(EggDebugScenario.AUTO_DISMISS)
            Blank().width(Spacing.xs)
            this.labButton(EggDebugScenario.TAP_DISMISS)
          }
          .width('100%')

          Row() {
            this.labButton(EggDebugScenario.RETRIGGER_BLOCKED)
            Blank().width(Spacing.xs)
            this.labButton(EggDebugScenario.RAPID_TAPS)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.labButton(EggDebugScenario.AFTER_END)
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
  private sectionLabel(index: string, kind: EggLabSectionKind) {
    Row() {
      Text(index)
        .fontSize(8)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === EggLabSectionKind.PRESETS) {
          Span(this.uiLabels.presets)
        } else {
          Span(this.uiLabels.lifecycle)
        }
      }
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
  private labButton(scenario: EggDebugScenario) {
    Text() {
      if (scenario === EggDebugScenario.SPARKLE) {
        Span(this.uiLabels.sparkle)
      } else if (scenario === EggDebugScenario.DARK) {
        Span(this.uiLabels.darkEgg)
      } else if (scenario === EggDebugScenario.BUBBLE) {
        Span(this.uiLabels.bubble)
      } else if (scenario === EggDebugScenario.SAKURA) {
        Span(this.uiLabels.sakura)
      } else if (scenario === EggDebugScenario.RISE) {
        Span(this.uiLabels.rise)
      } else if (scenario === EggDebugScenario.AT_FIELD) {
        Span(this.uiLabels.atField)
      } else if (scenario === EggDebugScenario.AUTO_DISMISS) {
        Span(this.uiLabels.autoDismiss)
      } else if (scenario === EggDebugScenario.TAP_DISMISS) {
        Span(this.uiLabels.tapDismiss)
      } else if (scenario === EggDebugScenario.RETRIGGER_BLOCKED) {
        Span(this.uiLabels.retriggerBlock)
      } else if (scenario === EggDebugScenario.RAPID_TAPS) {
        Span(this.uiLabels.rapidTaps)
      } else {
        Span(this.uiLabels.afterEnd)
      }
    }
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
