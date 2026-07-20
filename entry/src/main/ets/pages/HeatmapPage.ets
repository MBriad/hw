/** Entry page for the Actrace technical activity workspace. */
import { preferences } from '@kit.ArkData';
import { Spacing } from '../common/SpacingTokens';
import { AppSection } from '../domain/AppSection';
import { CheckIn } from '../domain/CheckIn';
import { UsagePattern } from '../domain/EasterEgg';
import { DesignTokens, SkinTheme, ThemeNames, ThemePalette } from '../domain/SkinTheme';
import { HeatmapVM } from '../viewmodels/HeatmapVM';
import { CheckInInput } from './components/CheckInInput';
import { GridBackdrop } from './components/GridBackdrop';
import { HeatmapGrid } from './components/HeatmapGrid';
import { HorizontalNavigation } from './components/HorizontalNavigation';
import { ParticleOverlay } from './components/ParticleOverlay';
import { QuoteBanner } from './components/QuoteBanner';
import { SkinSwitcher } from './components/SkinSwitcher';

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
  private dataPage() {
    Scroll() {
      Column() {
        Row() {
          Text('CALENDAR VIEW')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Blank()

          Text(`${this.vm!.cells.length} DAYS`)
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .height(38)
        .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })

        HeatmapGrid({
          cells: this.vm!.cells,
          selectedDate: this.vm!.selectedDate,
          todayString: this.vm!.todayString,
          onCellTap: (date: string) => {
            this.vm!.selectDate(date);
          }
        })
          .width('100%')
          .margin({ top: Spacing.sm })

        Row() {
          Column() {
            Text('BEST RUN')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')

            Row() {
              Text(`${this.vm!.longestMonthStreak}`)
                .fontSize(42)
                .fontWeight(900)
                .fontColor(this.tokens.textPrimary)

              Text('DAYS')
                .fontSize(10)
                .fontWeight(700)
                .fontColor(this.tokens.textMuted)
                .fontFamily('monospace')
                .margin({ left: Spacing.xxs, bottom: Spacing.xs })
            }
            .alignItems(VerticalAlign.Bottom)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('MONTH COMMITS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')

            Text(`${this.vm!.monthCommitCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.sm, bottom: Spacing.lg })
        .margin({ top: Spacing.sm })
        .border({ width: { top: 1 }, color: this.tokens.textPrimary })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private logsPage() {
    Scroll() {
      Column() {
        Row() {
          Column() {
            Text('COMMIT_LOG')
              .fontSize(28)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
              .fontFamily('monospace')

            Text('LOCAL ACTIVITY STREAM')
              .fontSize(9)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(`${this.vm!.totalCommitCount}`)
            .fontSize(38)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
        }
        .width('100%')
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        if (this.vm!.checkIns.length === 0) {
          Text('AWAITING FIRST COMMIT...')
            .width('100%')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .padding({ top: Spacing.xl, bottom: Spacing.xl })
        } else {
          ForEach(this.vm!.checkIns, (checkIn: CheckIn, index: number) => {
            Row() {
              Column() {
                Text(checkIn.date.replace(/-/g, '.'))
                  .fontSize(10)
                  .fontWeight(700)
                  .fontColor(this.tokens.textMuted)
                  .fontFamily('monospace')

                Text(checkIn.content)
                  .fontSize(15)
                  .fontWeight(600)
                  .fontColor(this.tokens.textPrimary)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: Spacing.xxs })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(String(this.vm!.checkIns.length - index).padStart(3, '0'))
                .fontSize(12)
                .fontWeight(700)
                .fontColor(this.tokens.brandPrimary)
                .fontFamily('monospace')
            }
            .width('100%')
            .padding({ top: Spacing.sm, bottom: Spacing.sm })
            .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
          }, (checkIn: CheckIn) => `${checkIn.date}-${checkIn.timestamp}`)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private corePage() {
    Scroll() {
      Column() {
        Column() {
          Text('USAGE_CORE')
            .fontSize(28)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('LOCAL PATTERN ENGINE // NO FIXED KEYWORDS')
            .fontSize(9)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        Row() {
          Column() {
            Text('LEARNED PATTERNS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.vm!.usagePatterns.length}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('MILESTONES')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text('03 / 07 / 14 / 30')
              .fontSize(12)
              .fontWeight(700)
              .fontColor(this.tokens.textPrimary)
              .fontFamily('monospace')
              .margin({ top: Spacing.sm })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.md, bottom: Spacing.md })
        .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })

        if (this.vm!.usagePatterns.length === 0) {
          Text('SIGNAL: LISTENING...')
            .width('100%')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
            .padding({ top: Spacing.xl, bottom: Spacing.xl })
        } else {
          ForEach(this.vm!.usagePatterns, (pattern: UsagePattern) => {
            Row() {
              Column() {
                Text(pattern.term.toUpperCase())
                  .fontSize(15)
                  .fontWeight(800)
                  .fontColor(this.tokens.textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(pattern.nextMilestone > 0 ? `NEXT // ${pattern.nextMilestone}` : 'LEVEL // MAX')
                  .fontSize(9)
                  .fontWeight(700)
                  .fontColor(this.tokens.textMuted)
                  .fontFamily('monospace')
                  .margin({ top: Spacing.xxs })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(`x${pattern.count}`)
                .fontSize(24)
                .fontWeight(900)
                .fontColor(this.tokens.brandPrimary)
                .fontFamily('monospace')
            }
            .width('100%')
            .padding({ top: Spacing.sm, bottom: Spacing.sm })
            .border({ width: { bottom: 1 }, color: this.tokens.borderColor })
          }, (pattern: UsagePattern) => pattern.term)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private userPage() {
    Scroll() {
      Column() {
        Column() {
          Text('USER_PROFILE')
            .fontSize(28)
            .fontWeight(900)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')

          Text('LOCAL FIRST // PRIVATE BY DEFAULT')
            .fontSize(9)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: Spacing.lg, bottom: Spacing.md })
        .border({ width: { bottom: 4 }, color: this.tokens.textPrimary })

        Row() {
          Text('THEME PROFILE')
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
          Blank()
          Text(ThemeNames[this.themeName])
            .fontSize(12)
            .fontWeight(800)
            .fontColor(this.tokens.textPrimary)
        }
        .width('100%')
        .padding({ top: Spacing.md })

        SkinSwitcher({
          onSwitch: (theme: SkinTheme) => {
            this.switchTheme(theme);
          }
        })
          .margin({ bottom: Spacing.lg })

        Row() {
          Text('STORAGE')
            .fontSize(10)
            .fontWeight(700)
            .fontColor(this.tokens.textMuted)
            .fontFamily('monospace')
          Blank()
          Text('ON DEVICE')
            .fontSize(11)
            .fontWeight(700)
            .fontColor(this.tokens.textPrimary)
            .fontFamily('monospace')
        }
        .width('100%')
        .padding({ top: Spacing.md, bottom: Spacing.md })
        .border({ width: { top: 1, bottom: 1 }, color: this.tokens.textPrimary })

        Row() {
          Column() {
            Text('TOTAL COMMITS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.vm!.totalCommitCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('PATTERNS')
              .fontSize(10)
              .fontWeight(700)
              .fontColor(this.tokens.textMuted)
              .fontFamily('monospace')
            Text(`${this.vm!.usagePatterns.length}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.lg })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private activePage() {
    if (this.activeSection === AppSection.LOGS) {
      this.logsPage()
    } else if (this.activeSection === AppSection.CORE) {
      this.corePage()
    } else if (this.activeSection === AppSection.USER) {
      this.userPage()
    } else {
      this.dataPage()
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
