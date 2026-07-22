import { CheckInResult } from '../CheckInResult';

export interface IProcessCheckIn {
  execute(date: string, content: string, year: number, month: number): Promise<CheckInResult>;
}
