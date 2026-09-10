import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Disclosure.
//   size:  GSize.M|L|Xl -> body-1 / body-2 / subheader-3
//   arrow: GAlign.Start (default) | End
//
// The arrow is ArrowToggle: one ChevronDown rotated by direction, so it turns
// rather than swapping glyphs.
Column {
    id: disclosure

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int arrow: GAlign.Start
    property string summary: ""
    property bool expanded: false

    default property alias content: body.data

    spacing: Metrics.spacing(2)

    Row {
        id: trigger

        spacing: Metrics.disclosureGap
        // .g-disclosure__trigger_arrow_end
        layoutDirection: disclosure.arrow === GAlign.End ? Qt.RightToLeft : Qt.LeftToRight

        GIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron-down"
            size: 16
            color: disclosure.enabled ? disclosure.gcolors.textPrimary : disclosure.gcolors.textSecondary
            rotation: disclosure.expanded ? 0 : -90
            Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }

        GText {
            anchors.verticalCenter: parent.verticalCenter
            variant: Metrics.disclosureVariant(disclosure.size)
            text: disclosure.summary
            color: disclosure.enabled ? disclosure.gcolors.textPrimary : disclosure.gcolors.textSecondary
        }

        activeFocusOnTab: disclosure.enabled

        GFocusRing {
            boxRadius: Metrics.focusBorderRadius
        }

        HoverHandler {
            enabled: disclosure.enabled
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: disclosure.enabled
            onTapped: disclosure.expanded = !disclosure.expanded
        }
    }

    Column {
        id: body

        width: disclosure.width
        visible: disclosure.expanded
        // g-disclosure-expanded / -collapsed: 0.2s in, 0.1s out
        opacity: disclosure.expanded ? 1.0 : 0.4
        Behavior on opacity { NumberAnimation { duration: disclosure.expanded ? 200 : 100 } }
    }
}
