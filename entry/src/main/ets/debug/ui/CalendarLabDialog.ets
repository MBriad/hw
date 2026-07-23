import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { UILabels } from '../../common/UILabels';
import { DesignTokens } from '../../domain/SkinTheme';
import { CalendarDebugScenario } from '../DebugRuntime';

enum CalendarLabSectionKind {
  STANDARD = 'standard',
  YEAR_BOUNDARIES = 'year_boundaries',
}

@CustomDialog
export struct CalendarLabDialog {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  controller: CustomDialogController;
  onRun?: (scenario: CalendarDebugScenario) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.uiLabels.calendarLab)
            .fontSize(14)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('sans-serif')
            .maxLines(1)

          Text(this.uiLabels.monthNavigationPipeline)
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
      .height(84)
      .padding({ left: Spacing.lg, right: Spacing.sm })

      Divider()
        .color(this.tokens.borderColor)
        .strokeWidth(1)

      Column() {
        this.sectionLabel('01', CalendarLabSectionKind.STANDARD)

        Row() {
          this.labButton(CalendarDebugScenario.PREVIOUS_MONTH)
          Blank().width(Spacing.xs)
          this.labButton(CalendarDebugScenario.NEXT_MONTH)
        }
        .width('100%')

        Row() {
          this.labButton(CalendarDebugScenario.CURRENT_MONTH)
          Blank().width(Spacing.xs)
          Blank().layoutWeight(1)
        }
        .width('100%')
        .margin({ top: Spacing.xs })

        this.sectionLabel('02', CalendarLabSectionKind.YEAR_BOUNDARIES)

        Row() {
          this.labButton(CalendarDebugScenario.DECEMBER_TO_JANUARY)
          Blank().width(Spacing.xs)
          this.labButton(CalendarDebugScenario.JANUARY_TO_DECEMBER)
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
  private sectionLabel(index: string, kind: CalendarLabSectionKind) {
    Row() {
      Text(index)
        .fontSize(8)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === CalendarLabSectionKind.STANDARD) {
          Span(this.uiLabels.calendarStandard)
        } else {
          Span(this.uiLabels.calendarYearBoundaries)
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
  private labButton(scenario: CalendarDebugScenario) {
    Text() {
      if (scenario === CalendarDebugScenario.PREVIOUS_MONTH) {
        Span(this.uiLabels.previousMonth)
      } else if (scenario === CalendarDebugScenario.NEXT_MONTH) {
        Span(this.uiLabels.nextMonth)
      } else if (scenario === CalendarDebugScenario.CURRENT_MONTH) {
        Span(this.uiLabels.currentMonth)
      } else if (scenario === CalendarDebugScenario.DECEMBER_TO_JANUARY) {
        Span(this.uiLabels.decemberToJanuary)
      } else {
        Span(this.uiLabels.januaryToDecember)
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
