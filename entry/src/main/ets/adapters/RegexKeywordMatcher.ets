/**
 * Adapter: Regex-based keyword-to-easter-egg matching.
 * Implements KeywordMatcher port. Uses hardcoded rule set.
 */
import { EasterEgg, EasterEggRule } from '../domain/EasterEgg';
import { KeywordMatcher } from '../domain/ports/KeywordMatcher';

/** Master rule set — add new triggers here */
const RULES: EasterEggRule[] = [
  {
    keywords: ['Rust', 'rust', 'Rustacean'],
    quote: '检测到 Rustacean Commit，当前世界线变动率：0.231492%',
    effectType: 'eva_at_field',
    soundFile: 'eva_alert',
  },
  {
    keywords: ['加班', '熬夜', '凌晨', '深夜', '爆肝'],
    quote: '深夜 Commit 确认。你又在燃烧生命了呢……不过，这份觉悟，我并不讨厌。',
    effectType: 'particle_dark',
    soundFile: 'wind_chime',
  },
  {
    keywords: ['Bug', 'bug', 'BUG', '调试', '修复', '修bug', '修Bug'],
    quote: 'Bug 歼灭者在此！每一个被消灭的 Bug 都是通向神级的阶梯。',
    effectType: 'particle_sparkle',
    soundFile: 'jojo_menace',
  },
  {
    keywords: ['摸鱼', '划水', '摆烂', '不想上班'],
    quote: '哼~ 偶尔摸摸鱼也不错嘛。反正世界不会因为少写两行代码就毁灭的。',
    effectType: 'particle_bubble',
    soundFile: 'healing_bell',
  },
  {
    keywords: ['动漫', '追番', '新番', '番剧'],
    quote: '二次元雷达启动！今天又在追什么番？作业写完了吗（笑）？',
    effectType: 'particle_sakura',
    soundFile: 'anime_sparkle',
  },
  {
    keywords: ['学习', '看完了', '学完了', '学会了'],
    quote: '知识 +1！今日的积累，终将成为明日的武器。加油！',
    effectType: 'particle_rise',
    soundFile: 'level_up',
  },
];

export class RegexKeywordMatcher implements KeywordMatcher {
  match(text: string): EasterEgg | null {
    const lower = text.toLowerCase();
    for (let i = 0; i < RULES.length; i++) {
      const rule = RULES[i];
      for (let j = 0; j < rule.keywords.length; j++) {
        if (lower.includes(rule.keywords[j].toLowerCase())) {
          return {
            keyword: rule.keywords[j],
            quote: rule.quote,
            effectType: rule.effectType,
            soundFile: rule.soundFile,
          };
        }
      }
    }
    return null;
  }
}
