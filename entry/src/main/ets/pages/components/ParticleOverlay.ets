/**
 * Humble View: Particle burst effect overlay for easter egg triggers.
 * Spawns colored particles that fade and disappear over ~1.5s.
 * Non-blocking — user can still interact with the page.
 */
import { DesignTokens } from '../../domain/SkinTheme';

class Particle {
  x: number;
  y: number;
  size: number;
  color: ResourceColor;
  vx: number;
  vy: number;

  constructor(x: number, y: number, size: number, color: ResourceColor, vx: number, vy: number) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.color = color;
    this.vx = vx;
    this.vy = vy;
  }
}

@Component
export struct ParticleOverlay {
  @Consume tokens: DesignTokens;
  @Prop effectType: string = 'particle_sparkle';
  @State private particles: Particle[] = [];
  @State private visible: boolean = false;
  @State private progress: number = 0;

  aboutToAppear(): void {
    this.show();
  }

  show(): void {
    this.visible = true;
    this.progress = 0;
    this.generateParticles();
    setTimeout(() => {
      animateTo({ duration: 1200, curve: Curve.EaseOut }, () => {
        this.progress = 1;
      });
    }, 16);
    setTimeout(() => {
      this.visible = false;
      this.particles = [];
    }, 1600);
  }

  private generateParticles(): void {
    const count = 25;
    const colors = this.getColorsForEffect();
    const p: Particle[] = [];
    for (let i = 0; i < count; i++) {
      const angle = (Math.random() * Math.PI * 2);
      const distance = 24 + Math.random() * 20;
      p.push(new Particle(
        50,
        48,
        4 + Math.random() * 8,
        colors[i % colors.length],
        Math.cos(angle) * distance,
        Math.sin(angle) * distance - 10,
      ));
    }
    this.particles = p;
  }

  private getColorsForEffect(): ResourceColor[] {
    switch (this.effectType) {
      case 'eva_at_field':
        return [this.tokens.brandAccent, this.tokens.brandActive, this.tokens.brandPrimary, this.tokens.textPrimary];
      case 'particle_dark':
        return [this.tokens.brandActive, this.tokens.brandPrimary, this.tokens.textSecondary, this.tokens.brandText];
      case 'particle_sakura':
        return [this.tokens.brandAccent, this.tokens.brandPrimary, this.tokens.brandText, this.tokens.brandLight];
      case 'particle_bubble':
        return [this.tokens.brandPrimary, this.tokens.brandText, this.tokens.brandLight, this.tokens.brandActive];
      case 'particle_rise':
        return [this.tokens.brandPrimary, this.tokens.brandAccent, this.tokens.brandText, this.tokens.textSecondary];
      default:
        return [this.tokens.brandAccent, this.tokens.brandPrimary, this.tokens.brandText, this.tokens.brandLight];
    }
  }

  build() {
    if (this.visible) {
      Stack() {
        ForEach(this.particles, (p: Particle, index: number) => {
          Rect()
            .width(p.size)
            .height(p.size)
            .fill(p.color)
            .opacity(1.0 - this.progress)
            .position({
              x: `${p.x + p.vx * this.progress}%`,
              y: `${p.y + p.vy * this.progress}%`,
            })
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .hitTestBehavior(HitTestMode.Transparent)
    }
  }
}
