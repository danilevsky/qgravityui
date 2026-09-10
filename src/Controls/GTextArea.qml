import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit TextArea. Same chrome as TextInput; the size only
// drives padding, radius and font, since the height comes from `rows`.
//   size: GSize.S | M (default) | L | Xl
//   view: GView.Normal (default) | Clear
//   inputState: GInputState.Normal (default) | Error
T.TextArea {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int view: GView.Normal
    property int inputState: GInputState.Normal

    // Visible rows when empty; upstream calls this minRows.
    property int rows: 3

    readonly property int _lineHeight: size === GSize.Xl ? Typography.body2.lineHeight
                                                     : Typography.bodyShort.lineHeight

    implicitWidth: 260
    implicitHeight: rows * _lineHeight + topPadding + bottomPadding + 2

    leftPadding: view === GView.Clear ? 0 : Metrics.inputPadding(size)
    rightPadding: leftPadding
    topPadding: Metrics.inputVerticalPadding(size)
    bottomPadding: topPadding

    hoverEnabled: true
    wrapMode: TextEdit.Wrap

    color: enabled ? control.gcolors.textPrimary : control.gcolors.textHint
    selectionColor: control.gcolors.baseSelection
    selectedTextColor: control.gcolors.textPrimary
    placeholderTextColor: control.gcolors.textHint

    font.family: Typography.fontFamily
    font.pixelSize: Metrics.fontSizeForSize(size)
    font.weight: Typography.body1.weight

    Text {
        x: control.leftPadding
        y: control.topPadding
        width: control.width - control.leftPadding - control.rightPadding
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        wrapMode: control.wrapMode
        elide: Text.ElideRight
        renderType: control.renderType
        visible: !control.length && !control.preeditText
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
