import { EasterEgg } from './EasterEgg';

export enum PatternStage {
  OBSERVING = 'OBSERVING',
  CANDIDATE = 'CANDIDATE',
  MATURE = 'MATURE',
  COOLDOWN = 'COOLDOWN',
}

export class PatternSuggestion {
  topic: string;
  aliases: string[];
  confidence: number;
  quote: string;
  effectType: string;
  soundFile: string;

  constructor(
    topic: string,
    aliases: string[],
    confidence: number,
    quote: string,
    effectType: string,
    soundFile: string,
  ) {
    this.topic = topic;
    this.aliases = aliases;
    this.confidence = confidence;
    this.quote = quote;
    this.effectType = effectType;
    this.soundFile = soundFile;
  }
}

export class LearnedPattern {
  id: string;
  topic: string;
  aliases: string[];
  occurrenceCount: number;
  distinctDateCount: number;
  confidence: number;
  stage: PatternStage;
  quote: string;
  effectType: string;
  soundFile: string;
  observedDates: string[];
  cooldownUntil: number;
  lastMatchedAt: number;
  updatedAt: number;

  constructor(id: string, topic: string) {
    this.id = id;
    this.topic = topic;
    this.aliases = [];
    this.occurrenceCount = 0;
    this.distinctDateCount = 0;
    this.confidence = 0;
    this.stage = PatternStage.OBSERVING;
    this.quote = '';
    this.effectType = 'particle_sparkle';
    this.soundFile = 'level_up';
    this.observedDates = [];
    this.cooldownUntil = 0;
    this.lastMatchedAt = 0;
    this.updatedAt = 0;
  }
}

export class PatternMatchResult {
  pattern: LearnedPattern;
  egg: EasterEgg | null;

  constructor(pattern: LearnedPattern, egg: EasterEgg | null) {
    this.pattern = pattern;
    this.egg = egg;
  }
}
