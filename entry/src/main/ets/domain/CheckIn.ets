/** Domain entity: a single check-in record. Pure ArkTS. */
export class CheckIn {
  date: string;
  content: string;
  timestamp: number;

  constructor(date: string, content: string, timestamp: number) {
    this.date = date;
    this.content = content;
    this.timestamp = timestamp;
  }
}
