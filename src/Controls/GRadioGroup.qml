pragma ComponentBehavior: Bound
import QtQuick
import QGravityUI.Core

// Port of @gravity-ui/uikit RadioGroup.
//   direction: GDirection.Vertical (default) | Horizontal
//   size: GSize.M (default) | L | Xl
//   options: [{ value, content, disabled }]
//
// The group owns `value`; the radios are driven from it rather than toggling
// themselves, so a programmatic change to `value` always wins.
Grid {
    id: group

    property int direction: GDirection.Vertical
    property int size: GSize.M
    property var options: []
    property var value

    signal activated(var value)

    readonly property bool _horizontal: direction === GDirection.Horizontal

    columns: _horizontal ? Math.max(1, options.length) : 1

    // RadioGroup.css option margins
    columnSpacing: size === GSize.M ? 12 : 15
    rowSpacing: size === GSize.L ? 12 : (size === GSize.Xl ? 18 : 8)

    Repeater {
        model: group.options

        GRadio {
            required property var modelData

            size: group.size
            text: modelData.content !== undefined ? modelData.content : modelData.value
            enabled: group.enabled && modelData.disabled !== true

            // The group is the single source of truth for the selection.
            checkable: false
            checked: group.value === modelData.value
            onClicked: {
                group.value = modelData.value;
                group.activated(modelData.value);
            }
        }
    }
}
