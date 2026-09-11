pragma Singleton
import QtQuick
import QGravityUI.Core

// Global theme selection. The palettes themselves are generated -- see
// tools/gen-tokens/gen_tokens.py and Tokens/Theme<Name>.qml.
//
// This is the window-wide setting. A subtree can override it with the
// GThemeScope attached property from QGravityUI.Core; components resolve
// their palette through palette(GThemeScope.effectiveMode), which falls back
// here when nothing above them has an opinion.
QtObject {
    id: theme

    property int mode: GThemeMode.Dark

    readonly property bool dark: mode === GThemeMode.Dark || mode === GThemeMode.DarkHc
    readonly property bool highContrast: mode === GThemeMode.LightHc
                                         || mode === GThemeMode.DarkHc

    // Flips light/dark, keeping the high-contrast choice.
    function toggle() {
        if (highContrast)
            mode = dark ? GThemeMode.LightHc : GThemeMode.DarkHc;
        else
            mode = dark ? GThemeMode.Light : GThemeMode.Dark;
    }

    readonly property ColorTokens light: ThemeLight {}
    readonly property ColorTokens lightHc: ThemeLightHc {}
    readonly property ColorTokens darkTokens: ThemeDark {}
    readonly property ColorTokens darkHc: ThemeDarkHc {}

    readonly property ColorTokens colors: palette(mode)

    // Resolve a palette by mode, with -1 meaning "whatever the window is set
    // to". That is what GThemeScope.effectiveMode reports when no ancestor
    // has overridden the theme, and it is why components can ask for a
    // scoped palette without knowing whether a scope exists.
    function palette(requested: int): ColorTokens {
        switch (requested < 0 ? mode : requested) {
        case GThemeMode.Dark: return darkTokens;
        case GThemeMode.LightHc: return lightHc;
        case GThemeMode.DarkHc: return darkHc;
        default: return light;
        }
    }
}
