import QtQuick
import QGravityUI.Core
import QtQuick.Effects
import QGravityUI.Tokens

// Shared chrome for everything that floats: a rounded, optionally outlined
// rectangle with a drop shadow.
//
// Gravity states these as CSS box-shadows -- Popup carries
// `0 0 0 1px line-generic-solid, 0 8px 20px 1px sfx-shadow`, i.e. the border
// itself is a shadow. Here the hairline is a real border and only the blur
// goes through MultiEffect.
//
// CSS blur radius and MultiEffect's blur are different measures (Gaussian
// sigma vs. a fixed multi-pass kernel), so `shadowBlurPx` is close rather than
// exact; it maps to blurMax so the kernel is sized to the shadow we asked for.
Item {
    id: surface

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property color color: surface.gcolors.baseFloat
    property int radius: Metrics.popupRadius
    property int borderWidth: 0
    property color borderColor: surface.gcolors.lineGenericSolid

    property bool shadowEnabled: true
    property int shadowBlurPx: 20
    property int shadowOffsetY: 8
    property color shadowColor: surface.gcolors.sfxShadow

    Rectangle {
        id: plate
        anchors.fill: parent
        radius: surface.radius
        color: surface.color
        border.width: surface.borderWidth
        border.color: surface.borderColor
        // Drawn by the effect below; kept out of the scene itself so the
        // shadow is not composited over its own source.
        visible: !surface.shadowEnabled
    }

    MultiEffect {
        anchors.fill: plate
        source: plate
        visible: surface.shadowEnabled
        shadowEnabled: true
        shadowColor: surface.shadowColor
        shadowBlur: 1.0
        blurMax: surface.shadowBlurPx
        shadowVerticalOffset: surface.shadowOffsetY
        shadowHorizontalOffset: 0
    }
}
