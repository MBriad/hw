/**
 * Humble View: Particle burst effect overlay for easter egg triggers.
 * Spawns colored particles that fade and disappear over ~1.5s.
 * Non-blocking — user can still interact with the page.
 */
import { DesignTokens } from '../../domain/SkinTheme';

interface Particle {
  x: number;
  y: number;
  size: number;
  color: string;
  vx: number;
  vy: number;
  opacity: number;
}

@Component
export struct ParticleOverlay {
  @Consume tokens: DesignTokens;
  @Prop effectType: string = 'particle_sparkle';
  @State private particles: Particle[] = [];
  @State private visible: boolean = false;

  show(): void {
    this.visible = true;
    this.generateParticles();
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
      const speed = 2 + Math.random() * 4;
      p.push({
        x: 50,
        y: 50,
        size: 4 + Math.random() * 8,
        color: colors[i % colors.length],
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed - 2,
        opacity: 1.0,
      });
    }
    this.particles = p;
  }

  private getColorsForEffect(): string[] {
    switch (this.effectType) {
      case 'eva_at_field':
        return ['#FF6B35', '#7B2D8E', '#FFA500', '#FF4500'];
      case 'particle_dark':
        return ['#6366F1', '#818CF8', '#312E81', '#A5B4FC'];
      case 'particle_sakura':
        return ['#FF69B4', '#FFB7C5', '#FF1493', '#FFF0F5'];
      case 'particle_bubble':
        return ['#67E8F9', '#22D3EE', '#A5F3FC', '#0891B2'];
      case 'particle_rise':
        return ['#34D399', '#FBBF24', '#60A5FA', '#A78BFA'];
      default:
        return ['#F59E0B', '#FCD34D', '#FBBF24', '#FDE68A'];
    }
  }

  build() {
    if (this.visible) {
      Stack() {
        ForEach(this.particles, (p: Particle, index: number) => {
          Circle()
            .width(p.size)
            .height(p.size)
            .fill(p.color)
            .opacity(p.opacity)
            .position({ x: `${p.x}%`, y: `${p.y}%` })
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .hitTestBehavior(HitTestMode.Transparent)
    }
  }
}
