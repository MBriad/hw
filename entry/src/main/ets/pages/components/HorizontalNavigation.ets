import { Spacing } from '../../common/SpacingTokens';
import { UILabels, labelsForLocale } from '../../common/UILabels';
import { AppSection } from '../../domain/AppSection';
import { DesignTokens, SkinTheme } from '../../domain/SkinTheme';

const RAIL_HEIGHT = 44;

@Component
export struct HorizontalNavigation {
  @Consume tokens: DesignTokens;
  @Consume locale: string;
  @Consume themeName: SkinTheme;
  @Prop active: AppSection;
  onNavigate?: (section: AppSection) => void;

  private labels(): UILabels {
    return labelsForLocale(this.locale);
  }

  @Builder
  private tab(section: AppSection, label: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontWeight(this.active === section ? 800 : 600)
        .fontColor(this.active === section ? this.tokens.textPrimary : this.tokens.textPlaceholder)
        .fontFamily('monospace')
        .maxLines(1)

      Column()
        .width('100%')
        .height(3)
        .backgroundColor(this.active === section ? this.tokens.brandPrimary : Color.Transparent)
        .margin({ top: Spacing.xs })
    }
    .layoutWeight(1)
    .height(RAIL_HEIGHT)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: Spacing.xxs, right: Spacing.sm })
    .backgroundColor(this.tokens.bgBase)
    .stateStyles({
      normal: {
        .backgroundColor(this.tokens.bgBase)
        .scale({ x: 1, y: 1 })
      },
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.97, y: 0.97 })
      }
    })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onClick(() => {
      if (this.onNavigate) {
        this.onNavigate(section);
      }
    })
  }

  build() {
    Row() {
      this.tab(AppSection.DATA, this.labels().tabCalendar)
      this.tab(AppSection.LOGS, this.labels().tabLogs)
      this.tab(AppSection.CORE, this.labels().tabPatterns)
      this.tab(AppSection.USER, this.labels().tabProfile)
    }
    .height(RAIL_HEIGHT)
    .width('100%')
    .backgroundColor(this.tokens.bgBase)
    .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })
    .id(`horizontal_navigation_${this.themeName}_${this.locale}`)
  }
}
