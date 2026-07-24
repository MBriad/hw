/** Result returned by a pending-observation analysis cycle. */
export class AnalyzeResult {
  analyzed: number;
  patternsCreated: number;

  constructor(analyzed: number, patternsCreated: number) {
    this.analyzed = analyzed;
    this.patternsCreated = patternsCreated;
  }
}

export interface AnalyzePendingUseCase {
  execute(now: number): Promise<AnalyzeResult>;
}
