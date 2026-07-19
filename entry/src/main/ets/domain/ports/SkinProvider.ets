/**
 * Port: Skin theme configuration provider.
 * Pure interface — zero framework dependencies.
 */
import { SkinTheme, SkinConfig } from '../SkinTheme';

export interface SkinProvider {
  /** Get full color config for a specific skin */
  getSkin(id: SkinTheme): SkinConfig;

  /** List all available skins */
  listSkins(): SkinConfig[];
}
