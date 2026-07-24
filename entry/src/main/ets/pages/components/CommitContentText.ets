import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { DesignTokens } from '../../common/ThemeTokens';

export class CommitContentSegment {
  text: string;
  url: string;

  constructor(text: string, url: string = '') {
    this.text = text;
    this.url = url;
  }
}

/** Local presentation parser for rendering URL fragments without changing stored content. */
export class CommitContentParser {
  static segments(content: string): CommitContentSegment[] {
    const segments: CommitContentSegment[] = [];
    const pattern = /https?:\/\/[^\s]+/g;
    let cursor = 0;
    let match: RegExpExecArray | null = pattern.exec(content);
    while (match !== null) {
      if (match.index > cursor) {
        segments.push(new CommitContentSegment(content.substring(cursor, match.index)));
      }
      segments.push(new CommitContentSegment(match[0], match[0]));
      cursor = match.index + match[0].length;
      match = pattern.exec(content);
    }
    if (cursor < content.length || segments.length === 0) {
      segments.push(new CommitContentSegment(content.substring(cursor)));
    }
    return segments;
  }
}

@Component
export struct CommitContentText {
  @Consume tokens: DesignTokens;
  @Prop content: string;
  @Prop sequence: string;
  @Prop timestamp: string;
  @Prop componentId: string;
  @State private activeUrl: string = '';
  @State private popupVisible: boolean = false;
  @State private popupPinned: boolean = false;

  private showUrl(url: string, pinned: boolean): void {
    this.activeUrl = url;
    this.popupPinned = pinned;
    this.popupVisible = true;
  }

  private leaveUrl(url: string): void {
    if (!this.popupPinned && this.activeUrl === url) {
      this.popupVisible = false;
      this.activeUrl = '';
    }
  }

  private firstUrl(): string {
    const segments = CommitContentParser.segments(this.content);
    for (let index = 0; index < segments.length; index++) {
      if (segments[index].url.length > 0) {
        return segments[index].url;
      }
    }
    return '';
  }

  @Builder
  private urlPopup() {
    Column() {
      Text(this.activeUrl)
        .width('100%')
        .fontSize(11)
        .fontWeight(700)
        .fontColor(this.tokens.brandText)

      Text(`${this.sequence}  ${this.timestamp}`)
        .width('100%')
        .fontSize(9)
        .fontWeight(600)
        .fontColor(this.tokens.textMuted)
        .fontFamily('monospace')
        .margin({ top: Spacing.xs })
    }
    .width(260)
    .padding(Spacing.sm)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: 1, color: this.tokens.borderColor })
    .borderRadius(Radius.none)
    .id('logs-url-popup')
  }

  build() {
    Text() {
      ForEach(CommitContentParser.segments(this.content), (segment: CommitContentSegment) => {
        if (segment.url.length > 0) {
          Span(segment.text)
            .fontColor(this.tokens.brandText)
            .decoration({ type: TextDecorationType.Underline, color: this.tokens.brandText })
            .onHover((isHover: boolean) => {
              if (isHover) {
                this.showUrl(segment.url, false);
              } else {
                this.leaveUrl(segment.url);
              }
            })
            .onClick(() => {
              this.showUrl(segment.url, true);
            })
            .id('logs-url-link')
        } else {
          Span(segment.text)
            .fontColor(this.tokens.textPrimary)
        }
      }, (segment: CommitContentSegment, index: number) => `${index}-${segment.text}`)
    }
    .width('100%')
    .fontSize(14)
    .fontWeight(700)
    .fontColor(this.tokens.textPrimary)
    .onHover((isHover: boolean) => {
      const url = this.firstUrl();
      if (url.length > 0) {
        if (isHover) {
          this.showUrl(url, false);
        } else {
          this.leaveUrl(url);
        }
      }
    })
    .onClick(() => {
      const url = this.firstUrl();
      if (url.length > 0) {
        this.showUrl(url, true);
      }
    })
    .bindPopup(this.popupVisible, {
      builder: this.urlPopup,
      placement: Placement.Bottom,
      popupColor: this.tokens.bgSurface,
      enableArrow: true,
      autoCancel: true,
      onStateChange: (event: PopupStateChangeParam) => {
        if (!event.isVisible) {
          this.popupVisible = false;
          this.popupPinned = false;
          this.activeUrl = '';
        }
      },
    })
    .id(this.componentId)
  }
}
