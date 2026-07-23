import { ActivitySnapshot } from '../ActivitySnapshot';

export interface ILoadActivity {
  execute(): Promise<ActivitySnapshot>;
}
