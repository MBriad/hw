/**
 * Reusable mock implementations for port interfaces.
 * ArkTS strict mode requires named classes for object literals.
 */
import { CheckIn } from '../../main/ets/domain/CheckIn';
import { CheckInRepository } from '../../main/ets/domain/ports/CheckInRepository';

/**
 * In-memory mock of CheckInRepository.
 * Captures save() calls and returns configured data.
 */
export class MockCheckInRepo implements CheckInRepository {
  public savedCheckIns: CheckIn[] = [];
  public loadAllResult: CheckIn[] = [];
  public loadByMonthResult: CheckIn[] = [];
  public lastSavedDate: string = '';
  public lastSavedContent: string = '';
  public lastSavedTimestamp: number = 0;

  async save(checkIn: CheckIn): Promise<void> {
    this.savedCheckIns.push(checkIn);
    this.lastSavedDate = checkIn.date;
    this.lastSavedContent = checkIn.content;
    this.lastSavedTimestamp = checkIn.timestamp;
  }

  async loadAll(): Promise<CheckIn[]> {
    return this.loadAllResult;
  }

  async loadByMonth(_year: number, _month: number): Promise<CheckIn[]> {
    return this.loadByMonthResult;
  }

  async clear(): Promise<void> {
    this.savedCheckIns = [];
    this.loadAllResult = [];
    this.loadByMonthResult = [];
  }
}
