export class LearningObservation {
  date: string;
  content: string;
  capturedAt: number;

  constructor(date: string, content: string, capturedAt: number) {
    this.date = date;
    this.content = content;
    this.capturedAt = capturedAt;
  }
}
