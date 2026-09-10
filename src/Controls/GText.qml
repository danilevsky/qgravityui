import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Text: pick a typography variant and a semantic
// color role instead of setting font/color by hand.
Text {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    // body-1 (default) | body-2 | body-3 | body-short | caption-1 | caption-2 |
    // header-1 | header-2 | subheader-1..3 | display-1..4 | code-1..3
    property int variant: GVariant.Body1

    // primary (default) | secondary | hint | brand | danger | positive |
    // warning | info | link
    property int colorRole: GTextColor.Primary

    readonly property TypeStyle _tok: Typography.token(variant)

    font.family: Typography.isMono(variant) ? Typography.monoFontFamily : Typography.fontFamily
    font.pixelSize: _tok.size
    font.weight: _tok.weight

    // Gravity ships a line-height with every step of the scale; without this
    // the vertical rhythm of stacked text does not match the web build.
    lineHeight: _tok.lineHeight
    lineHeightMode: Text.FixedHeight

    color: {
        switch (colorRole) {
        case GTextColor.Secondary: return control.gcolors.textSecondary;
        case GTextColor.Hint: return control.gcolors.textHint;
        case GTextColor.Brand: return control.gcolors.textBrand;
        case GTextColor.Danger: return control.gcolors.textDanger;
        case GTextColor.Positive: return control.gcolors.textPositive;
        case GTextColor.Warning: return control.gcolors.textWarning;
        case GTextColor.Info: return control.gcolors.textInfo;
        case GTextColor.Link: return control.gcolors.textLink;
        default: return control.gcolors.textPrimary;
        }
    }
}
