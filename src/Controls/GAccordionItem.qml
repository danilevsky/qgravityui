import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// One row of GAccordion: a summary that toggles and a details block.
//
// AccordionSummary.css sets the trigger's padding and type step per size
// (5 / --g-spacing-2 / --g-spacing-3 against subheader-1 / -2 / -2), and
// AccordionItem.css the details padding underneath.
//
// The row carries its own `size`: pushing it down from the accordion would
// mean assigning over whatever the caller wrote there.
Column {
    id: item

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property string summary: ""
    property bool expanded: false
    property int arrow: GAlign.Start

    default property alias details: detailsColumn.data

    signal toggled(bool expanded)

    // .g-accordion-item:not(:first-child) border-block-start -- a row can see
    // for itself whether it is the first one.
    readonly property bool _first: parent !== null && parent.children.length > 0
                                   && parent.children[0] === item

    readonly property int _inline: ComponentMetrics.accordionItemPaddingInline(size)

    width: parent !== null ? parent.width : implicitWidth
    spacing: 0

    Rectangle {
        width: parent.width
        height: 1
        visible: !item._first
        color: item.gcolors.lineGeneric
    }

    // .g-accordion-summary__trigger
    Item {
        id: trigger

        width: parent.width
        height: summaryText.implicitHeight
                + 2 * Metrics.accordionSummaryPaddingBlock(item.size)

        activeFocusOnTab: item.enabled

        Rectangle {
            anchors.fill: parent
            color: hover.hovered && item.enabled ? item.gcolors.baseSimpleHover
                                                 : "transparent"
        }

        GArrowToggle {
            id: arrowIcon

            anchors.verticalCenter: parent.verticalCenter
            x: item.arrow === GAlign.End
               ? parent.width - width - ComponentMetrics.accordionSummaryPaddingInline(item.size)
               : ComponentMetrics.accordionSummaryPaddingInline(item.size)
            direction: item.expanded ? GPlacement.Bottom : GPlacement.Right
            color: item.enabled ? item.gcolors.textPrimary : item.gcolors.textHint
        }

        GText {
            id: summaryText

            anchors.verticalCenter: parent.verticalCenter
            x: item.arrow === GAlign.End
               ? ComponentMetrics.accordionSummaryPaddingInline(item.size)
               : arrowIcon.x + arrowIcon.width + Metrics.disclosureGap
            width: trigger.width - x
                   - ComponentMetrics.accordionSummaryPaddingInline(item.size)
                   - (item.arrow === GAlign.End ? arrowIcon.width + Metrics.disclosureGap : 0)
            variant: Metrics.accordionSummaryVariant(item.size)
            text: item.summary
            elide: Text.ElideRight
            color: item.enabled ? item.gcolors.textPrimary : item.gcolors.textHint
        }

        GFocusRing {
            boxRadius: 0
            offset: -2
        }

        HoverHandler {
            id: hover
            enabled: item.enabled
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: item.enabled
            onTapped: {
                item.expanded = !item.expanded;
                item.toggled(item.expanded);
            }
        }
    }

    // .g-accordion-item__details
    Item {
        width: parent.width
        visible: item.expanded
        height: visible ? detailsColumn.implicitHeight
                          + Metrics.spacing(0.5)
                          + Metrics.accordionDetailsPaddingBottom(item.size)
                        : 0

        Column {
            id: detailsColumn

            x: item._inline
            y: Metrics.spacing(0.5)
            width: parent.width - 2 * item._inline
            spacing: Metrics.spacing(2)
        }
    }
}
