import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { DesignTokens, SkinTheme, ThemeNames } from '../../domain/SkinTheme';
import { DebugPanel } from '../components/DebugPanel';
import { SkinSwitcher } from '../components/SkinSwitcher';

@Component
export struct ProfileSection {
  @Consume tokens: DesignTokens;
  @Consume themeName: SkinTheme;
  @Prop totalCommitCount: number;
  @Prop patternCount: number;
  onThemeSwitch?: (theme: SkinTheme) => void;

  @Builder
  private sectionLabel(index: string, label: string) {
    Row() {
      Text(index)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text(label)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')
        .margin({ left: Spacing.xs })
    }
    .width('100%')
    .padding({ bottom: Spacing.xs })
  }

  @Builder
  private settingRow(title: string, subtitle: string, value: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .maxLines(1)

        Text(subtitle)
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(value)
        .fontSize(11)
        .fontWeight(800)
        .fontColor(this.tokens.textPrimary)
        .fontFamily('monospace')
        .textAlign(TextAlign.End)
        .maxLines(2)
        .constraintSize({ maxWidth: 148 })
    }
    .width('100%')
    .height(62)
    .padding({ left: Spacing.md, right: Spacing.md })
  }

  build() {
    Scroll() {
      Column() {
        this.sectionLabel('01', 'APPEARANCE')

        Column() {
          this.settingRow('THEME', 'COLOR SYSTEM', ThemeNames[this.themeName])

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          SkinSwitcher({
            onSwitch: (theme: SkinTheme) => {
              if (this.onThemeSwitch) {
                this.onThemeSwitch(theme);
              }
            }
          })
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('02', 'STORAGE')

        Column() {
          this.settingRow('STORAGE LOCATION', 'PRIVATE APP DATA', 'ON DEVICE')

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.settingRow('LOCAL ACTIVITY', 'DATA SUMMARY',
            `${this.totalCommitCount} COMMITS / ${this.patternCount} PATTERNS`)
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('03', 'DEVELOPER')

        DebugPanel()
          .width('100%')
      }
      .width('100%')
      .padding({ top: Spacing.lg, bottom: Spacing.xl })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
