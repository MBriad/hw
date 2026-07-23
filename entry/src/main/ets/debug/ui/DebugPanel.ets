import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DesignTokens } from '../../domain/SkinTheme';
import { CalendarVM } from '../../viewmodels/CalendarVM';
import { ActivityVM } from '../../viewmodels/ActivityVM';
import { EasterEggVM } from '../../viewmodels/EasterEggVM';
import { DebugRuntime, EggDebugScenario, PatternDebugScenario, AiDebugScenario } from '../DebugRuntime';
import { UILabels } from '../../common/UILabels';
import { EasterEggLabDialog } from './EasterEggLabDialog';
import { PatternLearningLabDialog } from './PatternLearningLabDialog';

enum DebugSectionKind {
  QUICK_TESTS = 'quick_tests',
  FEATURE_LABS = 'feature_labs',
}

enum DebugActionKind {
  LOAD_HEATMAP = 'load_heatmap',
  LOAD_ACTIVITY = 'load_activity',
  RELOAD_MONTH = 'reload_month',
  REFRESH_DATA = 'refresh_data',
  CLEAR_RECORDS = 'clear_records',
}

enum DebugLabKind {
  EASTER_EGG = 'easter_egg',
  PATTERN_LEARNING = 'pattern_learning',
}

@Component
export struct DebugPanel {
  @StorageLink('calendarVM') private calendarVM: CalendarVM | null = null;
  @StorageLink('activityVM') private activityVM: ActivityVM | null = null;
  @StorageLink('easterEggVM') private easterEggVM: EasterEggVM | null = null;
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  @State private expanded: boolean = false;

