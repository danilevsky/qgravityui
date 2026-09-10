pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit TreeSelect: Select's control box over a
// GTreeList instead of a flat menu.
//
//   items:    the nested [{id, title, subtitle, children, disabled}] that
//             GTreeList takes
//   value:    the selected ids
//   multiple: several at once; the control then shows "N selected"
//   hasClear: the xmark that empties the selection
//   popupHeight: the popup is scrollable, so it needs a height of its own;
//             240 is roughly upstream's eight rows
//
// Same box as GSelect on purpose -- upstream shares SelectControl between
// the two, so a Select and a TreeSelect side by side line up.
T.AbstractButton {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int view: GView.Normal
    property int inputState: GInputState.Normal
    property string placeholder: ""
    property var items: []
    property var value: []
    property var expanded: []
    property bool multiple: false
    property bool hasClear: false
    property int popupHeight: 240

    signal updated(var value)

    focusPolicy: Qt.StrongFocus
    hoverEnabled: true

    implicitHeight: Metrics.heightForSize(size)
    implicitWidth: 200

    leftPadding: Metrics.selectPadding(size) + 1
    rightPadding: Metrics.selectPadding(size) + 1

    onClicked: popup.opened ? popup.close() : popup.open()

    // What the closed control says. A single choice shows the item's title,
    // which means finding it in a tree that may be arbitrarily deep.
    readonly property string _label: {
        if (value === undefined || value.length === 0)
            return placeholder;
        if (multiple && value.length > 1)
            return qsTr("%1 selected").arg(value.length);
        return _titleOf(items, String(value[0]));
    }

    function _titleOf(list, id: string): string {
        for (const item of list) {
            if (String(item.id) === id)
                return item.title !== undefined ? String(item.title) : id;
            if (item.children !== undefined) {
                const found = control._titleOf(item.children, id);
                if (found !== "")
                    return found;
            }
        }
        return "";
    }

    function clear() {
        control.value = [];
        control.updated([]);
    }

    background: GInputBackground {
        size: control.size
        view: control.view
        inputState: control.inputState
        controlEnabled: control.enabled
        controlHovered: control.hovered
        controlFocused: popup.opened
    }

    contentItem: Item {
        Text {
            anchors.left: parent.left
            anchors.right: clearButton.visible ? clearButton.left : chevron.left
            anchors.rightMargin: Metrics.spacing(1)
            anchors.verticalCenter: parent.verticalCenter

            text: control._label
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: Metrics.fontSizeForSize(control.size)
            color: {
                const t = control.gcolors;
                if (!control.enabled)
                    return t.textHint;
                return control.value !== undefined && control.value.length > 0
                       ? t.textPrimary : t.textHint;
            }
        }

        GButton {
            id: clearButton

            visible: control.hasClear && control.value !== undefined && control.value.length > 0
            anchors.right: chevron.left
            anchors.rightMargin: Metrics.spacing(1)
            anchors.verticalCenter: parent.verticalCenter
            view: GView.Flat
            size: GSize.S
            icon.name: "xmark"
            onClicked: control.clear()
        }

        GIcon {
            id: chevron

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron-down"
            size: control.size === GSize.S ? 12 : 16
            color: control.enabled ? control.gcolors.textSecondary : control.gcolors.textHint
        }
    }

    GPopup {
        id: popup

        anchorItem: control
        width: control.width
        height: control.popupHeight
        padding: Metrics.spacing(1)

        contentItem: GTreeList {
            id: treeList

            items: control.items
            multiple: control.multiple
            size: control.size
            value: control.value
            expanded: control.expanded

            onUpdated: function (next) {
                control.value = next;
                control.updated(next);
                // A single choice closes the popup, the way Select does;
                // a multiple one stays open to take the next tick.
                if (!control.multiple)
                    popup.close();
            }

            onExpandToggled: control.expanded = treeList.expanded
        }
    }
}
