/**
 * Main heatmap page — Humble View.
 * Assembles SkinSwitcher + HeatmapGrid + CheckInInput.
 * VM is created internally for now; Task 1.7 will move wiring to Composition Root.
 */
import { HeatmapVM } from '../viewmodels/HeatmapVM';
import { RecordCheckIn } from '../usecases/RecordCheckIn';
import { LoadHeatmap } from '../usecases/LoadHeatmap';
import { PreferencesCheckInRepo } from '../adapters/PreferencesCheckInRepo';
import { SkinProviderImpl } from '../adapters/SkinProviderImpl';
import { SkinTheme } from '../domain/SkinTheme';
import { HeatmapCell } from '../domain/Streak';
import { HeatmapGrid } from './components/HeatmapGrid';
import { CheckInInput } from './components/CheckInInput';
import { SkinSwitcher } from './components/SkinSwitcher';

@Entry
@Component
struct HeatmapPage {
  private vm: HeatmapVM = this.createVM();

  private createVM(): HeatmapVM {
    const repo = new PreferencesCheckInRepo(getContext(this));
    const loadHeatmap = new LoadHeatmap(repo);
    const recordCheckIn = new RecordCheckIn(repo);
    const skinProvider = new SkinProviderImpl();
    return new HeatmapVM(loadHeatmap, recordCheckIn, skinProvider);
  }

  aboutToAppear(): void {
    const now = new Date();
    this.vm.loadMonth(now.getFullYear(), now.getMonth() + 1);
  }

  build() {
    Column() {
      // Header area
      Column() {
        Text(this.vm.monthLabel)
          .fontSize(20)
          .fontColor(this.vm.currentSkinConfig.textOnSurface)
          .fontWeight(FontWeight.Bold)
          .padding({ top: 12, bottom: 4 })

        SkinSwitcher({
          skinConfig: this.vm.currentSkinConfig,
          currentSkin: this.vm.currentSkin,
          onSwitch: (theme: SkinTheme) => {
            this.vm.switchSkin(theme);
          }
        })
      }
      .width('100%')
      .backgroundColor(this.vm.currentSkinConfig.surface)

      // Scrollable grid area
      Scroll() {
        Column() {
          HeatmapGrid({
            cells: this.vm.cells,
            skinConfig: this.vm.currentSkinConfig,
            selectedDate: this.vm.selectedDate,
            todayString: this.vm.todayString,
            onCellTap: (date: string) => {
              this.vm.selectDate(date);
            }
          })
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor(this.vm.currentSkinConfig.surface)
      .scrollBar(BarState.Off)

      // Check-in input area (sticky bottom)
      CheckInInput({
        selectedDate: this.vm.selectedDate,
        skinConfig: this.vm.currentSkinConfig,
        onLightUp: (text: string) => {
          this.vm.doCheckIn(text);
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.vm.currentSkinConfig.surfaceSecondary)
  }
}
