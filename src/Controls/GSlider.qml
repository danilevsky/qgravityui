import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Slider (BaseSlider.css).
//   size: GSize.S | M (default) | L | Xl
//   inputState: GInputState.Normal (default) | Error
// Handle 15/18/21/24 with border 3/4/5/6; rail and track 3/4/5/6 tall.
T.Slider {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int inputState: GInputState.Normal

    readonly property int _handle: {
        switch (size) {
        case GSize.S: return 15;
        case GSize.L: return 21;
        case GSize.Xl: return 24;
        default: return 18;
        }
    }
    readonly property int _handleBorder: {
        switch (size) {
        case GSize.S: return 3;
        case GSize.L: return 5;
        case GSize.Xl: return 6;
        default: return 4;
        }
    }
    readonly property int _bar: _handleBorder // rail/track heights match the border widths
    readonly property bool _error: inputState === GInputState.Error

    implicitWidth: 200
    implicitHeight: _handle
    hoverEnabled: true

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: control._bar
        radius: 4
        color: {
            const t = control.gcolors;
            if (!control.enabled) return t.baseGenericAccentDisabled;
            return control._error ? t.baseDangerHeavy : t.baseSelection;
        }

        // .g-base-slider__track is hidden entirely in the disabled and error states
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: control.gcolors.baseBrand
            visible: control.enabled && !control._error
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: control._handle
        implicitHeight: control._handle
        radius: width / 2
        color: control.gcolors.baseBackground
        border.width: control._handleBorder
        border.color: {
            const t = control.gcolors;
            if (!control.enabled) return t.baseGenericAccent;
            return control._error ? t.baseDangerHeavy : t.baseBrand;
        }

        // :focus and :active grow a 3px / 4px ring around the handle
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 2 * _ring
            height: parent.height + 2 * _ring
            radius: width / 2
            z: -1
            readonly property int _ring: control.pressed ? 4 : (control.visualFocus ? 3 : 0)
            visible: _ring > 0 && control.enabled
            color: control._error ? control.gcolors.baseDangerLightHover
                                  : control.gcolors.baseSelectionHover
        }
    }
}
