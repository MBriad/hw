import { Spacing } from '../../common/SpacingTokens';
import { Radius } from '../../common/RadiusTokens';
import { UILabels, labelsForLocale } from '../../common/UILabels';
import { DesignTokens, SkinTheme } from '../../domain/SkinTheme';
import { DebugPanel } from '../../debug/ui/DebugPanel';
import { SkinSwitcher } from '../components/SkinSwitcher';

@Component
export struct ProfileSection {
  @Consume tokens: DesignTokens;
  @Consume locale: string;
  @Prop totalCommitCount: number;
  @Prop patternCount: number;
  onThemeSwitch?: (theme: SkinTheme) => void;
  onLocaleSwitch?: (locale: string) => void;

  private labels(): UILabels {
    return labelsForLocale(this.locale);
  }

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
        this.sectionLabel('01', this.labels().appearance)

        Column() {
          this.settingRow(this.labels().themeLabel, this.labels().colorSystem, '')

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

        this.sectionLabel('02', this.labels().storage)

        Column() {
          this.settingRow(this.labels().storageLocation, this.labels().privateAppData, this.labels().onDevice)

          Divider()
            .color(this.tokens.borderColor)
            .strokeWidth(1)

          this.settingRow(this.labels().localActivity, this.labels().dataSummary,
            `${this.totalCommitCount} ${this.labels().commitCountLabel} / ` +
              `${this.patternCount} ${this.labels().patternCountLabel}`)
        }
        .width('100%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.borderColor })
        .borderRadius(Radius.none)

        Blank()
          .height(Spacing.lg)

        this.sectionLabel('03', this.labels().developer)

        DebugPanel({
          onLocaleSwitch: this.onLocaleSwitch,
        })
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
}
