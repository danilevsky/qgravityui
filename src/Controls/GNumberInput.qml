import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit NumberInput: a TextInput plus a stacked
// increment/decrement block separated by a --g-color-line-generic rule
// (.g-number-input__arrows has only an inline-start border).
//   size: GSize.S | M (default) | L | Xl
//   view: GView.Normal (default) | Clear
//   inputState: GInputState.Normal (default) | Error
T.SpinBox {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int view: GView.Normal
    property int inputState: GInputState.Normal

    // NumberInput.css --_--textinput-end-padding
    readonly property int _endPadding: (size === GSize.L || size === GSize.Xl) ? 3 : 1
    readonly property int _arrowsWidth: Metrics.heightForSize(size) - 2 * _endPadding

    editable: true
    hoverEnabled: true
    implicitWidth: 220
    implicitHeight: Metrics.heightForSize(size)

    leftPadding: view === GView.Clear ? 0 : Metrics.inputPadding(size)
    rightPadding: _arrowsWidth + Metrics.spacing(1)
    topPadding: 0
    bottomPadding: 0

    font.family: Typography.fontFamily
    font.pixelSize: Metrics.fontSizeForSize(size)
    font.weight: Typography.body1.weight

    contentItem: TextInput {
        text: control.displayText
        font: control.font
        color: control.enabled ? control.gcolors.textPrimary : control.gcolors.textHint
        selectionColor: control.gcolors.baseSelection
        selectedTextColor: control.gcolors.textPrimary
        verticalAlignment: TextInput.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        selectByMouse: true
    }

    background: GInputBackground {
        size: control.size
        view: control.view
        inputState: control.inputState
        controlEnabled: control.enabled
        controlHovered: control.hovered
        controlFocused: control.activeFocus

        // .g-number-input__arrows: border-inline-start only
        Rectangle {
            width: 1
            color: parent.border.color
            visible: control.enabled && control.view !== GView.Clear
            anchors.right: parent.right
            anchors.rightMargin: control._arrowsWidth + control._endPadding
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: control._endPadding
        }
    }

    up.indicator: Rectangle {
        x: control.width - width - control._endPadding
        y: control._endPadding
        width: control._arrowsWidth
        height: (control.height - 2 * control._endPadding) / 2
        color: control.up.hovered && control.enabled ? control.gcolors.baseSimpleHover : "transparent"
        topRightRadius: Metrics.radiusForSize(control.size) - 1

        GIcon {
            anchors.centerIn: parent
            // NumericArrows renders ChevronUp/ChevronDown at a flat 12px.
            name: "chevron-up"
            size: 12
            color: control.enabled ? control.gcolors.textSecondary : control.gcolors.textHint
        }
    }

    down.indicator: Rectangle {
        x: control.width - width - control._endPadding
        y: control.height / 2
        width: control._arrowsWidth
        height: (control.height - 2 * control._endPadding) / 2
        color: control.down.hovered && control.enabled ? control.gcolors.baseSimpleHover : "transparent"
        bottomRightRadius: Metrics.radiusForSize(control.size) - 1

        GIcon {
            anchors.centerIn: parent
            name: "chevron-down"
            size: 12
            color: control.enabled ? control.gcolors.textSecondary : control.gcolors.textHint
        }
    }
}
