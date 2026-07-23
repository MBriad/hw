import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { UILabels } from '../../common/UILabels';
import { DesignTokens } from '../../domain/SkinTheme';
import { PatternDebugScenario, AiDebugScenario } from '../DebugRuntime';

enum PatternLabSectionKind {
  STAGES = 'stages',
  MATCHING = 'matching',
  DATA = 'data',
  AI = 'ai',
}

@CustomDialog
export struct PatternLearningLabDialog {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  controller: CustomDialogController;
  onRun?: (scenario: PatternDebugScenario) => void;
  onAiRun?: (scenario: AiDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.uiLabels.patternLearningLab)
            .fontSize(14)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text(this.uiLabels.realLearningPipeline)
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
          this.sectionLabel('01', PatternLabSectionKind.STAGES)

          Row() {
            this.labButton(PatternDebugScenario.OBSERVING)
            Blank().width(Spacing.xs)
            this.labButton(PatternDebugScenario.CANDIDATE)
          }
          .width('100%')

          Row() {
            this.labButton(PatternDebugScenario.MATURE)
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('02', PatternLabSectionKind.MATCHING)

          Row() {
            this.labButton(PatternDebugScenario.SIMILAR_MATCH)
            Blank().width(Spacing.xs)
            this.labButton(PatternDebugScenario.NO_MATCH)
          }
          .width('100%')

          Row() {
            this.labButton(PatternDebugScenario.COOLDOWN)
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('03', PatternLabSectionKind.DATA)

          Row() {
            this.labButton(PatternDebugScenario.OBSERVATION_STATUS)
            Blank().width(Spacing.xs)
            this.labButton(PatternDebugScenario.RESET_SAMPLE)
          }
          .width('100%')

          this.sectionLabel('04', PatternLabSectionKind.AI)

          Row() {
            this.aiButton(AiDebugScenario.AI_PING)
            Blank().width(Spacing.xs)
            this.aiButton(AiDebugScenario.AI_ANALYZE_SAMPLE)
          }
          .width('100%')

          Row() {
            this.aiButton(AiDebugScenario.AI_TIMEOUT)
            Blank().width(Spacing.xs)
            this.aiButton(AiDebugScenario.AI_INVALID_RESPONSE)
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
  private sectionLabel(index: string, kind: PatternLabSectionKind) {
    Row() {
      Text(index)
        .fontSize(8)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === PatternLabSectionKind.STAGES) {
          Span(this.uiLabels.stages)
        } else if (kind === PatternLabSectionKind.MATCHING) {
          Span(this.uiLabels.matching)
        } else if (kind === PatternLabSectionKind.DATA) {
          Span(this.uiLabels.data_section)
        } else {
          Span(this.uiLabels.ai_section)
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
  private labButton(scenario: PatternDebugScenario) {
    Text() {
      if (scenario === PatternDebugScenario.OBSERVING) {
        Span(this.uiLabels.observing)
      } else if (scenario === PatternDebugScenario.CANDIDATE) {
        Span(this.uiLabels.candidate)
      } else if (scenario === PatternDebugScenario.MATURE) {
        Span(this.uiLabels.mature)
      } else if (scenario === PatternDebugScenario.SIMILAR_MATCH) {
        Span(this.uiLabels.similarMatch)
      } else if (scenario === PatternDebugScenario.NO_MATCH) {
        Span(this.uiLabels.noMatch)
      } else if (scenario === PatternDebugScenario.COOLDOWN) {
        Span(this.uiLabels.cooldown)
      } else if (scenario === PatternDebugScenario.OBSERVATION_STATUS) {
        Span(this.uiLabels.observationStatus)
      } else {
        Span(this.uiLabels.resetSample)
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

  @Builder
  private aiButton(scenario: AiDebugScenario) {
    Text() {
      if (scenario === AiDebugScenario.AI_PING) {
        Span(this.uiLabels.aiPing)
      } else if (scenario === AiDebugScenario.AI_ANALYZE_SAMPLE) {
        Span(this.uiLabels.aiAnalyzeSample)
      } else if (scenario === AiDebugScenario.AI_TIMEOUT) {
        Span(this.uiLabels.aiTimeout)
      } else {
        Span(this.uiLabels.aiInvalidResponse)
      }
    }
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
