import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DesignTokens } from '../../domain/SkinTheme';
import { HeatmapVM } from '../../viewmodels/HeatmapVM';
import { EasterEggLabDialog, EggDebugScenario } from './EasterEggLabDialog';

@Component
export struct DebugPanel {
  @StorageLink('heatmapVM') private vm: HeatmapVM | null = null;
  @Consume tokens: DesignTokens;
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

  build() {
    Column() {
      Row() {
        Column() {
          Text('DEV DEBUG PANEL')
            .fontSize(13)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('RUNTIME DATA FLOW')
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

      if (this.expanded && this.vm !== null) {
        Column() {
          this.sectionLabel('DATA USECASES')

          Row() {
            this.debugButton('LOAD HEATMAP', () => {
              this.vm!.debugUseCaseLoadHeatmap().then((result: string) => {
                this.showResult('LOAD HEATMAP', result);
              });
            })
            Blank().width(Spacing.xs)
            this.debugButton('LOAD ACTIVITY', () => {
              this.vm!.debugUseCaseLoadActivity().then((result: string) => {
                this.showResult('LOAD ACTIVITY', result);
              });
            })
          }
          .width('100%')

          Row() {
            this.debugButton('EASTER EGG LAB', () => {
              this.eggLabController.open();
            })
            Blank().width(Spacing.xs)
            this.debugButton('RELOAD MONTH', () => {
              const year = parseInt(this.vm!.todayString.slice(0, 4));
              const month = parseInt(this.vm!.todayString.slice(5, 7));
              this.vm!.loadMonth(year, month).then(() => {
                this.showResult('RELOAD MONTH', `OK | cells=${this.vm!.cells.length}`);
              }).catch((error: Error) => {
                this.showResult('RELOAD MONTH', `FAIL | ${JSON.stringify(error)}`);
              });
            })
          }
          .width('100%')
          .margin({ top: Spacing.xs })

          this.sectionLabel('VIEW MODEL')

          Row() {
            this.debugButton('REFRESH DATA', () => {
              this.vm!.refreshActivity().then(() => {
                this.showResult('REFRESH DATA',
                  `OK | commits=${this.vm!.checkIns.length} | patterns=${this.vm!.usagePatterns.length}`);
              }).catch((error: Error) => {
                this.showResult('REFRESH DATA', `FAIL | ${JSON.stringify(error)}`);
              });
            })
            Blank().width(Spacing.xs)
            this.debugButton('TOKEN SNAPSHOT', () => {
              this.showResult('TOKEN SNAPSHOT', this.vm!.debugTokenSnapshot());
            })
          }
          .width('100%')

          Row() {
            this.debugButton('CLEAR RECORDS', () => {
              this.vm!.debugClearAllRecords().then((result: string) => {
                this.showResult('CLEAR RECORDS', result);
              });
            })
            Blank().width(Spacing.xs)
            Blank().layoutWeight(1)
          }
          .width('100%')
          .margin({ top: Spacing.xs })
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
    if (this.vm === null) {
      return;
    }
    if (scenario === EggDebugScenario.SPARKLE) {
      this.vm.debugPlayEasterEgg('particle_sparkle', 'level_up', 'DEBUG // SPARKLE SIGNAL');
    } else if (scenario === EggDebugScenario.DARK) {
      this.vm.debugPlayEasterEgg('particle_dark', 'wind_chime', 'DEBUG // DARK SIGNAL');
    } else if (scenario === EggDebugScenario.BUBBLE) {
      this.vm.debugPlayEasterEgg('particle_bubble', 'healing_bell', 'DEBUG // BUBBLE SIGNAL');
    } else if (scenario === EggDebugScenario.SAKURA) {
      this.vm.debugPlayEasterEgg('particle_sakura', 'anime_sparkle', 'DEBUG // SAKURA SIGNAL');
    } else if (scenario === EggDebugScenario.RISE) {
      this.vm.debugPlayEasterEgg('particle_rise', 'jojo_menace', 'DEBUG // RISE SIGNAL');
    } else if (scenario === EggDebugScenario.AT_FIELD) {
      this.vm.debugPlayEasterEgg('eva_at_field', 'eva_alert', 'DEBUG // A.T. FIELD SIGNAL');
    } else if (scenario === EggDebugScenario.AUTO_DISMISS) {
      this.vm.debugPlayEasterEgg('particle_sparkle', 'level_up', 'DEBUG // AUTO DISMISS');
    } else if (scenario === EggDebugScenario.TAP_DISMISS) {
      this.vm.debugPlayEasterEgg('particle_sakura', 'anime_sparkle', 'DEBUG // TAP TO DISMISS');
    } else if (scenario === EggDebugScenario.RETRIGGER_BLOCKED) {
      this.vm.debugPlayBlockedRetrigger();
    } else if (scenario === EggDebugScenario.RAPID_TAPS) {
      this.vm.debugPlayRapidTaps();
    } else if (scenario === EggDebugScenario.AFTER_END) {
      this.vm.debugPlayAfterEnd();
    }
  }

  @Builder
  private sectionLabel(label: string) {
    Text(label)
      .width('100%')
      .fontSize(8)
      .fontWeight(800)
      .fontColor(this.tokens.textMuted)
      .fontFamily('monospace')
      .padding({ top: Spacing.sm, bottom: Spacing.xs })
  }

  @Builder
  private debugButton(label: string, action: () => void) {
    Text(label)
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
}
