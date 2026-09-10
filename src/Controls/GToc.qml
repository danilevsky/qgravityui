pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Toc: a table of contents.
//   items: [{ value, content, depth }] -- depth 0..6, indenting by 12px
//
// TocItem.css hangs a 2px rule down the inline start of every link; it is
// line-generic normally and line-brand on the active one, which is what
// carries the "you are here" marker.
Column {
    id: toc

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property var value: undefined

    signal activated(int index, var item)

    spacing: 0

    Repeater {
        model: toc.items

        Item {
            id: entry

            required property int index
            required property var modelData

            readonly property bool active: toc.value !== undefined
                                           && toc.value === modelData.value
            readonly property int depth: modelData.depth !== undefined
                                         ? modelData.depth : 0

            width: toc.width
            height: Math.max(Metrics.tocLinkMinHeight, label.implicitHeight)
                    + 2 * Metrics.tocLinkPaddingBlock

            activeFocusOnTab: true

            // .g-toc-item__section-link border-inline-start
            Rectangle {
                width: Metrics.tocMarkerWidth
                height: parent.height
                color: entry.active ? toc.gcolors.lineBrand : toc.gcolors.lineGeneric
            }

            GText {
                id: label

                anchors.verticalCenter: parent.verticalCenter
                x: Metrics.tocLinkPaddingInline
                   + entry.depth * Metrics.tocDepthIndent
                width: parent.width - x - Metrics.tocLinkPaddingBlock
                text: entry.modelData.content !== undefined ? entry.modelData.content : ""
                elide: Text.ElideRight
                color: {
                    const t = toc.gcolors;
                    if (entry.active)
                        return t.textPrimary;
                    return hover.hovered ? t.textComplementary : t.textSecondary;
                }
            }

            GFocusRing {
                offset: -2
                boxRadius: Metrics.focusBorderRadius + 2
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    toc.value = entry.modelData.value;
                    toc.activated(entry.index, entry.modelData);
                }
            }
        }
    }
}
