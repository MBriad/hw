import { preferences } from '@kit.ArkData';
import { LearnedPattern } from '../domain/LearnedPattern';
import { LearnedPatternRepository } from '../domain/ports/LearnedPatternRepository';

const STORE_NAME = 'learned_patterns';
const KEY_PATTERNS = 'patterns';

export class PreferencesLearnedPatternRepo implements LearnedPatternRepository {
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

  async loadAll(): Promise<LearnedPattern[]> {
    try {
      const store = await this.getStore();
      const raw = await store.get(KEY_PATTERNS, '[]');
      const data = typeof raw === 'string' ? raw : JSON.stringify(raw);
      return JSON.parse(data) as LearnedPattern[];
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async save(pattern: LearnedPattern): Promise<void> {
    try {
      const store = await this.getStore();
      const patterns = await this.loadAll();
      const index = patterns.findIndex((item: LearnedPattern) => item.id === pattern.id);
      if (index >= 0) {
        patterns[index] = pattern;
      } else {
        patterns.push(pattern);
      }
      await store.put(KEY_PATTERNS, JSON.stringify(patterns));
      await store.flush();
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async clear(): Promise<void> {
    try {
      const store = await this.getStore();
      await store.put(KEY_PATTERNS, '[]');
      await store.flush();
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }
}
