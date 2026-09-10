pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit TreeList: a nested list that can be expanded,
// walked with the keyboard and selected from.
//
//   items:    [{id, title, subtitle, children, disabled}], nested
//   multiple: several ids at once, each row carrying a tick
//   value:    the selected ids
//   expanded: the ids whose children are showing
//   size:     GSize.S|M (default)|L|Xl -- drives row height and radius
//
// Upstream keeps the flattened order, the expanded set and the selection in
// a `useList` hook shared with Select and TableColumnSetup. Here the flatten
// is a plain function over `items` and `expanded`: it is a handful of lines,
// and a QML property binding already gives the memoisation the hook was
// written for.
FocusScope {
    id: tree

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property bool multiple: false
    property int size: GSize.M
    property var value: []
    property var expanded: []
    property string activeId: ""

    signal itemClicked(string id, var item)
    signal updated(var value)
    signal expandToggled(string id, bool nowExpanded)

    implicitWidth: 240
    implicitHeight: view.contentHeight

    // .g-list-item-view__slot: one indentation step is 16px
    readonly property int _indent: 16

    // The visible rows, in order, each with the depth it is drawn at.
    readonly property var _rows: {
        const out = [];
        const walk = function (list, level) {
            for (const item of list) {
                const id = String(item.id);
                const children = item.children !== undefined ? item.children : [];
                const isExpanded = tree.expanded.indexOf(id) !== -1;
                out.push({id: id, item: item, level: level,
                          hasChildren: children.length > 0, expanded: isExpanded});
                if (children.length > 0 && isExpanded)
                    walk(children, level + 1);
            }
        };
        walk(items, 0);
        return out;
    }

    function isSelected(id: string): bool {
        return value !== undefined && value.indexOf(id) !== -1;
    }

    function toggleExpanded(id: string) {
        const next = expanded.slice();
        const at = next.indexOf(id);
        if (at === -1)
            next.push(id);
        else
            next.splice(at, 1);
        tree.expanded = next;
        tree.expandToggled(id, at === -1);
    }

    function select(id: string) {
        const current = value === undefined ? [] : value.slice();
        const at = current.indexOf(id);
        let next;
        if (multiple)
            next = at === -1 ? current.concat([id])
                             : current.slice(0, at).concat(current.slice(at + 1));
        else
            next = at === -1 ? [id] : [];
        tree.value = next;
        tree.updated(next);
    }

    function _rowAt(id: string): var {
        for (const row of _rows) {
            if (row.id === id)
                return row;
        }
        return undefined;
    }

    function _step(direction: int) {
        const rows = _rows;
        if (rows.length === 0)
            return;
        let at = -1;
        for (let i = 0; i < rows.length; ++i) {
            if (rows[i].id === activeId) {
                at = i;
                break;
            }
        }
        for (let n = 0; n < rows.length; ++n) {
            at = at === -1 ? (direction > 0 ? 0 : rows.length - 1)
                           : (at + direction + rows.length) % rows.length;
            if (rows[at].item.disabled !== true) {
                tree.activeId = rows[at].id;
                view.positionViewAtIndex(at, ListView.Contain);
                return;
            }
        }
    }

    function _activate() {
        const row = _rowAt(activeId);
        if (row === undefined || row.item.disabled === true)
            return;
        // A branch row opens instead of selecting, the way clicking it does.
        if (row.hasChildren)
            tree.toggleExpanded(row.id);
        else
            tree.select(row.id);
        tree.itemClicked(row.id, row.item);
    }

    Keys.onUpPressed: tree._step(-1)
    Keys.onDownPressed: tree._step(1)
    Keys.onReturnPressed: tree._activate()
    Keys.onEnterPressed: tree._activate()
    Keys.onRightPressed: {
        const row = tree._rowAt(tree.activeId);
        if (row !== undefined && row.hasChildren && !row.expanded)
            tree.toggleExpanded(row.id);
    }
    Keys.onLeftPressed: {
        const row = tree._rowAt(tree.activeId);
        if (row !== undefined && row.hasChildren && row.expanded)
            tree.toggleExpanded(row.id);
    }

    ListView {
        id: view

        anchors.fill: parent
        clip: true
        model: tree._rows
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: row

            required property int index
            required property var modelData

            readonly property var item: row.modelData.item
            readonly property bool hasSubtitle: row.item.subtitle !== undefined
                                                && row.item.subtitle !== ""
            readonly property bool rowEnabled: row.item.disabled !== true

            width: ListView.view.width
            height: Metrics.listItemHeight(tree.size, row.hasSubtitle)

            Rectangle {
                anchors.fill: parent
                radius: Metrics.listItemRadius(tree.size)
                color: {
                    if (tree.isSelected(row.modelData.id))
                        return tree.gcolors.baseSelection;
                    if (tree.activeId === row.modelData.id || rowHover.hovered)
                        return tree.gcolors.baseSimpleHover;
                    return "transparent";
                }
            }

            HoverHandler {
                id: rowHover

                enabled: row.rowEnabled
            }

            TapHandler {
                enabled: row.rowEnabled
                onTapped: {
                    tree.activeId = row.modelData.id;
                    if (row.modelData.hasChildren)
                        tree.toggleExpanded(row.modelData.id);
                    else
                        tree.select(row.modelData.id);
                    tree.itemClicked(row.modelData.id, row.item);
                }
            }

            Row {
                // spacing({px: 2}) on the row
                x: Metrics.spacing(2)
                width: parent.width - 2 * Metrics.spacing(2)
                height: parent.height
                spacing: 0

                // The tick slot exists on every row in multiple mode, so the
                // titles stay on one vertical line whether or not a row is
                // selected.
                Item {
                    id: tickSlot

                    visible: tree.multiple
                    width: visible ? 16 : 0
                    height: parent.height

                    GIcon {
                        anchors.centerIn: parent
                        visible: tree.isSelected(row.modelData.id)
                        name: "check"
                        size: 16
                        color: tree.gcolors.textInfo
                    }
                }

                Item {
                    id: indentSlot

                    // One 16px slot per level of nesting.
                    width: row.modelData.level * tree._indent
                    height: parent.height
                }

                GArrowToggle {
                    id: arrow

                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.modelData.hasChildren
                    width: visible ? 16 : 0
                    // behavior="action": down when closed, up when open.
                    direction: row.modelData.expanded ? GPlacement.Top : GPlacement.Bottom
                    color: row.rowEnabled ? tree.gcolors.textPrimary : tree.gcolors.textHint
                }

                Column {
                    // .g-list-item-view__main-content takes what the slots
                    // before it leave and is centred in the row.
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - tickSlot.width - indentSlot.width - arrow.width
                    spacing: 2

                    GText {
                        width: parent.width
                        elide: Text.ElideRight
                        variant: row.modelData.hasChildren ? GVariant.Subheader1 : GVariant.Body1
                        colorRole: row.rowEnabled ? GTextColor.Primary : GTextColor.Hint
                        text: row.item.title !== undefined ? row.item.title : row.modelData.id
                    }

                    GText {
                        width: parent.width
                        visible: row.hasSubtitle
                        elide: Text.ElideRight
                        colorRole: row.rowEnabled ? GTextColor.Secondary : GTextColor.Hint
                        text: row.hasSubtitle ? row.item.subtitle : ""
                    }
                }
            }
        }
    }
}
