/** Entry page for the Actrace technical activity workspace. */
import { preferences } from '@kit.ArkData';
import { Spacing } from '../common/SpacingTokens';
import { AppSection } from '../domain/AppSection';
import { DesignTokens, SkinTheme, ThemePalette } from '../domain/SkinTheme';
import { HeatmapVM } from '../viewmodels/HeatmapVM';
import { CheckInInput } from './components/CheckInInput';
import { GridBackdrop } from './components/GridBackdrop';
import { HorizontalNavigation } from './components/HorizontalNavigation';
import { ParticleOverlay } from './components/ParticleOverlay';
import { QuoteBanner } from './components/QuoteBanner';
import { CalendarSection } from './sections/CalendarSection';
import { LogsSection } from './sections/LogsSection';
import { PatternsSection } from './sections/PatternsSection';
import { ProfileSection } from './sections/ProfileSection';

const PREFS_NAME = 'app_settings';
const KEY_THEME = 'theme';
const CONTENT_MAX_WIDTH = 420;

@Entry
@Component
struct HeatmapPage {
  @Provide @Watch('onThemeChange') tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  @StorageLink('heatmapVM') private vm: HeatmapVM | null = null;
  @State private activeSection: AppSection = AppSection.DATA;

  aboutToAppear(): void {
    const now = new Date();
    if (this.vm !== null) {
      this.vm.initialize(now.getFullYear(), now.getMonth() + 1);
    }
    this.loadPersistedTheme();
  }

  onThemeChange(): void {
  }

  private switchTheme(name: SkinTheme): void {
    this.themeName = name;
    this.tokens = ThemePalette[name];
    this.persistTheme(name);
  }

  @Builder
  private calendarMonthHeader() {
    Row() {
      Text(this.vm!.monthHeaderLabel)
        .layoutWeight(1)
        .fontSize(26)
        .fontWeight(900)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('sans-serif')
        .textAlign(TextAlign.Start)
        .maxLines(1)

      Row() {
        this.monthNavigationButton($r('sys.symbol.chevron_left'), () => {
          this.vm!.previousMonth();
        })

        Text('TODAY')
          .width(56)
          .height(40)
          .fontSize(9)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .textAlign(TextAlign.Center)
          .backgroundColor(this.tokens.bgBase)
          .enabled(!this.vm!.isMonthLoading)
          .opacity(this.vm!.isMonthLoading ? 0.45 : 1)
          .stateStyles({
            normal: {
              .backgroundColor(this.tokens.bgBase)
            },
            pressed: {
              .backgroundColor(this.tokens.brandPrimary)
              .fontColor(this.tokens.brandText)
            }
          })
          .onClick(() => {
            this.vm!.returnToCurrentMonth();
          })

        this.monthNavigationButton($r('sys.symbol.chevron_right'), () => {
          this.vm!.nextMonth();
        })
      }
      .width(144)
      .height(44)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(62)
    .alignItems(VerticalAlign.Center)
    .padding({ top: Spacing.xs, bottom: Spacing.xs })
    .border({ width: { bottom: 3 }, color: this.tokens.textPrimary })
  }

  @Builder
  private monthNavigationButton(symbol: Resource, action: () => void) {
    Stack() {
      SymbolGlyph(symbol)
        .fontSize(20)
        .fontWeight(700)
        .fontColor([this.tokens.textPrimary])
    }
      .width(44)
      .height(44)
      .alignContent(Alignment.Center)
      .backgroundColor(this.tokens.bgBase)
      .border({ width: 1, color: this.tokens.borderColor })
      .enabled(!this.vm!.isMonthLoading)
      .opacity(this.vm!.isMonthLoading ? 0.45 : 1)
      .stateStyles({
        normal: {
          .backgroundColor(this.tokens.bgBase)
        },
        pressed: {
          .backgroundColor(this.tokens.bgSurfacePressed)
          .scale({ x: 0.94, y: 0.94 })
        }
      })
      .animation({ duration: 100, curve: Curve.EaseOut })
      .onClick(action)
  }

  @Builder
  private activePage() {
    if (this.activeSection === AppSection.LOGS) {
      LogsSection({
        checkIns: this.vm!.checkIns,
        totalCommitCount: this.vm!.totalCommitCount,
      })
        .width('100%')
        .height('100%')
    } else if (this.activeSection === AppSection.CORE) {
      PatternsSection({ usagePatterns: this.vm!.usagePatterns })
        .width('100%')
        .height('100%')
    } else if (this.activeSection === AppSection.USER) {
      ProfileSection({
        totalCommitCount: this.vm!.totalCommitCount,
        patternCount: this.vm!.usagePatterns.length,
        onThemeSwitch: (theme: SkinTheme) => {
          this.switchTheme(theme);
        }
      })
        .width('100%')
        .height('100%')
    } else {
      CalendarSection({
        cells: this.vm!.cells,
        selectedDate: this.vm!.selectedDate,
        todayString: this.vm!.todayString,
        longestMonthStreak: this.vm!.longestMonthStreak,
        monthCommitCount: this.vm!.monthCommitCount,
        onCellTap: (date: string) => {
          this.vm!.selectDate(date);
        }
      })
        .width('100%')
        .height('100%')
    }
  }

  build() {
    Stack() {
      GridBackdrop()

      Column() {
        Row() {
          Column() {
            if (this.vm !== null) {
              HorizontalNavigation({
                active: this.activeSection,
                onNavigate: (section: AppSection) => {
                  this.activeSection = section;
                }
              })

              if (this.activeSection === AppSection.DATA) {
                this.calendarMonthHeader()
              }

              Column() {
                this.activePage()
              }
              .width('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Start)

              if (this.activeSection === AppSection.DATA) {
                CheckInInput({
                  selectedDate: this.vm!.selectedDate,
                  onLightUp: (text: string) => {
                    this.vm!.doCheckIn(text);
                  }
                })
                  .margin({ top: Spacing.xs, bottom: Spacing.sm })
              }
            } else {
              Text('INITIALIZING // ACTRACE')
                .fontSize(12)
                .fontWeight(700)
                .fontColor(this.tokens.textMuted)
                .fontFamily('monospace')
                .margin({ top: Spacing.xl })
            }
          }
          .width('100%')
          .height('100%')
          .constraintSize({ maxWidth: CONTENT_MAX_WIDTH })
          .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.xs })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')

      if (this.vm !== null && this.vm.showParticles) {
        ParticleOverlay({
          effectType: this.vm.triggeredEgg ? this.vm.triggeredEgg.effectType : 'particle_sparkle',
        })
          .width('100%')
          .height('100%')
          .hitTestBehavior(HitTestMode.Transparent)
      }

      if (this.vm !== null && this.vm.showBanner) {
        QuoteBanner({ quote: this.vm.triggeredEgg ? this.vm.triggeredEgg.quote : '' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.tokens.bgBase)
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
    }
  }

  private persistTheme(name: SkinTheme): void {
    try {
      preferences.getPreferences(getContext(this), PREFS_NAME, (err, pref) => {
        if (!err) {
          pref.put(KEY_THEME, name, (e) => {
            if (!e) {
              pref.flush();
            }
          });
        }
      });
    } catch (_e) {
    }
  }
}
