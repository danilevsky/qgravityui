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

    // Upstream matches case-insensitively on the item's own text; a caller
    // that needs something else filters `items` itself and leaves this off.
    readonly property var _visible: {
        const out = [];
        const needle = filter.toLowerCase();
        for (let i = 0; i < items.length; ++i) {
            const item = items[i];
            const text = list.itemText(item);
            if (needle === "" || text.toLowerCase().indexOf(needle) !== -1)
                out.push(i);
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

            width: ListView.view.width
            height: list.itemHeight

            Rectangle {
                anchors.fill: parent
                color: {
                    const selected = list.isSelected(row.modelData);
                    if (selected && row.active)
                        return list.gcolors.baseSelectionHover;
                    if (selected)
                        return list.gcolors.baseSelection;
                    if (row.active)
                        return list.gcolors.baseSimpleHover;
                    return "transparent";
                }
            }

            HoverHandler {
                enabled: row.rowEnabled
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

            // .g-list__item-sort-icon: 12px wide, 4px from the content, and
            // on the far side when sortHandleAlign is `right`.
            GIcon {
                id: grip

                visible: list.sortable
                name: "grip"
                size: 12
                color: list.gcolors.textHint
                anchors.verticalCenter: parent.verticalCenter
                x: list.sortHandleAlign === GAlign.End ? parent.width - width - 10 : 0
                opacity: dragHandler.active ? 1 : 0.8

                DragHandler {
                    id: dragHandler

                    enabled: list.sortable
                    target: null
                    // A reorder is a swap as soon as the pointer passes the
                    // midpoint of the neighbouring row, which is what makes
                    // it feel like the web version without a drag ghost.
                    onCentroidChanged: {
                        if (!active)
                            return;
                        const y = row.y + centroid.position.y;
                        const to = Math.floor(y / list.itemHeight);
                        const order = list._visible;
                        const from = order.indexOf(row.modelData);
                        if (to === from || to < 0 || to >= order.length)
                            return;
                        list.sortEnded(row.modelData, order[to]);
                    }
                }
            }

            Item {
                id: content

                anchors.verticalCenter: parent.verticalCenter
                x: list.sortable && list.sortHandleAlign !== GAlign.End ? grip.width + 4 : 0
                width: parent.width - x - (list.sortable && list.sortHandleAlign === GAlign.End
                                           ? grip.width + 10 : 0)
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
        x: 0
        y: view.y + 8
        width: parent.width
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
