import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit TextInput.
//   size: GSize.S | M (default) | L | Xl
//   view: GView.Normal (default) | Clear
//   inputState: GInputState.Normal (default) | Error   (`state` is taken by Item)
//
// Upstream default is a transparent field with a 1px --g-color-line-generic
// border -- not a filled one; the fill only appears in the disabled state.
T.TextField {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int view: GView.Normal
    property int inputState: GInputState.Normal

    implicitHeight: Metrics.heightForSize(size)
    implicitWidth: 220
    leftPadding: view === GView.Clear ? 0 : Metrics.inputPadding(size)
    rightPadding: leftPadding
    verticalAlignment: TextInput.AlignVCenter
    hoverEnabled: true

    color: enabled ? control.gcolors.textPrimary : control.gcolors.textHint
    selectionColor: control.gcolors.baseSelection
    selectedTextColor: control.gcolors.textPrimary
    placeholderTextColor: control.gcolors.textHint

    font.family: Typography.fontFamily
    font.pixelSize: Metrics.fontSizeForSize(size)
    font.weight: Typography.body1.weight

    // T.TextField does not draw placeholderText by itself -- every QQC2 style
    // supplies this item.
    Text {
        x: control.leftPadding
        y: control.topPadding
        width: control.width - control.leftPadding - control.rightPadding
        height: control.height - control.topPadding - control.bottomPadding
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        verticalAlignment: control.verticalAlignment
        elide: Text.ElideRight
        renderType: control.renderType
        visible: !control.length && !control.preeditText
                 && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
    }

    background: GInputBackground {
        size: control.size
        view: control.view
        inputState: control.inputState
        controlEnabled: control.enabled
        controlHovered: control.hovered
        controlFocused: control.activeFocus
    }
}
