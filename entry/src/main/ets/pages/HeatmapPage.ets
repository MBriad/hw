/** Entry page for the Actrace technical activity workspace. */
import { Spacing } from '../common/SpacingTokens';
import { AppSection } from '../domain/AppSection';
import { DesignTokens, SkinTheme, ThemePalette } from '../domain/SkinTheme';
import { DebugLabels, CHINESE_DEBUG_LABELS } from '../common/DebugLabels';
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

const CONTENT_MAX_WIDTH = 420;

@Entry
@Component
struct HeatmapPage {
  @Provide tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide debugLabels: DebugLabels = CHINESE_DEBUG_LABELS;
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  @StorageLink('heatmapVM') private vm: HeatmapVM | null = null;
  @State private activeSection: AppSection = AppSection.DATA;

  aboutToAppear(): void {
    const now = new Date();
    if (this.vm !== null) {
      const vm = this.vm;
      vm.initialize(now.getFullYear(), now.getMonth() + 1).then(() => {
        this.themeName = vm.currentSkin;
        this.tokens = vm.currentTokens;
      });
    }
  }

  private switchTheme(name: SkinTheme): void {
    this.themeName = name;
    if (this.vm !== null) {
      this.vm.switchSkin(name);
      this.tokens = this.vm.currentTokens;
    } else {
      this.tokens = ThemePalette[name];
    }
  }

  @Builder
  private calendarMonthHeader() {
    Column() {
      Text(this.vm!.monthCode)
        .fontSize(28)
        .fontWeight(900)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('sans-serif')
        .maxLines(1)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: Spacing.xs, bottom: Spacing.xs })
    .border({ width: { bottom: 3 }, color: this.tokens.textPrimary })
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

}
