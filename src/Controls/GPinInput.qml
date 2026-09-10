pragma ComponentBehavior: Bound
import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit PinInput: a row of single-character fields sharing
// the TextInput chrome.
//   size: GSize.S | M (default) | L | Xl
//   inputState: GInputState.Normal (default) | Error
//
// PinInput.css carries no geometry of its own (it is `display: inline-block`
// over a row of TextInputs), but the geometry is upstream's:
// --_--item-width 22/26/34/42 against the input heights, so the cells are
// narrower than they are tall, and --_--gap 6/8/10/12.
Row {
    id: group

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int length: 4
    property string value: ""
    property int size: GSize.M
    property int inputState: GInputState.Normal
    property bool mask: false

    // Emitted once every cell holds a character.
    signal completed(string value)

    readonly property int _cellHeight: Metrics.heightForSize(size)
    readonly property int _cellWidth: Metrics.pinInputCellWidth(size)

    spacing: Metrics.pinInputGap(size)

    function _setChar(i, ch) {
        const padded = (value + "                ").substring(0, group.length).split("");
        padded[i] = ch === "" ? " " : ch;
        value = padded.join("").replace(/ +$/, "");
        if (value.length === group.length && value.indexOf(" ") === -1)
            completed(value);
    }

    Repeater {
        model: group.length

        T.TextField {
            id: cell
            required property int index

            width: group._cellWidth
            height: group._cellHeight
            hoverEnabled: true
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            maximumLength: 1
            echoMode: group.mask ? TextInput.Password : TextInput.Normal
            enabled: group.enabled

            color: enabled ? group.gcolors.textPrimary : group.gcolors.textHint
            selectionColor: group.gcolors.baseSelection
            selectedTextColor: group.gcolors.textPrimary

            font.family: Typography.fontFamily
            font.pixelSize: Metrics.fontSizeForSize(group.size)
            font.weight: Typography.body1.weight

            text: index < group.value.length ? group.value.charAt(index).trim() : ""

            onTextEdited: {
                group._setChar(index, text);
                if (text.length === 1)
                    nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason);
            }
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Backspace && text.length === 0) {
                    nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason);
                    event.accepted = true;
                }
            }

            background: GInputBackground {
                size: group.size
                inputState: group.inputState
                controlEnabled: cell.enabled
                controlHovered: cell.hovered
                controlFocused: cell.activeFocus
            }
        }
    }
}
