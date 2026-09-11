pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit List: a filterable, keyboard-navigable list of
// items, optionally reorderable by dragging a handle.
//
//   items:        [{text, disabled}] -- or plain strings
//   filterable:   shows the search field above the list
//   sortable:     shows a grip on each row and lets it be dragged
//   activeIndex:  the row under the keyboard cursor / pointer
//   selectedIndexes: the rows drawn with the selection fill
//   itemHeight:   28 upstream
//   itemDelegate: a Component to draw a row's content; it is handed
//                 `modelData`, `itemIndex` and `itemActive`. The default draws
//                 `text` elided.
//
// Dragging is uncontrolled: the row moves within the list straight away and
// `sortEnded(oldIndex, newIndex)` reports it, so a caller that only wants the
// visual reorder needs no handler, while one that persists the order can
// reassign `items` -- which resets the order kept here to match.
//
// Upstream virtualizes with react-window past a threshold. ListView does that
// unconditionally, which is why there is no `virtualized` flag here: rows
// outside the viewport are never built in the first place.
FocusScope {
    id: list

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property bool filterable: false
    property bool sortable: false
    property int sortHandleAlign: GAlign.Start
    property string filter: ""
    property string filterPlaceholder: qsTr("Search")
    property string emptyPlaceholder: qsTr("Nothing found")
    property int size: GSize.M
    property int itemHeight: 28
    property int activeIndex: -1
    property var selectedIndexes: []
    property Component itemDelegate: null
    property bool loading: false

    signal itemClicked(int index, var item)
    signal filterUpdated(string filter)
    signal sortEnded(int oldIndex, int newIndex)
    signal loadMoreRequested()

    implicitWidth: 200
    implicitHeight: (filterable ? filterField.height + 8 : 0)
                    + Math.max(itemHeight, view.contentHeight)

    // .g-list__item horizontal padding. Taken from the input's text inset so a
    // row lines up with the filter field's text instead of sitting flush
    // against the edge of the list.
    readonly property int _itemPadding: Metrics.inputPadding(size)
    // Grip (12px) plus the 4px that separates it from the row's content.
    readonly property int _gripLane: 16

    // The order the rows are shown in, as indexes into `items`. Rebuilt
    // whenever `items` is reassigned, so a caller reordering the array itself
    // overrides an order arrived at by dragging.
    property var _order: []
    // Row being dragged and the row it would land on, both as positions in
    // `_visible`.
    property int _dragFrom: -1
    property int _dragTo: -1
    // True while the pointer is over a grip: the ListView must not flick then,
    // or it would swallow the drag.
    property bool _overGrip: false

    onItemsChanged: list._resetOrder()
    Component.onCompleted: list._resetOrder()

    function _resetOrder() {
        const out = [];
        for (let i = 0; i < items.length; ++i)
            out.push(i);
        _order = out;
    }

    // Upstream matches case-insensitively on the item's own text; a caller
    // that needs something else filters `items` itself and leaves this off.
    readonly property var _visible: {
        const out = [];
        const needle = filter.toLowerCase();
        const order = _order;
        for (let k = 0; k < order.length; ++k) {
            const index = order[k];
            const text = list.itemText(items[index]);
            if (needle === "" || text.toLowerCase().indexOf(needle) !== -1)
                out.push(index);
        }
        return out;
    }

    function itemText(item): string {
        if (item === undefined || item === null)
            return "";
        if (typeof item === "string")
            return item;
        return item.text !== undefined ? String(item.text) : String(item);
    }

    function itemEnabled(item): bool {
        return !(item !== null && typeof item === "object" && item.disabled === true);
    }

    function isSelected(index: int): bool {
        return selectedIndexes !== undefined && selectedIndexes.indexOf(index) !== -1;
    }

    // Walks over the filtered rows, skipping disabled ones, the way the
    // arrow keys do upstream.
    function _step(direction: int) {
        const order = _visible;
        if (order.length === 0)
            return;
        let at = order.indexOf(activeIndex);
        for (let n = 0; n < order.length; ++n) {
            at = at === -1 ? (direction > 0 ? 0 : order.length - 1)
                           : (at + direction + order.length) % order.length;
            if (itemEnabled(items[order[at]])) {
                activeIndex = order[at];
                view.positionViewAtIndex(at, ListView.Contain);
                return;
            }
        }
    }

    function activate() {
        if (activeIndex >= 0 && itemEnabled(items[activeIndex]))
            list.itemClicked(activeIndex, items[activeIndex]);
    }

    // How far a row steps aside to open the gap the dragged one will fill.
    function _rowShift(position: int): real {
        if (_dragFrom < 0 || _dragTo === _dragFrom || position === _dragFrom)
            return 0;
        if (_dragFrom < _dragTo && position > _dragFrom && position <= _dragTo)
            return -itemHeight;
        if (_dragFrom > _dragTo && position >= _dragTo && position < _dragFrom)
            return itemHeight;
        return 0;
    }

    // Applies a finished drag to `_order` and reports it in `items` indexes,
    // which is what a caller stores.
    function _commitDrag() {
        const from = _dragFrom;
        const to = _dragTo;
        const shown = _visible;
        _dragFrom = -1;
        _dragTo = -1;
        if (from < 0 || to < 0 || from === to || to >= shown.length)
            return;

        const moved = shown[from];
        const target = shown[to];
        const next = _order.slice();
        next.splice(next.indexOf(moved), 1);
        next.splice(next.indexOf(target) + (to > from ? 1 : 0), 0, moved);
        _order = next;

        list.sortEnded(moved, target);
    }

    Keys.onUpPressed: list._step(-1)
    Keys.onDownPressed: list._step(1)
    Keys.onReturnPressed: list.activate()
    Keys.onEnterPressed: list.activate()

    GTextField {
        id: filterField

        visible: list.filterable
        width: parent.width
        size: list.size
        placeholderText: list.filterPlaceholder
        text: list.filter
        onTextEdited: {
            list.filter = text;
            list.filterUpdated(text);
        }
    }

    ListView {
        id: view

        y: list.filterable ? filterField.height + 8 : 0
        width: parent.width
        height: parent.height - y
        clip: true
        model: list._visible
        boundsBehavior: Flickable.StopAtBounds
        // A grip under the pointer owns the vertical gesture, not the flick.
        interactive: !list._overGrip && list._dragFrom === -1
        // onLoadMore upstream: fired once the tail comes into view.
        onAtYEndChanged: {
            if (atYEnd && !list.loading && count > 0)
                list.loadMoreRequested();
        }

        delegate: Item {
            id: row

            required property int index
            required property int modelData

            readonly property var item: list.items[row.modelData]
            readonly property bool active: list.activeIndex === row.modelData
            readonly property bool rowEnabled: list.itemEnabled(row.item)
            readonly property bool dragged: list._dragFrom === row.index

            width: ListView.view.width
            height: list.itemHeight
            // The dragged row passes over the ones making room for it.
            z: dragged ? 2 : 1

            // ListView owns `y`, so the drag and the rows stepping aside are
            // both drawn as a transform on top of the position it assigns.
            transform: Translate {
                y: row.dragged ? dragHandler.activeTranslation.y
                               : list._rowShift(row.index)

                Behavior on y {
                    enabled: !row.dragged
                    NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: {
                    if (row.dragged)
                        return list.gcolors.baseFloat;
                    const selected = list.isSelected(row.modelData);
                    if (selected && row.active)
                        return list.gcolors.baseSelectionHover;
                    if (selected)
                        return list.gcolors.baseSelection;
                    if (row.active)
                        return list.gcolors.baseSimpleHover;
                    return "transparent";
                }
                border.width: row.dragged ? 1 : 0
                border.color: list.gcolors.lineGeneric
            }

            HoverHandler {
                // While a row is in flight the pointer travels over the others;
                // they must not take the keyboard cursor from it.
                enabled: row.rowEnabled && list._dragFrom === -1
                onHoveredChanged: {
                    if (hovered)
                        list.activeIndex = row.modelData;
                }
            }

            TapHandler {
                enabled: row.rowEnabled
                onTapped: {
                    list.activeIndex = row.modelData;
                    list.itemClicked(row.modelData, row.item);
                }
            }

            // .g-list__item-sort-icon: 12px wide, 4px from the content, and on
            // the far side when sortHandleAlign is `right`. The icon is that
            // small, so the grab area is the whole lane and the row's height
            // rather than the glyph.
            Item {
                id: grip

                visible: list.sortable
                width: list._gripLane
                height: parent.height
                x: list.sortHandleAlign === GAlign.End
                   ? parent.width - width - list._itemPadding + 2
                   : list._itemPadding - 2

                GIcon {
                    anchors.centerIn: parent
                    name: "grip"
                    size: 12
                    color: row.dragged ? list.gcolors.textPrimary : list.gcolors.textHint
                }

                HoverHandler {
                    enabled: list.sortable
                    cursorShape: row.dragged ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    onHoveredChanged: {
                        if (hovered)
                            list._overGrip = true;
                        else if (!dragHandler.active)
                            list._overGrip = false;
                    }
                }

                // A row lands wherever it was dragged past the midpoint of,
                // which is what makes this feel like the web version.
                DragHandler {
                    id: dragHandler

                    enabled: list.sortable
                    target: null
                    xAxis.enabled: false

                    onActiveChanged: {
                        if (active) {
                            list._dragFrom = row.index;
                            list._dragTo = row.index;
                        } else if (list._dragFrom === row.index) {
                            list._commitDrag();
                            list._overGrip = false;
                        }
                    }
                    onActiveTranslationChanged: {
                        if (!active)
                            return;
                        const steps = Math.round(activeTranslation.y / list.itemHeight);
                        const last = view.count - 1;
                        list._dragTo = Math.max(0, Math.min(last, row.index + steps));
                    }
                }
            }

            Item {
                id: content

                anchors.verticalCenter: parent.verticalCenter
                x: list._itemPadding
                   + (list.sortable && list.sortHandleAlign !== GAlign.End ? list._gripLane : 0)
                width: parent.width - x - list._itemPadding
                       - (list.sortable && list.sortHandleAlign === GAlign.End
                          ? list._gripLane : 0)
                height: parent.height
                clip: true
                opacity: row.rowEnabled ? 1 : 0.6

                Loader {
                    anchors.fill: parent
                    sourceComponent: list.itemDelegate !== null ? list.itemDelegate : defaultRow

                    // The delegate is a Component the caller supplies, so the
                    // row's data is handed over as properties rather than
                    // through a scope it cannot see.
                    property var modelData: row.item
                    property int itemIndex: row.modelData
                    // Not `active`: Loader already has one.
                    property bool itemActive: row.active
                }

                Component {
                    id: defaultRow

                    GText {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        elide: Text.ElideRight
                        text: list.itemText(row.item)
                    }
                }
            }
        }
    }

    // .g-list__empty-placeholder
    GText {
        visible: list._visible.length === 0
        x: list._itemPadding
        y: view.y + 8
        width: parent.width - 2 * list._itemPadding
        height: 36
        verticalAlignment: Text.AlignVCenter
        colorRole: GTextColor.Hint
        text: list.emptyPlaceholder
    }

    GLoader {
        visible: list.loading
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - height
    }
}
