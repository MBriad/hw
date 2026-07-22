import { Spacing } from '../../common/SpacingTokens';
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

  build() {
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
            if (this.onThemeSwitch) {
              this.onThemeSwitch(theme);
            }
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
            Text(`${this.totalCommitCount}`)
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
            Text(`${this.patternCount}`)
              .fontSize(42)
              .fontWeight(900)
              .fontColor(this.tokens.textPrimary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: Spacing.lg })

        DebugPanel()
          .width('100%')
          .margin({ top: Spacing.lg })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
