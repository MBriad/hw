import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DebugLabels } from '../../common/DebugLabels';
import { DesignTokens } from '../../domain/SkinTheme';
import { PatternDebugScenario, AiDebugScenario } from '../DebugRuntime';

@CustomDialog
export struct PatternLearningLabDialog {
  @Consume tokens: DesignTokens;
  @Consume debugLabels: DebugLabels;
  controller: CustomDialogController;
  onRun?: (scenario: PatternDebugScenario) => void;
  onAiRun?: (scenario: AiDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.debugLabels.patternLearningLab)
            .fontSize(14)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text(this.debugLabels.realLearningPipeline)
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

      Divider().color(this.tokens.borderColor).strokeWidth(1)

      Scroll() {
        Column() {
          this.sectionLabel('01', this.debugLabels.stages)

          Row() {
            this.labButton(this.debugLabels.observing, PatternDebugScenario.OBSERVING)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.candidate, PatternDebugScenario.CANDIDATE)
          }
          .width('100%')

          Row() {
            this.labButton(this.debugLabels.mature, PatternDebugScenario.MATURE)
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('02', this.debugLabels.matching)

          Row() {
            this.labButton(this.debugLabels.similarMatch, PatternDebugScenario.SIMILAR_MATCH)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.noMatch, PatternDebugScenario.NO_MATCH)
          }
          .width('100%')

          Row() {
            this.labButton(this.debugLabels.cooldown, PatternDebugScenario.COOLDOWN)
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('03', this.debugLabels.data_section)

          Row() {
            this.labButton(this.debugLabels.observationStatus, PatternDebugScenario.OBSERVATION_STATUS)
            Blank().width(Spacing.xs)
            this.labButton(this.debugLabels.resetSample, PatternDebugScenario.RESET_SAMPLE)
          }
          .width('100%')

          this.sectionLabel('04', this.debugLabels.ai_section)

          Row() {
            this.aiButton(this.debugLabels.aiPing, AiDebugScenario.AI_PING)
            Blank().width(Spacing.xs)
            this.aiButton(this.debugLabels.aiAnalyzeSample, AiDebugScenario.AI_ANALYZE_SAMPLE)
          }
          .width('100%')

          Row() {
            this.aiButton(this.debugLabels.aiTimeout, AiDebugScenario.AI_TIMEOUT)
            Blank().width(Spacing.xs)
            this.aiButton(this.debugLabels.aiInvalidResponse, AiDebugScenario.AI_INVALID_RESPONSE)
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
    .height(520)
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
  private labButton(label: string, scenario: PatternDebugScenario) {
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

  @Builder
  private aiButton(label: string, scenario: AiDebugScenario) {
    Text(label)
      .layoutWeight(1)
      .height(44)
      .fontSize(9)
      .fontWeight(800)
      .fontColor(this.tokens.brandPrimary)
      .fontFamily('monospace')
      .textAlign(TextAlign.Center)
      .backgroundColor(this.tokens.bgBase)
      .border({ width: 1, color: this.tokens.brandPrimary })
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
          if (this.onAiRun) {
            this.onAiRun(scenario);
          }
        }, 160);
      })
  }
}
