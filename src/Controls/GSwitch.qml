import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Switch.
//   size: GSize.S | M (default) | L
// Track/slider geometry is straight from Switch.css:
//   s 28x16 slider 12 @2, m 36x20 slider 16 @2, l 42x24 slider 18 @3.
T.Switch {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M

    // Templates leave focusPolicy at NoFocus and let the style decide; without
    // this the control never enters the tab chain and the ring never shows.
    focusPolicy: Qt.StrongFocus

    readonly property int _trackW: size === GSize.S ? 28 : (size === GSize.L ? 42 : 36)
    readonly property int _trackH: size === GSize.S ? 16 : (size === GSize.L ? 24 : 20)
    readonly property int _sliderD: size === GSize.S ? 12 : (size === GSize.L ? 18 : 16)
    readonly property int _inset: size === GSize.L ? 3 : 2
    readonly property int _trackRadius: size === GSize.L ? 12 : 10

    spacing: Metrics.spacing(2)
    hoverEnabled: true

    implicitHeight: Math.max(_trackH, contentItem.implicitHeight)
    implicitWidth: _trackW + (text ? spacing + contentItem.implicitWidth : 0)

    indicator: Rectangle {
        implicitWidth: control._trackW
        implicitHeight: control._trackH
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: control._trackRadius

        color: {
            const t = control.gcolors;
            if (!control.enabled) {
                // .g-switch_disabled.g-switch_checked drops the brand fill to 50%
                return control.checked ? Qt.rgba(t.baseBrand.r, t.baseBrand.g, t.baseBrand.b, 0.5)
                                       : t.baseGenericAccentDisabled;
            }
            if (control.checked) return t.baseBrand; // no hover variant upstream
            return control.hovered ? t.baseGenericMediumHover : t.baseGenericMedium;
        }
        Behavior on color { ColorAnimation { duration: 100 } }

        Rectangle {
            width: control._sliderD
            height: control._sliderD
            radius: width / 2
            color: control.gcolors.baseBackground
            y: control._inset
            // .g-switch_checked .g-switch__slider { transform: translateX(100%) }
            x: control._inset + (control.checked ? control._sliderD : 0)
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }
    }

    GFocusRing {
        boxRadius: height / 2
    }

    contentItem: GControlLabel {
        text: control.text
        size: control.size
        controlEnabled: control.enabled
        leftPadding: control.indicator.width + control.spacing
    }
}
