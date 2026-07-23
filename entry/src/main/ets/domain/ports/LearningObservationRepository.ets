import { LearningObservation } from '../LearningObservation';

export interface LearningObservationRepository {
  loadPending(): Promise<LearningObservation[]>;
  save(observation: LearningObservation): Promise<void>;
  removeProcessed(observations: LearningObservation[]): Promise<void>;
  clear(): Promise<void>;
}
