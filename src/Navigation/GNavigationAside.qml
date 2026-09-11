pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens
import QGravityUI.Controls

// Port of @gravity-ui/navigation AsideHeader: a collapsible SPA sidebar.
//
//   items:       [{id, title, iconName, items?: [{id, title, iconName}]}]
//                one level of nesting -- shown inline under the parent when
//                expanded, as a flyout menu off the parent when compact.
//   current:     id of the active leaf item. Highlights it and, on first
//                render, opens whichever top-level item owns it.
//   compact:     true collapses the aside to icon-only. The control flips
//                this itself on the toggle button, the same controlled-but-
//                self-mutating contract GAccordionItem.expanded and
//                GTabs.value already use, and emits compactToggled too for
//                callers that mirror the state elsewhere (upstream's
//                onChangeCompact).
//   footerItems: [{id, iconName, tooltip}] -- icon-only actions pinned to
//                the bottom (theme switch, help, settings...).
//   logo:        {text, iconName}
Item {
    id: aside

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property var footerItems: []
    property var logo: ({text: "", iconName: ""})
    property var current: null
    property bool compact: false

    signal activated(var id, var item)
    signal compactToggled(bool compact)
    signal logoClicked()

    readonly property int _rowInline: Metrics.spacing(3)

    implicitWidth: Metrics.asideWidth(compact)
    implicitHeight: 480

    // Plain Item, unlike Control/Pane, never sizes itself from
    // implicitWidth/implicitHeight on its own -- without this the aside
    // renders at 0x0 unless something else (Layout.fillHeight in the demo)
    // happens to assign a real size on top of it.
    width: implicitWidth
    height: implicitHeight

    Behavior on implicitWidth {
        NumberAnimation { duration: Metrics.drawerDuration; easing.type: Easing.OutQuad }
    }

    // Which top-level item owns `current`, so its sublist starts open
    // instead of hiding the active page behind a collapsed parent. A plain
    // property, not a binding kept alive: once the user opens/closes a
    // sublist by hand that choice should stick, exactly like
    // GAccordionItem.expanded does.
    function _ownerIndex(): int {
        for (let i = 0; i < items.length; ++i) {
            const kids = items[i].items;
            if (kids === undefined)
                continue;
            for (let j = 0; j < kids.length; ++j) {
                if (kids[j].id === aside.current)
                    return i;
            }
        }
        return -1;
    }

    property int _expandedIndex: _ownerIndex()

    Rectangle {
        anchors.fill: parent
        color: aside.gcolors.baseBackground
        border.width: 1
        border.color: aside.gcolors.lineGeneric
    }

    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 44

        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: aside._rowInline
            spacing: Metrics.spacing(2)
            visible: !aside.compact && (aside.logo.text || aside.logo.iconName)

            GIcon {
                visible: !!aside.logo.iconName
                name: aside.logo.iconName || ""
                size: 20
                color: aside.gcolors.textPrimary
            }

            GText {
                text: aside.logo.text || ""
                variant: GVariant.Subheader1
            }
        }

        TapHandler {
            enabled: !!(aside.logo.text || aside.logo.iconName)
            onTapped: aside.logoClicked()
        }

        GButton {
            id: toggleButton
            anchors.verticalCenter: parent.verticalCenter
            x: aside.compact ? (parent.width - width) / 2
                             : parent.width - width - aside._rowInline
            view: GView.Flat
            icon.name: aside.compact ? "chevron-right" : "chevron-left"

            onClicked: {
                aside.compact = !aside.compact;
                aside.compactToggled(aside.compact);
            }

            GTooltip {
                text: aside.compact ? "Expand" : "Collapse"
                active: aside.compact
                placement: GPlacement.Right
            }
        }
    }

    Rectangle {
        id: headerDivider
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: aside.gcolors.lineGeneric
    }

    Flickable {
        id: itemsFlick
        anchors.top: headerDivider.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerDivider.top
        anchors.topMargin: Metrics.spacing(2)
        anchors.bottomMargin: Metrics.spacing(2)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width
        contentHeight: itemsColumn.height

        Column {
            id: itemsColumn
            width: itemsFlick.width
            spacing: Metrics.spacing(1)

            Repeater {
                model: aside.items

                delegate: Column {
                    id: row

                    required property int index
                    required property var modelData

                    readonly property bool hasKids: row.modelData.items !== undefined
                                                     && row.modelData.items.length > 0
                    readonly property bool isLeafActive: !row.hasKids
                                                          && row.modelData.id === aside.current

                    width: itemsColumn.width
                    spacing: Metrics.spacing(1)

                    GNavigationItem {
                        id: navRow
                        width: row.width
                        compact: aside.compact
                        iconName: row.modelData.iconName !== undefined ? row.modelData.iconName : ""
                        text: row.modelData.title !== undefined ? row.modelData.title : ""
                        hasChildren: row.hasKids
                        active: row.isLeafActive
                        expanded: aside._expandedIndex === row.index

                        onClicked: {
                            if (!row.hasKids) {
                                aside.current = row.modelData.id;
                                aside.activated(row.modelData.id, row.modelData);
                                return;
                            }
                            if (aside.compact) {
                                flyout.options = row.modelData.items.map(k => ({
                                    content: k.title,
                                    id: k.id,
                                    iconName: k.iconName,
                                    active: k.id === aside.current,
                                }));
                                flyout.anchorItem = navRow;
                                if (flyout.opened)
                                    flyout.close();
                                else
                                    flyout.open();
                                return;
                            }
                            aside._expandedIndex = aside._expandedIndex === row.index ? -1 : row.index;
                        }
                    }

                    // Inline sublist -- only when expanded and not compact;
                    // compact uses the shared `flyout` menu below instead.
                    Column {
                        id: sublist
                        width: row.width
                        visible: row.hasKids && !aside.compact && aside._expandedIndex === row.index
                        height: visible ? implicitHeight : 0
                        spacing: Metrics.spacing(1)

                        Repeater {
                            model: sublist.visible ? row.modelData.items : []

                            delegate: GNavigationItem {
                                required property var modelData

                                x: 16
                                width: row.width - 16
                                compact: false
                                iconName: modelData.iconName !== undefined ? modelData.iconName : ""
                                text: modelData.title !== undefined ? modelData.title : ""
                                active: modelData.id === aside.current

                                onClicked: {
                                    aside.current = modelData.id;
                                    aside.activated(modelData.id, modelData);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Shared flyout for a compact-mode item's subitems -- one GMenu instance
    // reused across rows the way one popup is enough since only one can be
    // open at a time, rather than a menu per row that never opens.
    GMenu {
        id: flyout
        placement: GPlacement.Right

        onTriggered: function (index, option) {
            aside.current = option.id;
            aside.activated(option.id, option);
        }
    }

    Rectangle {
        id: footerDivider
        anchors.bottom: footerRow.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: Metrics.spacing(1)
        height: 1
        visible: aside.footerItems.length > 0
        color: aside.gcolors.lineGeneric
    }

    // A compact 56px aside cannot fit two icon buttons side by side (2 * 28px
    // button + gap > 56); Flow wraps them onto their own line instead of
    // clipping, the same escape hatch GFlex already leans on for exactly
    // this "runs out of horizontal room" case.
    Flow {
        id: footerRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: Metrics.spacing(2)
        anchors.leftMargin: aside._rowInline
        anchors.rightMargin: aside._rowInline
        spacing: Metrics.spacing(1)

        Repeater {
            model: aside.footerItems

            delegate: GButton {
                id: footerButton
                required property var modelData

                view: GView.Flat
                icon.name: footerButton.modelData.iconName !== undefined ? footerButton.modelData.iconName : ""

                onClicked: aside.activated(footerButton.modelData.id, footerButton.modelData)

                GTooltip {
                    text: footerButton.modelData.tooltip !== undefined ? footerButton.modelData.tooltip : ""
                    placement: GPlacement.Right
                }
            }
        }
    }
}
