/**
 * Main content — rendered inside ThemeProvider, so can @Consume tokens.
 * Humble View: assembles SkinSwitcher + HeatmapGrid + CheckInInput.
 */
import { HeatmapVM } from '../viewmodels/HeatmapVM';
import { SkinTheme, DesignTokens } from '../domain/SkinTheme';
import { HeatmapGrid } from './components/HeatmapGrid';
import { CheckInInput } from './components/CheckInInput';
import { SkinSwitcher } from './components/SkinSwitcher';
import { Spacing } from '../common/SpacingTokens';

@Component
export struct HeatmapContent {
  @Consume tokens: DesignTokens;
  @Consume themeName: SkinTheme;
  @Prop vm: HeatmapVM;

  build() {
    Column() {
      // Header
      Column() {
        Text(this.vm.monthLabel)
          .fontSize(20)
          .fontWeight(700)
          .letterSpacing(-0.5)
          .fontColor(this.tokens.textPrimary)
          .padding({ top: Spacing.sm, bottom: Spacing.xs })

        SkinSwitcher({
          onSwitch: (theme: SkinTheme) => {
            this.vm.switchSkin(theme);
          }
        })
      }
      .width('100%')
      .backgroundColor(this.tokens.bgSurface)
      .padding({ left: Spacing.md, right: Spacing.md })

      // Grid
      Scroll() {
        Column() {
          HeatmapGrid({
            cells: this.vm.cells,
            selectedDate: this.vm.selectedDate,
            todayString: this.vm.todayString,
            onCellTap: (date: string) => {
              this.vm.selectDate(date);
            }
          })
          .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.xs, bottom: Spacing.xs })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor(this.tokens.bgSurface)
      .scrollBar(BarState.Off)

      // Check-in input
      CheckInInput({
        selectedDate: this.vm.selectedDate,
        onLightUp: (text: string) => {
          this.vm.doCheckIn(text);
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.tokens.bgBase)
  }
}
