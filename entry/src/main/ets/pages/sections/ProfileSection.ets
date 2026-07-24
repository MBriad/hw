import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { UILabels } from '../../common/UILabels';
import { SkinTheme } from '../../domain/SkinTheme';
import { DesignTokens } from '../../common/ThemeTokens';
import { DebugPanel } from '../../debug/ui/DebugPanel';
import { SkinSwitcher } from '../components/SkinSwitcher';

enum ProfileSectionKind {
  APPEARANCE = 'appearance',
  STORAGE = 'storage',
  DEVELOPER = 'developer',
}

enum ProfileSettingKind {
  THEME = 'theme',
  STORAGE_LOCATION = 'storage_location',
  LOCAL_ACTIVITY = 'local_activity',
}

@Component
export struct ProfileSection {
  @Consume tokens: DesignTokens;
  @Consume locale: string;
  @Consume uiLabels: UILabels;
  @Prop totalCommitCount: number;
  @Prop patternCount: number;
  onThemeSwitch?: (theme: SkinTheme) => void;
  onLocaleSwitch?: (locale: string) => void;

  @Builder
  private sectionLabel(index: string, kind: ProfileSectionKind) {
    Row() {
      Text(index)
        .fontSize(9)
        .fontWeight(800)
        .fontColor(this.tokens.brandPrimary)
        .fontFamily('monospace')

      Text() {
        if (kind === ProfileSectionKind.APPEARANCE) {
          Span(this.uiLabels.appearance)
        } else if (kind === ProfileSectionKind.STORAGE) {
          Span(this.uiLabels.storage)
        } else {
          Span(this.uiLabels.developer)
        }
      }
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
  private settingRow(kind: ProfileSettingKind) {
    Row() {
      Column() {
        Text() {
          if (kind === ProfileSettingKind.THEME) {
            Span(this.uiLabels.themeLabel)
          } else if (kind === ProfileSettingKind.STORAGE_LOCATION) {
            Span(this.uiLabels.storageLocation)
          } else {
            Span(this.uiLabels.localActivity)
          }
        }
          .fontSize(13)
          .fontWeight(700)
          .fontColor(this.tokens.textPrimary)
          .fontFamily('monospace')
          .maxLines(1)

        Text() {
          if (kind === ProfileSettingKind.THEME) {
            Span(this.uiLabels.colorSystem)
          } else if (kind === ProfileSettingKind.STORAGE_LOCATION) {
            Span(this.uiLabels.privateAppData)
          } else {
            Span(this.uiLabels.dataSummary)
          }
        }
          .fontSize(9)
          .fontWeight(600)
          .fontColor(this.tokens.textMuted)
          .fontFamily('monospace')
          .margin({ top: Spacing.xxs })
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text() {
        if (kind === ProfileSettingKind.STORAGE_LOCATION) {
          Span(this.uiLabels.onDevice)
        } else if (kind === ProfileSettingKind.LOCAL_ACTIVITY) {
          Span(`${this.totalCommitCount} ${this.uiLabels.commitCountLabel} / ` +
            `${this.patternCount} ${this.uiLabels.patternCountLabel}`)
        }
      }
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
        this.sectionLabel('01', ProfileSectionKind.APPEARANCE)

        Column() {
          this.settingRow(ProfileSettingKind.THEME)

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

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          Row() {
            this.localeButton('zh')
            Blank().width(Spacing.xs)
            this.localeButton('en')
          }
          .width('100%')
          .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.xs, bottom: Spacing.sm })
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('02', ProfileSectionKind.STORAGE)

        Column() {
          this.settingRow(ProfileSettingKind.STORAGE_LOCATION)

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.settingRow(ProfileSettingKind.LOCAL_ACTIVITY)
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('03', ProfileSectionKind.DEVELOPER)

        DebugPanel()
          .width('100%')
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ top: Spacing.lg, bottom: Spacing.xl })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private localeButton(locale: string) {
    Text() {
      if (locale === 'zh') {
        Span(this.uiLabels.langZh)
      } else {
        Span(this.uiLabels.langEn)
      }
    }
      .layoutWeight(1)
      .height(36)
      .fontSize(10)
      .fontWeight(800)
      .fontColor(this.locale === locale ? this.tokens.brandText : this.tokens.brandPrimary)
      .fontFamily('monospace')
      .textAlign(TextAlign.Center)
      .backgroundColor(this.locale === locale ? this.tokens.brandPrimary : this.tokens.bgBase)
      .border({ width: 1, color: this.tokens.brandPrimary })
      .stateStyles({
        normal: {
          .backgroundColor(this.locale === locale ? this.tokens.brandPrimary : this.tokens.bgBase)
          .scale({ x: 1, y: 1 })
        },
        pressed: {
          .backgroundColor(this.locale === locale ? this.tokens.brandActive : this.tokens.bgSurfacePressed)
          .scale({ x: 0.96, y: 0.96 })
        }
      })
      .animation({ duration: 100, curve: Curve.EaseOut })
      .id(`locale_button_${locale}`)
      .onClick(() => {
        if (this.locale !== locale && this.onLocaleSwitch) {
          this.onLocaleSwitch(locale);
        }
      })
  }
}
