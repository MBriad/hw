import { LearningObservation } from '../LearningObservation';

export interface LearningObservationRepository {
  loadPending(): Promise<LearningObservation[]>;
  save(observation: LearningObservation): Promise<void>;
  clear(): Promise<void>;
}
