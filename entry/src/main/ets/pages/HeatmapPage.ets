/** Entry page for the Actrace technical activity workspace. */
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

const CONTENT_MAX_WIDTH = 420;

@Entry
@Component
struct HeatmapPage {
  @Provide @Watch('onThemeChange') tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  @StorageLink('heatmapVM') private vm: HeatmapVM | null = null;
  @State private activeSection: AppSection = AppSection.DATA;
  @State private tokenVersion: number = 0;

  aboutToAppear(): void {
    const now = new Date();
    if (this.vm !== null) {
      this.vm.initialize(now.getFullYear(), now.getMonth() + 1);
    }
    this.loadPersistedTheme();
  }

  onThemeChange(): void {
  }

  private async switchTheme(name: SkinTheme): Promise<void> {
    const viewModel = this.vm;
    if (viewModel === null) {
      return;
    }

    // switchSkin updates its observable state synchronously, before persistence awaits.
    const pendingSwitch = viewModel.switchSkin(name);
    this.themeName = viewModel.currentSkin;
    this.tokens = viewModel.currentTokens;
    this.tokenVersion++;

    await pendingSwitch;
    if (this.vm === viewModel && viewModel.currentSkin === name) {
      this.themeName = viewModel.currentSkin;
      this.tokens = viewModel.currentTokens;
      this.tokenVersion++;
    }
  }

  private sectionLabel(): string {
    if (this.activeSection === AppSection.LOGS) {
      return 'LOG STREAM';
    }
    if (this.activeSection === AppSection.CORE) {
      return 'CORE LEARNING';
    }
    if (this.activeSection === AppSection.USER) {
      return 'USER PROFILE';
    }
    return 'DATA ACTIVE';
  }

  @Builder
  private systemHeader() {
    Row() {
      Text('ACTRACE_OS // V.CORE')
        .fontSize(9)
        .fontWeight(700)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')

      Blank()

      Row() {
        Column()
          .width(6)
          .height(6)
          .backgroundColor(this.tokens.brandPrimary)
          .margin({ right: Spacing.xxs })

        Text(`STATUS: ${this.sectionLabel()}`)
          .fontSize(9)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
      }
    }
    .width('100%')
    .height(28)
    .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })
  }

  @Builder
  private workspaceHeader() {
    Column() {
      Text('PERSONAL ACTIVITY MATRIX')
        .fontSize(10)
        .fontWeight(700)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')

      Text(this.vm!.monthCode)
        .fontSize(46)
        .fontWeight(900)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('sans-serif')
        .maxLines(1)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: Spacing.md, bottom: Spacing.sm })
    .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })
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
            this.systemHeader()

            if (this.vm !== null) {
              this.workspaceHeader()

              HorizontalNavigation({
                active: this.activeSection,
                onNavigate: (section: AppSection) => {
                  this.activeSection = section;
                }
              })

              Column() {
                this.activePage()
              }
              .width('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Start)

              CheckInInput({
                selectedDate: this.vm!.selectedDate,
                onLightUp: (text: string) => {
                  this.vm!.doCheckIn(text);
                }
              })
                .margin({ top: Spacing.xs, bottom: Spacing.sm })
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
    .id(`heatmap_v${this.tokenVersion}`)
  }

  private async loadPersistedTheme(): Promise<void> {
    const viewModel = this.vm;
    if (viewModel === null) {
      return;
    }
    await viewModel.loadPersistedSkin();
    this.themeName = viewModel.currentSkin;
    this.tokens = viewModel.currentTokens;
    this.tokenVersion++;
  }
}
