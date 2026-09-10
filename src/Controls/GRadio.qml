import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Radio. Same indicator scale as Checkbox
// (14 / 17 / 24) but round, with the disc inset by 5 / 6 / 8.
T.RadioButton {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M

    // Templates leave focusPolicy at NoFocus and let the style decide; without
    // this the control never enters the tab chain and the ring never shows.
    focusPolicy: Qt.StrongFocus

    readonly property int _box: Metrics.toggleIndicator(size)
    readonly property int _discInset: size === GSize.L ? 6 : (size === GSize.Xl ? 8 : 5)

    spacing: Metrics.spacing(2)
    hoverEnabled: true

    implicitHeight: Math.max(_box, contentItem.implicitHeight)
    implicitWidth: _box + (text ? spacing + contentItem.implicitWidth : 0)

    indicator: Rectangle {
        implicitWidth: control._box
        implicitHeight: control._box
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: width / 2

        color: {
            const t = control.gcolors;
            if (!control.enabled) return t.baseGenericAccentDisabled;
            if (!control.checked) return "transparent";
            return t.baseBrand;
        }
        border.width: (control.checked || !control.enabled) ? 0 : 1
        border.color: control.hovered ? control.gcolors.lineGenericAccentHover
                                      : control.gcolors.lineGenericAccent
        Behavior on color { ColorAnimation { duration: 100 } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: control._discInset
            radius: width / 2
            color: control.enabled ? control.gcolors.textBrandContrast : control.gcolors.textHint
            opacity: control.checked ? 1 : 0
            scale: control.checked ? 1 : 0.1
            Behavior on opacity { NumberAnimation { duration: 100 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        }
    }

    GFocusRing {
        // .g-radio__outline is a pill around the whole control
        boxRadius: height / 2
    }

    contentItem: GControlLabel {
        text: control.text
        size: control.size
        controlEnabled: control.enabled
        leftPadding: control.indicator.width + control.spacing
    }
}
