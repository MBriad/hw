/** Adapter: short synthesized feedback tones via AudioRenderer. */
import { SoundPlayer } from '../domain/ports/SoundPlayer';
import { audio } from '@kit.AudioKit';

class EasterEggStreamInfo implements audio.AudioStreamInfo {
  samplingRate: audio.AudioSamplingRate = audio.AudioSamplingRate.SAMPLE_RATE_44100;
  channels: audio.AudioChannel = audio.AudioChannel.CHANNEL_1;
  sampleFormat: audio.AudioSampleFormat = audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE;
  encodingType: audio.AudioEncodingType = audio.AudioEncodingType.ENCODING_TYPE_RAW;
}

class EasterEggRendererInfo implements audio.AudioRendererInfo {
  usage: audio.StreamUsage = audio.StreamUsage.STREAM_USAGE_GAME;
  rendererFlags: number = 0;
}

class EasterEggRendererOptions implements audio.AudioRendererOptions {
  streamInfo: audio.AudioStreamInfo = new EasterEggStreamInfo();
  rendererInfo: audio.AudioRendererInfo = new EasterEggRendererInfo();
}

export class SoundPlayerImpl implements SoundPlayer {
  async play(fileName: string): Promise<boolean> {
    let renderer: audio.AudioRenderer | null = null;
    try {
      renderer = await audio.createAudioRenderer(new EasterEggRendererOptions());
      await renderer.start();
      const tone = this.createTone(this.getFrequency(fileName));
      let offset = 0;
      while (offset < tone.byteLength) {
        const written = await renderer.write(tone.slice(offset));
        if (written <= 0) {
          break;
        }
        offset += written;
      }
      await renderer.drain();
      await renderer.stop();
      await renderer.release();
      return offset === tone.byteLength;
    } catch (_e) {
      if (renderer !== null) {
        try {
          await renderer.release();
        } catch (_releaseError) {
        }
      }
      return false;
    }
  }

  private createTone(frequency: number): ArrayBuffer {
    const sampleRate = 44100;
    const sampleCount = Math.floor(sampleRate * 0.22);
    const buffer = new ArrayBuffer(sampleCount * 2);
    const samples = new Int16Array(buffer);
    for (let i = 0; i < sampleCount; i++) {
      const progress = i / sampleCount;
      const envelope = Math.sin(Math.PI * progress);
      samples[i] = Math.floor(Math.sin(2 * Math.PI * frequency * i / sampleRate) * envelope * 9000);
    }
    return buffer;
  }

  private getFrequency(fileName: string): number {
    if (fileName === 'wind_chime') return 880;
    if (fileName === 'jojo_menace') return 440;
    if (fileName === 'healing_bell') return 740;
    if (fileName === 'anime_sparkle') return 990;
    if (fileName === 'level_up') return 1046;
    return 660;
  }
}
