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
    try {
      return await preferences.getPreferences(this.context, STORE_NAME);
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async loadPending(): Promise<LearningObservation[]> {
    try {
      const store = await this.getStore();
      const raw = await store.get(KEY_OBSERVATIONS, '[]');
      const data = typeof raw === 'string' ? raw : JSON.stringify(raw);
      return JSON.parse(data) as LearningObservation[];
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async save(observation: LearningObservation): Promise<void> {
    try {
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
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async removeProcessed(processed: LearningObservation[]): Promise<void> {
    try {
      const store = await this.getStore();
      const observations = await this.loadPending();
      const remaining = observations.filter((item: LearningObservation) =>
        !processed.some((candidate: LearningObservation) =>
          candidate.date === item.date &&
          candidate.capturedAt === item.capturedAt &&
          candidate.content === item.content
        )
      );
      await store.put(KEY_OBSERVATIONS, JSON.stringify(remaining));
      await store.flush();
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }

  async clear(): Promise<void> {
    try {
      const store = await this.getStore();
      await store.put(KEY_OBSERVATIONS, '[]');
      await store.flush();
    } catch (error) {
      throw new Error(JSON.stringify(error));
    }
  }
}
