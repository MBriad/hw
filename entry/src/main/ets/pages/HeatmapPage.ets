/** Entry page for the Actrace technical activity workspace. */
import { Spacing } from '../common/SpacingTokens';
import { AppSection } from '../domain/AppSection';
import { SkinTheme } from '../domain/SkinTheme';
import { DesignTokens, ThemePalette } from '../common/ThemeTokens';
import { UILabels, labelsForLocale } from '../common/UILabels';
import { pageStorage } from '../common/PageStorage';
import { CalendarVM } from '../viewmodels/CalendarVM';
import { ActivityVM } from '../viewmodels/ActivityVM';
import { ThemeVM } from '../viewmodels/ThemeVM';
import { EasterEggVM } from '../viewmodels/EasterEggVM';
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

@Entry(pageStorage)
@Component
struct HeatmapPage {
  @Provide tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide locale: string = 'zh';
  @Provide uiLabels: UILabels = labelsForLocale('zh');
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  @LocalStorageLink('calendarVM') private calendarVM: CalendarVM | null = null;
  @LocalStorageLink('activityVM') private activityVM: ActivityVM | null = null;
  @LocalStorageLink('themeVM') private themeVM: ThemeVM | null = null;
  @LocalStorageLink('easterEggVM') private easterEggVM: EasterEggVM | null = null;
  @State private activeSection: AppSection = AppSection.DATA;

  aboutToAppear(): void {
    const now = new Date();
    const calendar = this.calendarVM;
    const activity = this.activityVM;
    const theme = this.themeVM;
    if (calendar !== null && activity !== null && theme !== null) {
      theme.initialize().then(() => {
        this.themeName = theme.currentSkin;
        this.tokens = theme.currentTokens;
      });
      theme.loadLocale().then((saved: string) => {
        this.switchLocale(saved);
      });
      Promise.all([
        calendar.returnToCurrentMonth(now),
        activity.refreshAll(),
      ]);
    }
  }

  switchLocale(localeStr: string): void {
    const nextLocale = localeStr === 'en' ? 'en' : 'zh';
    this.locale = nextLocale;
    this.uiLabels = labelsForLocale(nextLocale);
    if (this.themeVM !== null) {
      this.themeVM.persistLocale(nextLocale);
    }
  }

  private switchTheme(name: SkinTheme): void {
    this.themeName = name;
    if (this.themeVM !== null) {
      this.themeVM.switchSkin(name);
      this.tokens = this.themeVM.currentTokens;
    } else {
      this.tokens = ThemePalette[name];
    }
  }

  private async doCheckIn(content: string): Promise<void> {
    const calendar = this.calendarVM;
    const activity = this.activityVM;
    const eggVM = this.easterEggVM;
    if (calendar === null || activity === null) {
      return;
    }
    const egg = await calendar.doCheckIn(content);
    await activity.refreshAll();
    if (egg !== null && eggVM !== null) {
      eggVM.present(egg);
    }
  }

  @Builder
  private calendarMonthHeader() {
    Row() {
      Text(this.calendarVM!.monthCode)
        .layoutWeight(1)
        .fontSize(26)
        .fontWeight(900)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('sans-serif')
        .textAlign(TextAlign.Start)
        .maxLines(1)

      Row() {
        this.monthNavigationButton($r('sys.symbol.chevron_left'), () => {
          this.calendarVM!.previousMonth();
        })

        Text(this.uiLabels.today)
          .width(56)
          .height(40)
          .fontSize(9)
          .fontWeight(800)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .textAlign(TextAlign.Center)
          .backgroundColor(this.tokens.bgBase)
          .enabled(!this.calendarVM!.isMonthLoading)
          .opacity(this.calendarVM!.isMonthLoading ? 0.45 : 1)
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
            this.calendarVM!.returnToCurrentMonth();
          })

        this.monthNavigationButton($r('sys.symbol.chevron_right'), () => {
          this.calendarVM!.nextMonth();
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
      .enabled(!this.calendarVM!.isMonthLoading)
      .opacity(this.calendarVM!.isMonthLoading ? 0.45 : 1)
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
        checkIns: this.activityVM!.checkIns,
        totalCommitCount: this.activityVM!.checkIns.length,
      })
        .width('100%')
        .height('100%')
    } else if (this.activeSection === AppSection.CORE) {
      PatternsSection({ usagePatterns: this.activityVM!.usagePatterns })
        .width('100%')
        .height('100%')
    } else if (this.activeSection === AppSection.USER) {
      ProfileSection({
        totalCommitCount: this.activityVM!.checkIns.length,
        patternCount: this.activityVM!.usagePatterns.length,
        onThemeSwitch: (theme: SkinTheme) => {
          this.switchTheme(theme);
        },
        onLocaleSwitch: (locale: string) => {
          this.switchLocale(locale);
        }
      })
        .width('100%')
        .height('100%')
    } else {
      CalendarSection({
        cells: this.calendarVM!.cells,
        selectedDate: this.calendarVM!.selectedDate,
        todayString: this.calendarVM!.todayString,
        longestMonthStreak: this.calendarVM!.longestMonthStreak,
        monthCommitCount: this.calendarVM!.monthCommitCount,
        onCellTap: (date: string) => {
          this.calendarVM!.selectDate(date);
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
            if (this.calendarVM !== null && this.activityVM !== null && this.themeVM !== null) {
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
                  selectedDate: this.calendarVM!.selectedDate,
                  onLightUp: (text: string) => {
                    this.doCheckIn(text);
                  }
                })
                  .margin({ top: Spacing.xs, bottom: Spacing.sm })
              }
            } else {
              Text(this.uiLabels.initializing)
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

      if (this.easterEggVM !== null && this.easterEggVM.showParticles) {
        ParticleOverlay({
          effectType: this.easterEggVM.triggeredEgg ? this.easterEggVM.triggeredEgg.effectType : 'particle_sparkle',
        })
          .width('100%')
          .height('100%')
          .hitTestBehavior(HitTestMode.Transparent)
      }

      if (this.easterEggVM !== null && this.easterEggVM.showBanner) {
        QuoteBanner({ quote: this.easterEggVM.triggeredEgg ? this.easterEggVM.triggeredEgg.quote : '' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.tokens.bgBase)
  }

}
