import { describe, it, expect } from '@ohos/hypium';
import { CheckIn } from '../main/ets/domain/CheckIn';
import { EasterEgg, UsagePattern } from '../main/ets/domain/EasterEgg';
import { UsagePatternEngine } from '../main/ets/domain/ports/UsagePatternEngine';
import { DetectEasterEgg } from '../main/ets/usecases/DetectEasterEgg';
import { MockCheckInRepo } from './mocks/MockCheckInRepo';

class MockUsagePatternEngine implements UsagePatternEngine {
  public capturedHistoryLength: number = 0;
  public capturedContent: string = '';
  public result: EasterEgg | null = null;

  evaluate(content: string, history: CheckIn[]): EasterEgg | null {
    this.capturedContent = content;
    this.capturedHistoryLength = history.length;
    return this.result;
  }

  summarize(_history: CheckIn[]): UsagePattern[] {
    return [];
  }
}

export default function detectEasterEggTest() {
  describe('DetectEasterEgg', () => {
    it('loads_history_and_delegates_to_engine', 0, async () => {
      const repo = new MockCheckInRepo();
      repo.loadAllResult = [
        { date: '2026-07-01', content: '绘画', timestamp: 1 },
        { date: '2026-07-02', content: '绘画', timestamp: 2 },
      ];
      const engine = new MockUsagePatternEngine();
      engine.result = {
        keyword: '绘画', quote: 'x3', effectType: 'particle_rise', soundFile: 'level_up'
      };
      const result = await new DetectEasterEgg(repo, engine).execute('2026-07-03', '绘画');
      expect(result !== null).assertEqual(true);
      expect(engine.capturedContent).assertEqual('绘画');
      expect(engine.capturedHistoryLength).assertEqual(2);
    });

    it('excludes_existing_record_for_same_date', 0, async () => {
      const repo = new MockCheckInRepo();
      repo.loadAllResult = [
        { date: '2026-07-01', content: '旧内容', timestamp: 1 },
        { date: '2026-07-02', content: '绘画', timestamp: 2 },
      ];
      const engine = new MockUsagePatternEngine();
      await new DetectEasterEgg(repo, engine).execute('2026-07-01', '绘画');
      expect(engine.capturedHistoryLength).assertEqual(1);
    });

    it('returns_null_without_loading_for_empty_text', 0, async () => {
      const repo = new MockCheckInRepo();
      repo.loadAllResult = [{ date: '2026-07-01', content: 'test', timestamp: 1 }];
      const engine = new MockUsagePatternEngine();
      const result = await new DetectEasterEgg(repo, engine).execute('2026-07-02', '   ');
      expect(result === null).assertEqual(true);
      expect(engine.capturedHistoryLength).assertEqual(0);
    });
  });
}
