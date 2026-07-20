import { CheckIn } from './CheckIn';
import { UsagePattern } from './EasterEgg';

export class ActivitySnapshot {
  checkIns: CheckIn[];
  patterns: UsagePattern[];

  constructor(checkIns: CheckIn[], patterns: UsagePattern[]) {
    this.checkIns = checkIns;
    this.patterns = patterns;
  }
}
