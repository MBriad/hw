/**
 * Global typography @Extend styles.
 * From .agent/architecture/ui-design-system/design-tokens-and-component-patterns.md
 */

/** 大标题 H1: 24fp, weight 700, letter spacing -0.5vp */
@Extend(Text)
function h1Style(): void {
  .fontSize(24)
  .fontWeight(700)
  .letterSpacing(-0.5)
}

/** 卡片标题 H2: 18fp, weight 600, letter spacing -0.3vp */
@Extend(Text)
function h2Style(): void {
  .fontSize(18)
  .fontWeight(600)
  .letterSpacing(-0.3)
}

/** 正文 Body: 15fp, weight 400, line height 1.5 */
@Extend(Text)
function bodyStyle(): void {
  .fontSize(15)
  .fontWeight(400)
  .lineHeight(22.5)
}

/** 辅助 Caption: 12fp, weight 400 */
@Extend(Text)
function captionStyle(): void {
  .fontSize(12)
  .fontWeight(400)
}
