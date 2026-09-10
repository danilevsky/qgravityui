pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Breadcrumbs.
//   items: [{ text, disabled }] -- the last one is the current page
//   separator: "/" upstream, overridable
//
// Not ported: the collapsing behaviour. Upstream measures the row and folds
// the middle into a menu when it overflows; that needs a measuring pass this
// component does not do.
Row {
    id: breadcrumbs

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property string separator: "/"

    signal itemClicked(int index, var item)

    Repeater {
        model: breadcrumbs.items

        Row {
            id: entry

            required property int index
            required property var modelData

            readonly property bool current: index === breadcrumbs.items.length - 1

            height: Metrics.breadcrumbHeight

            GText {
                anchors.verticalCenter: parent.verticalCenter
                text: entry.modelData.text !== undefined ? entry.modelData.text : ""
                // .g-breadcrumbs__item_current uses the accent weight
                font.weight: entry.current ? Font.DemiBold : Font.Normal
                color: {
                    const t = breadcrumbs.gcolors;
                    if (entry.modelData.disabled === true)
                        return t.textHint;
                    return hover.hovered && !entry.current ? t.textLinkHover : t.textPrimary;
                }

                activeFocusOnTab: !entry.current && entry.modelData.disabled !== true

                GFocusRing {
                    boxRadius: Metrics.focusBorderRadius
                }

                HoverHandler {
                    id: hover
                    enabled: !entry.current && entry.modelData.disabled !== true
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    enabled: hover.enabled
                    onTapped: breadcrumbs.itemClicked(entry.index, entry.modelData)
                }
            }

            // .g-breadcrumbs__divider: padding 0 --g-spacing-2
            GText {
                anchors.verticalCenter: parent.verticalCenter
                visible: !entry.current
                colorRole: GTextColor.Secondary
                text: breadcrumbs.separator
                leftPadding: Metrics.spacing(2)
                rightPadding: Metrics.spacing(2)
            }
        }
    }
}
