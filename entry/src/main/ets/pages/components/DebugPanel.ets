/**
 * Debug panel for runtime layer-by-layer data-flow verification.
 * All access goes through UseCases — no direct Port calls from VM.
 * Results are shown via AlertDialog popups.
 */
import { DesignTokens } from '../../domain/SkinTheme';
import { HeatmapVM } from '../../viewmodels/HeatmapVM';
import { Spacing } from '../../common/SpacingTokens';

@Component
export struct DebugPanel {
  @StorageLink('heatmapVM') private vm: HeatmapVM | null = null;
  @Consume tokens: DesignTokens;
  @State expanded: boolean = false;

  build() {
    Column() {
      // ── Toggle header ──
      Row() {
        Text('DEBUG PANEL')
          .fontSize(10)
          .fontWeight(700)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')

        Blank()

        Text(this.expanded ? '[-]' : '[+]')
          .fontSize(12)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
      }
      .width('100%')
      .padding({ top: Spacing.sm, bottom: Spacing.sm })
      .border({ width: { top: 1, bottom: 1 }, color: this.tokens.textPrimary })
      .onClick(() => {
        this.expanded = !this.expanded;
      })

      // ── Expanded content ──
      if (this.expanded && this.vm !== null) {
        Column() {
          // ── DATA UseCases ──
          this.sectionLabel('DATA')
          Row() {
            this.debugButton('LoadHeatmap', () => {
              this.vm!.debugUseCaseLoadHeatmap().then((r: string) => {
                this.showResult('DATA / LoadHeatmap', r);
              });
            })
            this.debugButton('LoadActivity', () => {
              this.vm!.debugUseCaseLoadActivity().then((r: string) => {
                this.showResult('DATA / LoadActivity', r);
              });
            })
            this.debugButton('ProcessCheckIn', () => {
              this.vm!.debugUseCaseProcessCheckIn().then((r: string) => {
                this.showResult('DATA / ProcessCheckIn', r);
              });
            })
          }
          .width('100%')

          // ── THEME UseCases ──
          this.sectionLabel('THEME')
          Row() {
            this.debugButton('LoadTheme', () => {
              this.vm!.debugUseCaseLoadTheme().then((r: string) => {
                this.showResult('THEME / LoadTheme', r);
              });
            })
            this.debugButton('SwitchTheme', () => {
              this.vm!.debugUseCaseSwitchTheme().then((r: string) => {
                this.showResult('THEME / SwitchTheme', r);
              });
            })
          }
          .width('100%')

          // ── Full chain (VM → UC → Adapter) ──
          this.sectionLabel('FULL CHAIN')
          Row() {
            this.debugButton('loadMonth', () => {
              const y = parseInt(this.vm!.todayString.slice(0, 4));
              const m = parseInt(this.vm!.todayString.slice(5, 7));
              this.vm!.loadMonth(y, m)
                .then(() => {
                  const active = this.vm!.cells.filter((c) => c.level > 0).length;
                  this.showResult('FULL / loadMonth', `OK | cells=${active}/${this.vm!.cells.length}`);
                })
                .catch((e: Error) => {
                  this.showResult('FULL / loadMonth', `FAIL | ${JSON.stringify(e)}`);
                });
            })
            this.debugButton('refreshActivity', () => {
              this.vm!.refreshActivity()
                .then(() => {
                  this.showResult('FULL / refreshActivity',
                    `OK | checkIns=${this.vm!.checkIns.length} | patterns=${this.vm!.usagePatterns.length}`);
                })
                .catch((e: Error) => {
                  this.showResult('FULL / refreshActivity', `FAIL | ${JSON.stringify(e)}`);
                });
            })
            this.debugButton('ClearState', () => {
              this.vm!.debugClearState();
              this.showResult('FULL / ClearState', 'VM state cleared');
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ top: Spacing.sm, bottom: Spacing.sm })
      }
    }
    .width('100%')
  }

  private showResult(title: string, msg: string): void {
    const isError = msg.startsWith('FAIL');
    AlertDialog.show({
      title: title,
      message: msg,
      confirm: {
        value: 'OK',
        fontColor: isError ? this.tokens.brandAccent : this.tokens.brandPrimary,
        action: () => {},
      },
    });
  }

  @Builder
  sectionLabel(label: string) {
    Text(`-- ${label} --`)
      .fontSize(8)
      .fontWeight(700)
      .fontColor(this.tokens.textMuted)
      .fontFamily('monospace')
      .padding({ top: Spacing.sm, bottom: Spacing.xs })
  }

  @Builder
  debugButton(label: string, action: () => void) {
    Text(label)
      .fontSize(9)
      .fontWeight(700)
      .fontColor(this.tokens.textPrimary)
      .fontFamily('monospace')
      .padding({ left: Spacing.sm, right: Spacing.sm, top: Spacing.xs, bottom: Spacing.xs })
      .border({ width: 1, color: this.tokens.borderColor })
      .margin({ right: Spacing.sm })
      .stateStyles({
        pressed: {
          .backgroundColor(this.tokens.bgSurfacePressed)
        }
      })
      .onClick(action)
  }
}
