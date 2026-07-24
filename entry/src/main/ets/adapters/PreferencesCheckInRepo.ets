/**
 * Adapter: Check-in persistence using @ohos.data.preferences.
 * Implements CheckInRepository port.
 */
import { preferences } from '@kit.ArkData';
import { CheckIn } from '../domain/CheckIn';
import { CheckInRepository } from '../domain/ports/CheckInRepository';

const STORE_NAME = 'heatmap_checkins';
const KEY_CHECKINS = 'checkins';

export class PreferencesCheckInRepo implements CheckInRepository {
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  private async getStore(): Promise<preferences.Preferences> {
    try {
      return await preferences.getPreferences(this.context, STORE_NAME);
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async save(checkIn: CheckIn): Promise<void> {
    try {
      const store = await this.getStore();
      const all = await this.loadAll();
      all.push(checkIn);
      await store.put(KEY_CHECKINS, JSON.stringify(all));
      await store.flush();
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async loadAll(): Promise<CheckIn[]> {
    try {
      const store = await this.getStore();
      const raw = await store.get(KEY_CHECKINS, '[]');
      let data: string;
      if (typeof raw === 'string') {
        data = raw;
      } else {
        data = JSON.stringify(raw);
      }
      const parsed = JSON.parse(data) as CheckIn[];
      return parsed.map((item: CheckIn) => new CheckIn(item.date, item.content, item.timestamp));
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async loadByMonth(year: number, month: number): Promise<CheckIn[]> {
    const all = await this.loadAll();
    const prefix = `${year}-${String(month).padStart(2, '0')}`;
    return all.filter((c: CheckIn) => c.date.startsWith(prefix));
  }

  async clear(): Promise<void> {
    try {
      const store = await this.getStore();
      await store.put(KEY_CHECKINS, '[]');
      await store.flush();
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }
}
