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
    return preferences.getPreferences(this.context, STORE_NAME);
  }

  async save(checkIn: CheckIn): Promise<void> {
    const store = await this.getStore();
    const all = await this.loadAll();
    // Upsert: replace existing entry for same date, or append new
    const idx = all.findIndex((c: CheckIn) => c.date === checkIn.date);
    if (idx >= 0) {
      all[idx] = checkIn;
    } else {
      all.push(checkIn);
    }
    await store.put(KEY_CHECKINS, JSON.stringify(all));
    await store.flush();
  }

  async loadAll(): Promise<CheckIn[]> {
    const store = await this.getStore();
    const raw = await store.get(KEY_CHECKINS, '[]');
    let data: string;
    if (typeof raw === 'string') {
      data = raw;
    } else {
      data = JSON.stringify(raw);
    }
    return JSON.parse(data) as CheckIn[];
  }

  async loadByMonth(year: number, month: number): Promise<CheckIn[]> {
    const all = await this.loadAll();
    const prefix = `${year}-${String(month).padStart(2, '0')}`;
    return all.filter((c: CheckIn) => c.date.startsWith(prefix));
  }
}
