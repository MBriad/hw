import { Radius } from '../../common/RadiusTokens';
import { Spacing } from '../../common/SpacingTokens';
import { UILabels } from '../../common/UILabels';
import { CheckIn } from '../../domain/CheckIn';
import { DesignTokens } from '../../common/ThemeTokens';
import { CommitSearch } from '../support/CommitSearch';
import { CommitDateSearchDialog } from './CommitDateSearchDialog';

enum SearchPopoverAction {
  OPEN = 'open',
  DATE = 'date',
  CLOSE = 'close',
}

/** Floating search control for commit content, display sequence, and exact dates. */
@Component
export struct CommitSearchPopover {
  @Consume tokens: DesignTokens;
  @Consume uiLabels: UILabels;
  @Prop checkIns: CheckIn[];
  onSelect?: (key: string) => void;
  @State private expanded: boolean = false;
  @State private query: string = '';
  @State private dateQuery: string = '';
  @State private matchKeys: string[] = [];
  @State private activeMatch: number = -1;
  private activeMatchCursor: number = -1;

  private dateController: CustomDialogController = new CustomDialogController({
    builder: CommitDateSearchDialog({
      initialDate: this.defaultDate(),
      onConfirm: (date: string) => this.runDateSearch(date),
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
  });

  private commitKey(checkIn: CheckIn): string {
    return `${checkIn.date}-${checkIn.timestamp}`;
  }

  private defaultDate(): string {
    return this.checkIns.length > 0 ? this.checkIns[0].date : '';
  }

  private selectIndexes(indexes: number[]): void {
    const keys: string[] = [];
    for (let position = 0; position < indexes.length; position++) {
      keys.push(this.commitKey(this.checkIns[indexes[position]]));
    }
    this.matchKeys = keys;
    this.activeMatch = keys.length > 0 ? 0 : -1;
    this.activeMatchCursor = this.activeMatch;
    if (keys.length > 0 && this.onSelect) {
      this.onSelect(keys[0]);
    }
  }

  private runTextSearch(): void {
    this.dateQuery = '';
    this.selectIndexes(CommitSearch.contentOrSequenceIndexes(this.checkIns, this.query));
  }

  private runDateSearch(date: string): void {
    this.query = '';
    this.dateQuery = date;
    this.selectIndexes(CommitSearch.dateIndexes(this.checkIns, date));
  }

  private moveMatch(offset: number): void {
    if (this.matchKeys.length === 0) {
      return;
    }
    const current = this.activeMatchCursor >= 0 ? this.activeMatchCursor : this.activeMatch;
    this.activeMatchCursor = (current + offset + this.matchKeys.length) % this.matchKeys.length;
    this.activeMatch = this.activeMatchCursor;
    if (this.onSelect) {
      this.onSelect(this.matchKeys[this.activeMatchCursor]);
    }
  }

  private close(): void {
    this.expanded = false;
    this.query = '';
    this.dateQuery = '';
    this.matchKeys = [];
    this.activeMatch = -1;
    this.activeMatchCursor = -1;
  }

  private resultLabel(): string {
    if (this.query.trim().length === 0 && this.dateQuery.length === 0) {
      return '';
    }
    if (this.matchKeys.length === 0) {
      return this.uiLabels.noSearchResults;
    }
    const prefix = this.dateQuery.length > 0 ? `${this.dateQuery} ` : '';
    return `${prefix}${this.activeMatch + 1} / ${this.matchKeys.length}`;
  }

  private runAction(action: SearchPopoverAction): void {
    if (action === SearchPopoverAction.OPEN) {
      this.expanded = true;
    } else if (action === SearchPopoverAction.DATE) {
      this.dateController.open();
    } else {
      this.close();
    }
  }

  @Builder
  private iconButton(id: string, icon: Resource, enabled: boolean, action: SearchPopoverAction) {
    Stack() {
      SymbolGlyph(icon)
        .fontSize(17)
        .fontWeight(700)
        .fontColor([enabled ? this.tokens.textPrimary : this.tokens.textPlaceholder])
    }
    .width(40)
    .height(40)
    .alignContent(Alignment.Center)
    .enabled(enabled)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: { left: 1 }, color: this.tokens.borderColor })
    .borderRadius(Radius.none)
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.94, y: 0.94 })
      }
    })
    .animation({ duration: 100 })
    .onClick(() => {
      this.runAction(action);
    })
    .id(id)
  }

  @Builder
  private searchSubmitButton() {
    Stack() {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(17)
        .fontWeight(700)
        .fontColor([this.query.trim().length > 0 ? this.tokens.textPrimary : this.tokens.textPlaceholder])
    }
    .width(40)
    .height(40)
    .alignContent(Alignment.Center)
    .enabled(this.query.trim().length > 0)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: { left: 1 }, color: this.tokens.borderColor })
    .borderRadius(Radius.none)
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.94, y: 0.94 })
      }
    })
    .animation({ duration: 100 })
    .onClick(() => {
      this.runTextSearch();
    })
    .id('logs-search-submit')
  }

  @Builder
  private previousMatchButton() {
    Button() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(17)
        .fontWeight(700)
        .fontColor([this.matchKeys.length > 1 ? this.tokens.textPrimary : this.tokens.textPlaceholder])
    }
    .width(40)
    .height(40)
    .padding(0)
    .enabled(true)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: { left: 1 }, color: this.tokens.borderColor })
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.94, y: 0.94 })
      }
    })
    .animation({ duration: 100 })
    .zIndex(2)
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      this.moveMatch(-1);
    })
    .id('logs-search-prev')
  }

  @Builder
  private nextMatchButton() {
    Button() {
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(17)
        .fontWeight(700)
        .fontColor([this.matchKeys.length > 1 ? this.tokens.textPrimary : this.tokens.textPlaceholder])
    }
    .width(40)
    .height(40)
    .padding(0)
    .enabled(true)
    .backgroundColor(this.tokens.bgSurface)
    .border({ width: { left: 1 }, color: this.tokens.borderColor })
    .stateStyles({
      pressed: {
        .backgroundColor(this.tokens.bgSurfacePressed)
        .scale({ x: 0.94, y: 0.94 })
      }
    })
    .animation({ duration: 100 })
    .zIndex(2)
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      this.moveMatch(1);
    })
    .id('logs-search-next')
  }

  build() {
    Stack() {
      if (this.expanded) {
        Column() {
          Row() {
            TextInput({ placeholder: this.uiLabels.searchCommits, text: this.query })
              .layoutWeight(1)
              .height(40)
              .fontSize(12)
              .fontWeight(600)
              .fontColor(this.tokens.textPrimary)
              .placeholderColor(this.tokens.textPlaceholder)
              .fontFamily('monospace')
              .backgroundColor(Color.Transparent)
              .borderRadius(Radius.none)
              .padding({ left: Spacing.sm, right: Spacing.xs })
              .caretColor(this.tokens.brandPrimary)
              .enterKeyType(EnterKeyType.Search)
              .onChange((value: string) => {
                this.query = value;
                this.dateQuery = '';
                this.matchKeys = [];
                this.activeMatch = -1;
                this.activeMatchCursor = -1;
              })
              .onSubmit(() => this.runTextSearch())
              .id('logs-search-input')

            this.searchSubmitButton()
            this.iconButton('logs-search-date', $r('sys.symbol.calendar'), true, SearchPopoverAction.DATE)
            this.iconButton('logs-search-close', $r('sys.symbol.xmark'), true, SearchPopoverAction.CLOSE)
          }
          .width('100%')
          .height(40)

          Row() {
            Text(this.resultLabel())
              .layoutWeight(1)
              .fontSize(9)
              .fontWeight(700)
              .fontColor(this.matchKeys.length > 0 ? this.tokens.textMuted : this.tokens.brandPrimary)
              .fontFamily('monospace')
              .maxLines(1)
              .padding({ left: Spacing.sm, right: Spacing.xs })
              .id('logs-search-result')

            Row() {
              this.previousMatchButton()
              this.nextMatchButton()
            }
            .width(80)
            .height(40)
            .zIndex(2)
            .hitTestBehavior(HitTestMode.Block)
          }
          .width('100%')
          .height(40)
          .border({ width: { top: 1 }, color: this.tokens.borderColor })
        }
        .width('88%')
        .backgroundColor(this.tokens.bgSurface)
        .border({ width: 1, color: this.tokens.brandPrimary })
        .borderRadius(Radius.none)
        .id('logs-search-popover')
      } else {
        this.iconButton('logs-search-toggle', $r('sys.symbol.magnifyingglass'), true, SearchPopoverAction.OPEN)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopEnd)
    .hitTestBehavior(HitTestMode.Transparent)
  }
}
