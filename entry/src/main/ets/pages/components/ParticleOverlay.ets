/**
 * Humble View: Particle burst effect overlay for easter egg triggers.
 * Spawns colored particles that fade and disappear over ~1.5s.
 * Non-blocking — user can still interact with the page.
 */
interface Particle {
  x: number;
  y: number;
  size: number;
  color: string;
  vx: number;
  vy: number;
}

@Component
export struct ParticleOverlay {
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
      p.push({
        x: 50,
        y: 48,
        size: 4 + Math.random() * 8,
        color: colors[i % colors.length],
        vx: Math.cos(angle) * distance,
        vy: Math.sin(angle) * distance - 10,
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
