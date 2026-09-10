pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit TableColumnSetup: the gear button over a table
// that opens the list of its columns -- tick the ones to show, drag them into
// order, apply.
//
//   items:    [{id, title, selected, required}]; a `required` column shows a
//             padlock instead of a checkbox and cannot be turned off
//   sortable: the grip on each row (default true)
//   showStatus: "3/7" beside the button label
//   hideApplyButton: every change is published immediately instead of being
//             held until Apply
//
// The popup edits a copy. Upstream does the same -- the table keeps rendering
// the old column set while the list is being rearranged, and only Apply
// hands the new one over.
Item {
    id: setup

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property bool sortable: true
    property bool showStatus: false
    property bool hideApplyButton: false
    property string switcherText: qsTr("Settings")
    property int popupWidth: 240

    signal updated(var items)

    implicitWidth: switcher.implicitWidth
    implicitHeight: switcher.implicitHeight

    readonly property int _rowHeight: 32

    // The working copy. Rebuilt from `items` every time the popup opens, so
    // a cancelled edit leaves nothing behind.
    property var _draft: []

    readonly property string _status: {
        let selected = 0;
        for (const item of items) {
            if (item.selected === true)
                selected += 1;
        }
        return selected + "/" + items.length;
    }

    function _copyItems(): var {
        const out = [];
        for (const item of setup.items)
            out.push({id: item.id, title: item.title,
                      selected: item.selected === true, required: item.required === true});
        return out;
    }

    function _publish() {
        setup.updated(setup._draft);
    }

    GButton {
        id: switcher

        anchors.fill: parent
        icon.name: "gear"
        text: setup.switcherText + (setup.showStatus ? "  " + setup._status : "")

        onClicked: {
            if (popup.opened) {
                popup.close();
                return;
            }
            setup._draft = setup._copyItems();
            popup.open();
        }
    }

    GPopup {
        id: popup

        anchorItem: setup
        width: setup.popupWidth
        height: body.implicitHeight

        contentItem: Column {
            id: body

            spacing: 0

            Repeater {
                model: setup._draft

                Item {
                    id: rowItem

                    required property int index
                    required property var modelData

                    width: popup.width
                    height: setup._rowHeight

                    Rectangle {
                        anchors.fill: parent
                        color: rowHover.hovered ? setup.gcolors.baseSimpleHover : "transparent"
                    }

                    HoverHandler { id: rowHover }

                    // A required column is fixed on: upstream swaps its
                    // checkbox for a padlock rather than disabling it.
                    GIcon {
                        id: lock

                        visible: rowItem.modelData.required === true
                        name: "lock"
                        size: 16
                        color: setup.gcolors.textSecondary
                        x: Metrics.spacing(2)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    GCheckbox {
                        id: tick

                        visible: rowItem.modelData.required !== true
                        x: Metrics.spacing(2)
                        anchors.verticalCenter: parent.verticalCenter
                        size: GSize.M
                        checked: rowItem.modelData.selected === true

                        onToggled: {
                            const draft = setup._draft.slice();
                            draft[rowItem.index] = Object.assign({}, draft[rowItem.index],
                                                                 {selected: checked});
                            setup._draft = draft;
                            if (setup.hideApplyButton)
                                setup._publish();
                        }
                    }

                    GText {
                        x: Metrics.spacing(2) + 16 + Metrics.spacing(2)
                        width: parent.width - x - (setup.sortable ? 16 + Metrics.spacing(2) : 0)
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        text: rowItem.modelData.title !== undefined
                              ? rowItem.modelData.title : rowItem.modelData.id
                    }

                    GIcon {
                        id: grip

                        visible: setup.sortable
                        name: "grip"
                        size: 16
                        color: setup.gcolors.textHint
                        x: parent.width - width - Metrics.spacing(2)
                        anchors.verticalCenter: parent.verticalCenter

                        DragHandler {
                            id: drag

                            enabled: setup.sortable
                            target: null

                            // The row is moved as soon as the pointer crosses
                            // into a neighbour's half, so the list reorders
                            // under the finger with no drag ghost to draw.
                            onCentroidChanged: {
                                if (!active)
                                    return;
                                const y = rowItem.y + centroid.position.y;
                                const to = Math.max(0, Math.min(setup._draft.length - 1,
                                                                Math.floor(y / setup._rowHeight)));
                                if (to === rowItem.index)
                                    return;
                                const draft = setup._draft.slice();
                                const moved = draft.splice(rowItem.index, 1)[0];
                                draft.splice(to, 0, moved);
                                setup._draft = draft;
                                if (setup.hideApplyButton)
                                    setup._publish();
                            }
                        }
                    }
                }
            }

            // .g-inner-table-column-setup__controls
            Item {
                visible: !setup.hideApplyButton
                width: popup.width
                height: applyRow.height + 2 * Metrics.spacing(1)

                Row {
                    id: applyRow

                    x: Metrics.spacing(1)
                    y: Metrics.spacing(1)
                    spacing: Metrics.spacing(1)

                    GButton {
                        text: qsTr("Apply")
                        view: GView.Action
                        onClicked: {
                            setup._publish();
                            popup.close();
                        }
                    }

                    GButton {
                        text: qsTr("Reset")
                        view: GView.Flat
                        onClicked: setup._draft = setup._copyItems()
                    }
                }
            }
        }
    }
}
