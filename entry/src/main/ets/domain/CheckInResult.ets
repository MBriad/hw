import { HeatmapCell } from './Streak';
import { CheckIn } from './CheckIn';
import { UsagePattern, EasterEgg } from './EasterEgg';

/** Result bundle from ProcessCheckIn usecase */
export class CheckInResult {
  cells: HeatmapCell[] = [];
  checkIns: CheckIn[] = [];
  usagePatterns: UsagePattern[] = [];
  egg: EasterEgg | null = null;

  constructor(cells: HeatmapCell[], checkIns: CheckIn[], patterns: UsagePattern[], egg: EasterEgg | null) {
    this.cells = cells;
    this.checkIns = checkIns;
    this.usagePatterns = patterns;
    this.egg = egg;
  }
}
