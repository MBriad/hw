import { LearningObservation } from '../../main/ets/domain/LearningObservation';
import { LearningObservationRepository } from '../../main/ets/domain/ports/LearningObservationRepository';

export class MockLearningObservationRepo implements LearningObservationRepository {
  public observations: LearningObservation[] = [];
  public saveCount: number = 0;
  public clearCount: number = 0;

  async loadPending(): Promise<LearningObservation[]> {
    return this.observations;
  }

  async save(observation: LearningObservation): Promise<void> {
    this.saveCount++;
    const index = this.observations.findIndex((item: LearningObservation) => item.date === observation.date);
    if (index >= 0) {
      this.observations[index] = observation;
    } else {
      this.observations.push(observation);
    }
  }

  async removeProcessed(processed: LearningObservation[]): Promise<void> {
    this.observations = this.observations.filter((item: LearningObservation) =>
      !processed.some((candidate: LearningObservation) =>
        candidate.date === item.date &&
        candidate.capturedAt === item.capturedAt &&
        candidate.content === item.content
      )
    );
  }

  async clear(): Promise<void> {
    this.clearCount++;
    this.observations = [];
  }
}
