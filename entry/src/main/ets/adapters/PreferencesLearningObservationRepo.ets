import { preferences } from '@kit.ArkData';
import { LearningObservation } from '../domain/LearningObservation';
import { LearningObservationRepository } from '../domain/ports/LearningObservationRepository';

const STORE_NAME = 'learned_patterns';
const KEY_OBSERVATIONS = 'observations';

export class PreferencesLearningObservationRepo implements LearningObservationRepository {
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  private async getStore(): Promise<preferences.Preferences> {
    return preferences.getPreferences(this.context, STORE_NAME);
  }

  async loadPending(): Promise<LearningObservation[]> {
    const store = await this.getStore();
    const raw = await store.get(KEY_OBSERVATIONS, '[]');
    const data = typeof raw === 'string' ? raw : JSON.stringify(raw);
    return JSON.parse(data) as LearningObservation[];
  }

  async save(observation: LearningObservation): Promise<void> {
    const store = await this.getStore();
    const observations = await this.loadPending();
    const index = observations.findIndex((item: LearningObservation) => item.date === observation.date);
    if (index >= 0) {
      observations[index] = observation;
    } else {
      observations.push(observation);
    }
    await store.put(KEY_OBSERVATIONS, JSON.stringify(observations));
    await store.flush();
  }

  async clear(): Promise<void> {
    const store = await this.getStore();
    await store.put(KEY_OBSERVATIONS, '[]');
    await store.flush();
  }
}
