import { CheckIn } from '../../domain/CheckIn';

/** Pure matching rules for the Logs search field. */
export class CommitSearch {
  static contentOrSequenceIndexes(checkIns: CheckIn[], query: string): number[] {
    const normalized = query.trim().toLowerCase();
    if (normalized.length === 0) {
      return [];
    }

    if (normalized.startsWith('#')) {
      const sequence = Number(normalized.substring(1));
      if (Number.isInteger(sequence) && sequence >= 1 && sequence <= checkIns.length) {
        return [checkIns.length - sequence];
      }
      return [];
    }

    const matches: number[] = [];
    for (let index = 0; index < checkIns.length; index++) {
      const checkIn = checkIns[index];
      if (checkIn.content.toLowerCase().includes(normalized)) {
        matches.push(index);
      }
    }
    return matches;
  }

  static dateIndexes(checkIns: CheckIn[], date: string): number[] {
    const normalized = date.trim();
    if (normalized.length === 0) {
      return [];
    }
    const matches: number[] = [];
    for (let index = 0; index < checkIns.length; index++) {
      if (checkIns[index].date === normalized) {
        matches.push(index);
      }
    }
    return matches;
  }
}
