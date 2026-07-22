import { EasterEgg } from '../domain/EasterEgg';
import { HeatmapCell } from '../domain/Streak';
import { HeatmapVM } from '../viewmodels/HeatmapVM';

const EGG_DEBUG_REPLAY_MS = 3200;

export enum EggDebugScenario {
  SPARKLE = 'SPARKLE',
  DARK = 'DARK',
  BUBBLE = 'BUBBLE',
  SAKURA = 'SAKURA',
  RISE = 'RISE',
  AT_FIELD = 'AT_FIELD',
  AUTO_DISMISS = 'AUTO_DISMISS',
  TAP_DISMISS = 'TAP_DISMISS',
  RETRIGGER_BLOCKED = 'RETRIGGER_BLOCKED',
  RAPID_TAPS = 'RAPID_TAPS',
  AFTER_END = 'AFTER_END',
}

export class DebugRuntime {
  private vm: HeatmapVM;

  constructor(vm: HeatmapVM) {
    this.vm = vm;
  }

  async loadHeatmap(): Promise<string> {
    try {
      const date = this.currentMonth();
      await this.vm.loadMonth(date.year, date.month);
      const active = this.vm.cells.filter((cell: HeatmapCell) => cell.level > 0).length;
      return `OK | cells=${active}/${this.vm.cells.length}`;
    } catch (error) {
      return this.failure(error);
    }
  }

  async loadActivity(): Promise<string> {
    try {
      await this.vm.refreshActivity();
      return `OK | checkIns=${this.vm.checkIns.length} | patterns=${this.vm.usagePatterns.length}`;
    } catch (error) {
      return this.failure(error);
    }
  }

  async reloadMonth(): Promise<string> {
    try {
      const today = this.todayMonth();
      await this.vm.loadMonth(today.year, today.month);
      return `OK | cells=${this.vm.cells.length}`;
    } catch (error) {
      return this.failure(error);
    }
  }

  async refreshData(): Promise<string> {
    try {
      await this.vm.refreshActivity();
      return `OK | commits=${this.vm.checkIns.length} | patterns=${this.vm.usagePatterns.length}`;
    } catch (error) {
      return this.failure(error);
    }
  }

  tokenSnapshot(): string {
    return `OK | theme=${this.vm.currentSkin} | primary=${this.vm.currentTokens.brandPrimary}`;
  }

  async clearRecords(): Promise<string> {
    try {
      await this.vm.clearAllRecords();
      return 'OK | records cleared';
    } catch (error) {
      return this.failure(error);
    }
  }

  runEasterEggScenario(scenario: EggDebugScenario): void {
    if (scenario === EggDebugScenario.SPARKLE) {
      this.playEasterEgg('particle_sparkle', 'level_up', 'DEBUG // SPARKLE SIGNAL');
    } else if (scenario === EggDebugScenario.DARK) {
      this.playEasterEgg('particle_dark', 'wind_chime', 'DEBUG // DARK SIGNAL');
    } else if (scenario === EggDebugScenario.BUBBLE) {
      this.playEasterEgg('particle_bubble', 'healing_bell', 'DEBUG // BUBBLE SIGNAL');
    } else if (scenario === EggDebugScenario.SAKURA) {
      this.playEasterEgg('particle_sakura', 'anime_sparkle', 'DEBUG // SAKURA SIGNAL');
    } else if (scenario === EggDebugScenario.RISE) {
      this.playEasterEgg('particle_rise', 'jojo_menace', 'DEBUG // RISE SIGNAL');
    } else if (scenario === EggDebugScenario.AT_FIELD) {
      this.playEasterEgg('eva_at_field', 'eva_alert', 'DEBUG // A.T. FIELD SIGNAL');
    } else if (scenario === EggDebugScenario.AUTO_DISMISS) {
      this.playEasterEgg('particle_sparkle', 'level_up', 'DEBUG // AUTO DISMISS');
    } else if (scenario === EggDebugScenario.TAP_DISMISS) {
      this.playEasterEgg('particle_sakura', 'anime_sparkle', 'DEBUG // TAP TO DISMISS');
    } else if (scenario === EggDebugScenario.RETRIGGER_BLOCKED) {
      this.playBlockedRetrigger();
    } else if (scenario === EggDebugScenario.RAPID_TAPS) {
      this.playRapidTaps();
    } else if (scenario === EggDebugScenario.AFTER_END) {
      this.playAfterEnd();
    }
  }

  playEasterEgg(effectType: string, soundFile: string, quote: string): void {
    this.vm.dismissEgg();
    this.vm.presentEasterEgg(this.egg('debug', quote, effectType, soundFile));
  }

  playBlockedRetrigger(): void {
    this.playEasterEgg('particle_dark', 'jojo_menace', 'DEBUG // FIRST SIGNAL');
    this.vm.presentEasterEgg(this.egg(
      'debug_blocked',
      'DEBUG // THIS SIGNAL MUST BE BLOCKED',
      'particle_sakura',
      'anime_sparkle'
    ));
  }

  playRapidTaps(): void {
    this.playEasterEgg('particle_rise', 'level_up', 'DEBUG // RAPID INPUT LOCKED');
    for (let i = 0; i < 4; i++) {
      this.vm.presentEasterEgg(this.egg(
        'debug_rapid',
        'DEBUG // DUPLICATE SIGNAL',
        'particle_bubble',
        'wind_chime'
      ));
    }
  }

  playAfterEnd(): void {
    this.playEasterEgg('particle_sparkle', 'level_up', 'DEBUG // SIGNAL ONE');
    setTimeout(() => {
      this.vm.presentEasterEgg(this.egg(
        'debug_replay',
        'DEBUG // SIGNAL TWO',
        'eva_at_field',
        'eva_alert'
      ));
    }, EGG_DEBUG_REPLAY_MS);
  }

  private egg(keyword: string, quote: string, effectType: string, soundFile: string): EasterEgg {
    return {
      keyword: keyword,
      quote: quote,
      effectType: effectType,
      soundFile: soundFile,
    };
  }

  private currentMonth(): DebugMonth {
    const parts = this.vm.monthCode.split('.');
    return new DebugMonth(parseInt(parts[0]), parseInt(parts[1]));
  }

  private todayMonth(): DebugMonth {
    const today = this.vm.todayString;
    return new DebugMonth(parseInt(today.slice(0, 4)), parseInt(today.slice(5, 7)));
  }

  private failure(error: Object): string {
    return `FAIL | ${JSON.stringify(error)}`;
  }
}

class DebugMonth {
  year: number;
  month: number;

  constructor(year: number, month: number) {
    this.year = year;
    this.month = month;
  }
}
