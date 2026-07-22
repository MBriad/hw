import { SkinTheme, DesignTokens, ThemeResult } from '../SkinTheme';

export interface ILoadPersistedTheme {
  execute(): Promise<ThemeResult>;
}

export interface ISwitchTheme {
  execute(theme: SkinTheme): Promise<DesignTokens>;
}
