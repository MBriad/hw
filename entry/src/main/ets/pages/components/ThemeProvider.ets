/**
 * ThemeProvider: @Provide DesignTokens to entire component tree.
 * Supports runtime theme switching + persistence via @ohos.data.preferences.
 * From .agent/architecture/ui-design-system/design-tokens-and-component-patterns.md
 */
import { preferences } from '@kit.ArkData';
import { DesignTokens, ThemePalette, SkinTheme } from '../../domain/SkinTheme';

const PREFS_NAME = 'app_settings';
const KEY_THEME = 'theme';

@Component
export struct ThemeProvider {
  @Provide @Watch('onThemeChange') tokens: DesignTokens = ThemePalette[SkinTheme.LIGHT];
  @Provide themeName: SkinTheme = SkinTheme.LIGHT;
  @BuilderParam child: () => void;

  aboutToAppear(): void {
    this.loadPersistedTheme();
  }

  onThemeChange(): void {
    // ArkUI auto-triggers subtree repaint when @Provide tokens changes.
  }

  switchTheme(name: SkinTheme): void {
    this.themeName = name;
    this.tokens = ThemePalette[name];
    this.persistTheme(name);
  }

  private loadPersistedTheme(): void {
    try {
      preferences.getPreferences(getContext(this), PREFS_NAME, (err, pref) => {
        if (!err) {
          pref.get(KEY_THEME, SkinTheme.LIGHT, (_e, value) => {
            const saved = value as string;
            if (saved === SkinTheme.LIGHT || saved === SkinTheme.DARK ||
                saved === SkinTheme.PINK || saved === SkinTheme.PASTEL) {
              this.themeName = saved;
              this.tokens = ThemePalette[saved];
            }
          });
        }
      });
    } catch (_e) {
      // Fallback to default LIGHT theme
    }
  }

  private persistTheme(name: SkinTheme): void {
    try {
      preferences.getPreferences(getContext(this), PREFS_NAME, (err, pref) => {
        if (!err) {
          pref.put(KEY_THEME, name, (e) => {
            if (!e) {
              pref.flush();
            }
          });
        }
      });
    } catch (_e) {
      // Silent fail — non-critical feature
    }
  }

  build() {
    Column() {
      this.child()
    }
    .backgroundColor(this.tokens.bgBase)
    .width('100%')
    .height('100%')
  }
}
