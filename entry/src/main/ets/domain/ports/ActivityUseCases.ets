import { ActivitySnapshot } from '../ActivitySnapshot';
import { EasterEgg } from '../EasterEgg';

export interface ILoadActivity {
  execute(): Promise<ActivitySnapshot>;
}

export interface IDetectEasterEgg {
  execute(date: string, content: string): Promise<EasterEgg | null>;
}
