/**
 * Entry page — provides DesignTokens via @Provide to entire subtree.
 * Child components use @Consume to read current theme tokens.
 */
import { HeatmapVM } from '../viewmodels/HeatmapVM';
import { RecordCheckIn } from '../usecases/RecordCheckIn';
import { LoadHeatmap } from '../usecases/LoadHeatmap';
import { PreferencesCheckInRepo } from '../adapters/PreferencesCheckInRepo';
import { SkinProviderImpl } from '../adapters/SkinProviderImpl';
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { preferences } from '@kit.ArkData';
import { HeatmapGrid } from './components/HeatmapGrid';
import { CheckInInput } from './components/CheckInInput';
import { SkinSwitcher } from './components/SkinSwitcher';
import { Spacing } from '../common/SpacingTokens';

const PREFS_NAME = 'app_settings';
const KEY_THEME = 'theme';

@Entry
@Component
struct HeatmapPage {
  @Provide @Watch('onThemeChange') tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  private vm: HeatmapVM | null = null;

  aboutToAppear(): void {
    const repo = new PreferencesCheckInRepo(getContext(this));
    this.vm = new HeatmapVM(
      new LoadHeatmap(repo),
      new RecordCheckIn(repo),
      new SkinProviderImpl()
    );
    const now = new Date();
    this.vm.loadMonth(now.getFullYear(), now.getMonth() + 1);
    this.loadPersistedTheme();
  }

  onThemeChange(): void {
    // Auto-triggers subtree repaint via @Provide
  }

  switchTheme(name: SkinTheme): void {
    this.themeName = name;
    this.tokens = ThemePalette[name];
    this.persistTheme(name);
  }

  private loadPersistedTheme(): void {
    try {
      preferences.getPreferences(getContext(this), PREFS_NAME, (err, pref) => {
        if (!err) {
          pref.get(KEY_THEME, SkinTheme.LIGHT, (_e, value) => {
            const saved = value as string;
            if (saved === SkinTheme.LIGHT || saved === SkinTheme.DARK ||
                saved === SkinTheme.PINK || saved === SkinTheme.PASTEL) {
              this.themeName = saved;
              this.tokens = ThemePalette[saved];
            }
          });
        }
      });
    } catch (_e) {
      // Fallback to LIGHT
    }
  }

  private persistTheme(name: SkinTheme): void {
    try {
      preferences.getPreferences(getContext(this), PREFS_NAME, (err, pref) => {
        if (!err) {
          pref.put(KEY_THEME, name, (e) => { if (!e) { pref.flush() } });
        }
      });
    } catch (_e) {
      // Silent fail
    }
  }

  build() {
    Column() {
      if (this.vm !== null) {
        // Header
        Column() {
          Text(this.vm!.monthLabel)
            .fontSize(20)
            .fontWeight(700)
            .letterSpacing(-0.5)
            .fontColor(this.tokens.textPrimary)
            .padding({ top: Spacing.sm, bottom: Spacing.xs })

          SkinSwitcher({
            onSwitch: (theme: SkinTheme) => {
              this.switchTheme(theme);
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
              cells: this.vm!.cells,
              selectedDate: this.vm!.selectedDate,
              todayString: this.vm!.todayString,
              onCellTap: (date: string) => {
                this.vm!.selectDate(date);
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
          selectedDate: this.vm!.selectedDate,
          onLightUp: (text: string) => {
            this.vm!.doCheckIn(text);
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.tokens.bgBase)
  }
}
