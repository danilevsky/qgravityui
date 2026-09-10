pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Tabs (the TabList part).
//   size:  GSize.M|L|Xl -> 36/40/44 tall, 24/28/32 apart, 2/2/3 underline
//   items: [{ id, title, counter, disabled }]
//
// The hairline under the row is .g-tab-list's inset box-shadow; the active
// tab paints over it with line-brand.
Item {
    id: tabs

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property var items: []
    property var value: undefined

    signal activated(int index, var item)

    implicitHeight: Metrics.tabsHeight(size)
    implicitWidth: row.implicitWidth

    // .g-tab-list box-shadow: inset 0 -1px 0 0 line-generic
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: tabs.gcolors.lineGeneric
    }

    Row {
        id: row

        height: parent.height
        spacing: Metrics.tabsGap(tabs.size)

        Repeater {
            model: tabs.items

            Item {
                id: tab

                required property int index
                required property var modelData

                readonly property bool active: tabs.value !== undefined
                                               && tabs.value === modelData.id
                readonly property bool disabled: modelData.disabled === true

                width: content.implicitWidth
                height: tabs.height

                Row {
                    id: content

                    anchors.centerIn: parent
                    spacing: Metrics.spacing(2)

                    GText {
                        anchors.verticalCenter: parent.verticalCenter
                        variant: Metrics.tabsVariant(tabs.size)
                        text: tab.modelData.title !== undefined ? tab.modelData.title : ""
                        color: {
                            const t = tabs.gcolors;
                            if (tab.disabled)
                                return t.textHint;
                            return (tab.active || hover.hovered) ? t.textPrimary : t.textSecondary;
                        }
                    }

                    GText {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: tab.modelData.counter !== undefined
                        variant: Metrics.tabsVariant(tabs.size)
                        text: tab.modelData.counter !== undefined ? tab.modelData.counter : ""
                        // .g-tab__counter is hint until the tab wakes up
                        color: (tab.active || hover.hovered) && !tab.disabled
                               ? tabs.gcolors.textSecondary
                               : tabs.gcolors.textHint
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Metrics.tabsBorderWidth(tabs.size)
                    visible: tab.active
                    color: tabs.gcolors.lineBrand
                }

                activeFocusOnTab: !tab.disabled

                GFocusRing {
                    offset: -2
                }

                HoverHandler {
                    id: hover
                    enabled: !tab.disabled
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    enabled: !tab.disabled
                    onTapped: {
                        tabs.value = tab.modelData.id;
                        tabs.activated(tab.index, tab.modelData);
                    }
                }
            }
        }
    }
}
