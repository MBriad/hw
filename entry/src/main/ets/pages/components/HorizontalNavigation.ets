import { Spacing } from '../../common/SpacingTokens';
import { AppSection } from '../../domain/AppSection';
import { DesignTokens } from '../../domain/SkinTheme';

const TAB_WIDTH = 94;
const RAIL_HEIGHT = 44;

@Component
export struct HorizontalNavigation {
  @Consume tokens: DesignTokens;
  @Prop active: AppSection;
  onNavigate?: (section: AppSection) => void;

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
    .width(TAB_WIDTH)
    .height(RAIL_HEIGHT)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: Spacing.xxs, right: Spacing.sm })
    .stateStyles({
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
    Scroll() {
      Row() {
        this.tab(AppSection.DATA, 'CALENDAR')
        this.tab(AppSection.LOGS, 'LOGS')
        this.tab(AppSection.CORE, 'PATTERNS')
        this.tab(AppSection.USER, 'PROFILE')
      }
      .height(RAIL_HEIGHT)
    }
    .width('100%')
    .height(RAIL_HEIGHT)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .border({ width: { bottom: 1 }, color: this.tokens.textPrimary })
  }
}
