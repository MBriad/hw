/**
 * Entry page — provides DesignTokens via @Provide to entire subtree.
 * Child components use @Consume to read current theme tokens.
 */
import { HeatmapVM } from '../viewmodels/HeatmapVM';
import { RecordCheckIn } from '../usecases/RecordCheckIn';
import { LoadHeatmap } from '../usecases/LoadHeatmap';
import { PreferencesCheckInRepo } from '../adapters/PreferencesCheckInRepo';
import { SkinProviderImpl } from '../adapters/SkinProviderImpl';
import { RegexKeywordMatcher } from '../adapters/RegexKeywordMatcher';
import { SoundPlayerImpl } from '../adapters/SoundPlayerImpl';
import { SkinTheme, DesignTokens, ThemePalette } from '../domain/SkinTheme';
import { preferences } from '@kit.ArkData';
import { HeatmapGrid } from './components/HeatmapGrid';
import { CheckInInput } from './components/CheckInInput';
import { SkinSwitcher } from './components/SkinSwitcher';
import { ParticleOverlay } from './components/ParticleOverlay';
import { QuoteBanner } from './components/QuoteBanner';
import { Spacing } from '../common/SpacingTokens';
import { Radius } from '../common/RadiusTokens';
import { GlassTheme } from '../common/GlassTheme';

const PREFS_NAME = 'app_settings';
const KEY_THEME = 'theme';

@Entry
@Component
struct HeatmapPage {
  @Provide @Watch('onThemeChange') tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  @State private vm: HeatmapVM | null = null;

  aboutToAppear(): void {
    const repo = new PreferencesCheckInRepo(getContext(this));
    this.vm = new HeatmapVM(
      new LoadHeatmap(repo),
      new RecordCheckIn(repo),
      new SkinProviderImpl(),
      new RegexKeywordMatcher(),
      new SoundPlayerImpl()
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
    Stack() {
      // Base layer: main content
      Column() {
        if (this.vm !== null) {
          Column() {
            Text(this.vm!.monthLabel)
              .fontSize(24)
              .fontWeight(700)
              .fontColor(this.tokens.textPrimary)
              .padding({ top: Spacing.sm, bottom: Spacing.xs })

            SkinSwitcher({
              onSwitch: (theme: SkinTheme) => {
                this.switchTheme(theme);
              }
            })
          }
          .width('100%')
          .padding({ left: Spacing.md, right: Spacing.md })
          .backgroundColor(GlassTheme.surface(this.themeName))
          .backdropBlur(24)
          .border({ width: 1, color: GlassTheme.border(this.themeName) })
          .borderRadius(Radius.lg)
          .shadow({ radius: 18, color: GlassTheme.shadow(this.themeName), offsetY: 6 })

          HeatmapGrid({
            cells: this.vm!.cells,
            selectedDate: this.vm!.selectedDate,
            todayString: this.vm!.todayString,
            onCellTap: (date: string) => {
              this.vm!.selectDate(date);
            }
          })
            .width('100%')
            .padding(Spacing.md)
            .margin({ top: Spacing.sm })
            .backgroundColor(GlassTheme.surface(this.themeName))
            .backdropBlur(24)
            .border({ width: 1, color: GlassTheme.border(this.themeName) })
            .borderRadius(Radius.lg)
            .shadow({ radius: 18, color: GlassTheme.shadow(this.themeName), offsetY: 6 })

          Blank()
            .layoutWeight(1)

          CheckInInput({
            selectedDate: this.vm!.selectedDate,
            onLightUp: (text: string) => {
              this.vm!.doCheckIn(text);
            }
          })
            .margin({ top: Spacing.sm })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.xs, bottom: Spacing.sm })
      .backgroundColor(this.tokens.bgBase)
      .linearGradient({
        angle: 160,
        colors: [[this.tokens.bgBase, 0.0], [this.tokens.brandLight, 0.52], [this.tokens.bgBase, 1.0]]
      })

      // Easter egg particle overlay (on top)
      if (this.vm !== null && this.vm.showParticles) {
        ParticleOverlay({
          effectType: this.vm.triggeredEgg ? this.vm.triggeredEgg.effectType : 'particle_sparkle',
        })
          .width('100%')
          .height('100%')
          .hitTestBehavior(HitTestMode.Transparent)
      }

      // Easter egg quote banner (bottom overlay)
      if (this.vm !== null && this.vm.showBanner) {
        QuoteBanner({
          quote: this.vm.triggeredEgg ? this.vm.triggeredEgg.quote : '',
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
