import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens
import QGravityUI.Controls

// One row of GNavigationAside's item list (top-level or inline sublist).
// Mirrors GMenuItem's active/hover precedence so current-page highlighting
// reads the same way selection does in GMenu.
//
//   iconName:    an icon from QGravityUI.Icons -- named iconName rather than
//                icon.name because T.AbstractButton already owns `icon` as
//                an IconGroup
//   compact:     icon-only, no label -- the aside is collapsed. The label is
//                still there for screen readers/tooltips, just not painted.
//   active:      this is the current page
//   hasChildren: draws a trailing chevron; GNavigationAside decides what
//                happens on click (inline sublist vs. flyout)
//   expanded:    purely visual -- rotates the chevron. GNavigationAside owns
//                the actual open/closed state.
T.AbstractButton {
    id: item

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string iconName: ""
    property bool compact: false
    property bool active: false
    property bool hasChildren: false
    property bool expanded: false

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    readonly property int _rowHeight: Metrics.asideItemHeight
    readonly property int _iconGap: Metrics.spacing(2)
    readonly property int _inline: Metrics.spacing(3)

    implicitHeight: _rowHeight
    implicitWidth: _rowHeight + 160

    background: Rectangle {
        radius: Metrics.radiusS
        color: {
            const t = item.gcolors;
            if (item.active)
                return item.hovered ? t.baseSelectionHover : t.baseSelection;
            if ((item.hovered || item.visualFocus) && item.enabled)
                return t.baseSimpleHover;
            return "transparent";
        }
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Item {
        implicitHeight: item._rowHeight

        GIcon {
            id: glyph
            x: item.compact ? (parent.width - width) / 2 : item._inline
            anchors.verticalCenter: parent.verticalCenter
            visible: item.iconName !== ""
            name: item.iconName
            size: 18
            color: item.active ? item.gcolors.textBrand : item.gcolors.textPrimary
        }

        GText {
            id: label
            x: glyph.visible ? glyph.x + glyph.width + item._iconGap : item._inline
            anchors.verticalCenter: parent.verticalCenter
            visible: !item.compact
            text: item.text
            elide: Text.ElideRight
            width: Math.max(0, parent.width - x - item._inline
                                - (arrow.visible ? arrow.width + item._iconGap : 0))
            colorRole: item.active ? GTextColor.Brand : GTextColor.Primary
        }

        GArrowToggle {
            id: arrow
            visible: item.hasChildren && !item.compact
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - width - item._inline
            direction: item.expanded ? GPlacement.Bottom : GPlacement.Right
            color: item.active ? item.gcolors.textBrand : item.gcolors.textPrimary
        }
    }

    GFocusRing {
        boxRadius: Metrics.radiusS
    }

    // Compact mode drops the label, so the row's own text becomes a tooltip
    // instead -- the same trade GDropdownMenu's icon-only switcher makes.
    GTooltip {
        text: item.text
        active: item.compact && item.text !== ""
        placement: GPlacement.Right
    }
}