  private eggLabController: CustomDialogController = new CustomDialogController({
    builder: EasterEggLabDialog({
      onRun: (scenario: EggDebugScenario) => {
        this.runEggScenario(scenario);
      }
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
  });
  private patternLabController: CustomDialogController = new CustomDialogController({
    builder: PatternLearningLabDialog({
      onRun: (scenario: PatternDebugScenario) => {
        this.runPatternScenario(scenario);
      },
      onAiRun: (scenario: AiDebugScenario) => {
        this.runAiScenario(scenario);
      }
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
  });

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.uiLabels.devDebugPanel)
            .fontSize(13)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text(this.uiLabels.unifiedDebugEntry)
            .fontSize(9)
            .fontWeight(600)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .margin({ top: Spacing.xxs })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.expanded ? '[-]' : '[+]')
          .fontSize(11)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
      }
      .width('100%')
      .height(62)
      .padding({ left: Spacing.md, right: Spacing.md })
      .backgroundColor(this.tokens.bgSurface)
      .stateStyles({
        normal: {
          .backgroundColor(this.tokens.bgSurface)
        },
        pressed: {
          .backgroundColor(this.tokens.bgSurfacePressed)
        }
      })
      .onClick(() => {
        this.expanded = !this.expanded;
      })

      if (this.expanded && this.calendarVM !== null && this.activityVM !== null && this.easterEggVM !== null) {
        Column() {
          this.sectionLabel(DebugSectionKind.QUICK_TESTS)

          Row() {
            this.debugButton(DebugActionKind.LOAD_HEATMAP, () => {
              this.runAsync(this.uiLabels.loadHeatmap, (runtime: DebugRuntime) => runtime.loadHeatmap());
            })
            Blank().width(Spacing.xs)
            this.debugButton(DebugActionKind.LOAD_ACTIVITY, () => {
              this.runAsync(this.uiLabels.loadActivity, (runtime: DebugRuntime) => runtime.loadActivity());
            })
          }
          .width('100%')

          Row() {
            this.debugButton(DebugActionKind.RELOAD_MONTH, () => {
              this.runAsync(this.uiLabels.reloadMonth, (runtime: DebugRuntime) => runtime.reloadMonth());
            })
            Blank().width(Spacing.xs)
            this.debugButton(DebugActionKind.REFRESH_DATA, () => {
              this.runAsync(this.uiLabels.refreshData, (runtime: DebugRuntime) => runtime.refreshData());
            })
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          Row() {
            this.debugButton(DebugActionKind.CLEAR_RECORDS, () => {
              this.runAsync(this.uiLabels.clearRecords, (runtime: DebugRuntime) => runtime.clearRecords());
            })
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel(DebugSectionKind.FEATURE_LABS)

          this.featureLabButton(
            DebugLabKind.EASTER_EGG,
            () => {
              this.eggLabController.open();
            }
          )

          Blank().height(Spacing.xs)

          this.featureLabButton(
            DebugLabKind.PATTERN_LEARNING,
            () => {
              this.patternLabController.open();
            }
          )
        }
        .width('100%')
        .padding({ left: Spacing.md, right: Spacing.md, bottom: Spacing.md })
        .backgroundColor(this.tokens.bgSurface)
      }
    }
    .width('100%')
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: 1, color: this.tokens.borderColor })
    .borderRadius(Radius.none)
  }

  private runtime(): DebugRuntime | null {
    if (this.calendarVM === null || this.activityVM === null || this.easterEggVM === null) {
      return null;
    }
    return new DebugRuntime(this.calendarVM, this.activityVM, this.easterEggVM);
  }

  private runAsync(title: string, action: (runtime: DebugRuntime) => Promise<string>): void {
    const runtime = this.runtime();
    if (runtime === null) {
      return;
    }
    action(runtime).then((result: string) => {
      this.showResult(title, result);
    });
  }

  private showResult(title: string, message: string): void {
    const isError = message.startsWith('FAIL');
    AlertDialog.show({
      title: title,
      message: message,
      confirm: {
        value: 'OK',
        fontColor: isError ? this.tokens.brandAccent : this.tokens.brandPrimary,
        action: () => {
        },
      },
    });
  }

  private runEggScenario(scenario: EggDebugScenario): void {
    const runtime = this.runtime();
    if (runtime !== null) {
      runtime.runEasterEggScenario(scenario);
    }
  }

  private runPatternScenario(scenario: PatternDebugScenario): void {
    const runtime = this.runtime();
    if (runtime === null) {
      return;
    }
    runtime.runPatternScenario(scenario).then((result: string) => {
      if (scenario === PatternDebugScenario.SIMILAR_MATCH && result.startsWith('OK | matched=')) {
        return;
      }
      this.showResult('PATTERN LEARNING', result);
    });
  }

  private runAiScenario(scenario: AiDebugScenario): void {
    const runtime = this.runtime();
    if (runtime === null) {
      return;
    }
    runtime.runAiScenario(scenario).then((result: string) => {
      this.showResult('AI PATTERN', result);
    });
  }

  @Builder
  private sectionLabel(kind: DebugSectionKind) {
    Text() {
      if (kind === DebugSectionKind.QUICK_TESTS) {
        Span(this.uiLabels.quickTests)
      } else {
        Span(this.uiLabels.featureLabs)
      }
    }
      .width('100%')
      .fontSize(8)
      .fontWeight(800)
      .fontColor(this.tokens.textMuted)
      .fontFamily('monospace')
      .padding({ top: Spacing.sm, bottom: Spacing.xs })
  }

  @Builder
  private debugButton(kind: DebugActionKind, action: () => void) {
    Text() {
      if (kind === DebugActionKind.LOAD_HEATMAP) {
        Span(this.uiLabels.loadHeatmap)
      } else if (kind === DebugActionKind.LOAD_ACTIVITY) {
        Span(this.uiLabels.loadActivity)
      } else if (kind === DebugActionKind.RELOAD_MONTH) {
        Span(this.uiLabels.reloadMonth)
      } else if (kind === DebugActionKind.REFRESH_DATA) {
        Span(this.uiLabels.refreshData)
      } else {
        Span(this.uiLabels.clearRecords)
      }
    }
      .layoutWeight(1)
      .height(40)
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
          .scale({ x: 0.97, y: 0.97 })
        }
      })
      .animation({ duration: 100, curve: Curve.EaseOut })
      .onClick(action)
  }

  @Builder
  private featureLabButton(kind: DebugLabKind, action: () => void) {
    Row() {
      Column() {
        Text() {
          if (kind === DebugLabKind.EASTER_EGG) {
            Span(this.uiLabels.easterEggLab)
          } else {
            Span(this.uiLabels.patternLearningLab)
          }
        }
          .fontSize(10)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')

        Text() {
          if (kind === DebugLabKind.EASTER_EGG) {
            Span(this.uiLabels.easterEggLabSub)
          } else {
            Span(this.uiLabels.patternLearningLabSub)
          }
        }
          .fontSize(8)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('[>]')
        .fontSize(10)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')
    }
    .width('100%')
    .height(54)
    .padding({ left: Spacing.sm, right: Spacing.sm })
    .backgroundColor(this.tokens.bgBase)
    .border({ width: 1, color: this.tokens.borderColor })
    .stateStyles({
      normal: {
        .backgroundColor(this.tokens.bgBase)
        .scale({ x: 1, y: 1 })
      },
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.98, y: 0.98 })
      }
    })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onClick(action)
  }
}
