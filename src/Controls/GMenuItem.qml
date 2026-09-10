import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Menu.Item.
//   size:   GSize.S|M|L|Xl -> row height 24/28/32/36
//   theme:  GTheme.Normal (default) | Danger
//   active: the current value -- base-selection, a stronger tint than hover
//   selected: highlighted without being current -- the hover colour, pinned
T.AbstractButton {
    id: item

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int theme: GTheme.Normal
    property bool selected: false
    property bool active: false

    hoverEnabled: true

    leftPadding: Metrics.menuItemPadding(size)
    rightPadding: Metrics.menuItemPadding(size)

    implicitHeight: Metrics.menuItemHeight(size)
    implicitWidth: label.implicitWidth + leftPadding + rightPadding

    background: Rectangle {
        color: {
            const t = item.gcolors;
            if (item.active)
                return item.hovered ? t.baseSelectionHover : t.baseSelection;
            if (item.selected)
                return t.baseSimpleHover;
            // .g-menu__item_interactive:hover, :focus-visible -- same fill
            if ((item.hovered || item.visualFocus) && item.enabled)
                return t.baseSimpleHover;
            return "transparent";
        }
    }

    contentItem: Text {
        id: label
        text: item.text
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.family: Typography.fontFamily
        font.pixelSize: Metrics.menuFontSize(item.size)
        color: {
            const t = item.gcolors;
            // .g-menu__item_disabled wins over the danger theme upstream
            if (!item.enabled)
                return t.textSecondary;
            return item.theme === GTheme.Danger ? t.textDanger : t.textPrimary;
        }
    }
}
