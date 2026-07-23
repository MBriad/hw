import { HeatmapCell } from '../../main/ets/domain/Streak';
import { ActivitySnapshot } from '../../main/ets/domain/ActivitySnapshot';
import { EasterEgg } from '../../main/ets/domain/EasterEgg';
import { LearningObservation } from '../../main/ets/domain/LearningObservation';
import { LearnedPattern, PatternSuggestion } from '../../main/ets/domain/LearnedPattern';
import { ILoadActivity } from '../../main/ets/domain/ports/ActivityUseCases';
import { IClearCheckIns, ILoadHeatmap, IRecordCheckIn } from '../../main/ets/domain/ports/HeatmapUseCases';
import { PatternLearningApi } from '../../main/ets/domain/ports/PatternLearningApi';

/**
 * Mock usecases for ViewModel testing.
 * Implements the same interfaces as real usecases (DIP).
 */
export class MockLoadHeatmap implements ILoadHeatmap {
  public capturedYear: number = 0;
  public capturedMonth: number = 0;
  public resultCells: HeatmapCell[] = [];

  async execute(year: number, month: number): Promise<HeatmapCell[]> {
    this.capturedYear = year;
    this.capturedMonth = month;
    return this.resultCells;
  }
}

export class MockRecordCheckIn implements IRecordCheckIn {
  public capturedDate: string = '';
  public capturedContent: string = '';

  async execute(date: string, content: string): Promise<void> {
    this.capturedDate = date;
    this.capturedContent = content;
  }
}

export class MockClearCheckIns implements IClearCheckIns {
  public executeCount: number = 0;

  async execute(): Promise<void> {
    this.executeCount++;
  }
}

export class MockLoadActivity implements ILoadActivity {
  public result: ActivitySnapshot = new ActivitySnapshot([], []);
  public executeCount: number = 0;

  async execute(): Promise<ActivitySnapshot> {
    this.executeCount++;
    return this.result;
  }
}

export class MockPatternLearning implements PatternLearningApi {
  public loadResult: LearnedPattern[] = [];
  public pendingObservations: LearningObservation[] = [];
  public matchResult: EasterEgg | null = null;
  public capturedContent: string = '';
  public capturedNow: number = 0;
  public capturedObservationContent: string = '';
  public capturedObservationDate: string = '';
  public capturedObservationNow: number = 0;
  public pendingCount: number = 0;
  public loadCount: number = 0;
  public clearCount: number = 0;

  async load(): Promise<LearnedPattern[]> {
    this.loadCount++;
    return this.loadResult;
  }

  async captureInput(content: string, date: string, now: number): Promise<void> {
    this.capturedObservationContent = content;
    this.capturedObservationDate = date;
    this.capturedObservationNow = now;
    this.pendingCount = content.trim().length === 0 ? this.pendingCount : 1;
  }

  async pendingObservationCount(): Promise<number> {
    return this.pendingCount;
  }

  async loadPendingBatch(limit: number): Promise<LearningObservation[]> {
    return this.pendingObservations.slice(0, limit);
  }

  async acknowledgeProcessed(observations: LearningObservation[]): Promise<void> {
    this.pendingObservations = this.pendingObservations.filter((item: LearningObservation) =>
      !observations.some((candidate: LearningObservation) =>
        candidate.date === item.date &&
        candidate.capturedAt === item.capturedAt &&
        candidate.content === item.content
      )
    );
    this.pendingCount = this.pendingObservations.length;
  }

  async observe(suggestion: PatternSuggestion, date: string, now: number): Promise<LearnedPattern> {
    const pattern = new LearnedPattern(suggestion.topic.toLowerCase(), suggestion.topic);
    pattern.aliases = suggestion.aliases;
    pattern.occurrenceCount = 1;
    pattern.distinctDateCount = 1;
    pattern.observedDates = [date];
    pattern.confidence = suggestion.confidence;
    pattern.quote = suggestion.quote;
    pattern.effectType = suggestion.effectType;
    pattern.soundFile = suggestion.soundFile;
    pattern.updatedAt = now;
    this.loadResult = [pattern];
    return pattern;
  }

  async match(content: string, now: number): Promise<EasterEgg | null> {
    this.capturedContent = content;
    this.capturedNow = now;
    return this.matchResult;
  }

  async clear(): Promise<void> {
    this.clearCount++;
    this.loadResult = [];
    this.pendingCount = 0;
  }
}
