import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Select (single choice).
//   size:  GSize.S|M|L|Xl -- the input scale, 24/28/36/44
//   view:  GView.Normal | Clear
//   options: the GMenu model, [{ value, content, disabled }]
//
// The control reuses GInputBackground so a Select and a TextField standing
// next to each other are the same box, and the dropdown is a GMenu pinned to
// at least the control's width, as SelectPopup does upstream.
T.AbstractButton {
    id: select

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M

    // Templates leave focusPolicy at NoFocus and let the style decide; without
    // this the control never enters the tab chain and the ring never shows.
    focusPolicy: Qt.StrongFocus
    property int view: GView.Normal
    property int inputState: GInputState.Normal
    property string placeholder: ""
    property var options: []
    // Change signal comes free with the property; Select has no extra one.
    property var value: undefined

    readonly property var _selected: {
        for (let i = 0; i < options.length; ++i) {
            if (options[i].value === value)
                return options[i];
        }
        return undefined;
    }

    hoverEnabled: true

    implicitHeight: Metrics.heightForSize(size)
    implicitWidth: 200

    leftPadding: Metrics.selectPadding(size) + 1
    rightPadding: Metrics.selectPadding(size) + 1

    onClicked: menu.opened ? menu.close() : menu.open()

    background: GInputBackground {
        size: select.size
        view: select.view
        inputState: select.inputState
        controlEnabled: select.enabled
        controlHovered: select.hovered
        controlFocused: menu.opened
    }

    contentItem: Item {
        Text {
            id: valueText

            anchors.left: parent.left
            anchors.right: chevron.left
            anchors.rightMargin: Metrics.spacing(1)
            anchors.verticalCenter: parent.verticalCenter

            text: select._selected !== undefined ? select._selected.content : select.placeholder
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: Metrics.fontSizeForSize(select.size)
            color: {
                const t = select.gcolors;
                if (!select.enabled)
                    return t.textHint;
                return select._selected !== undefined ? t.textPrimary : t.textHint;
            }
        }

        GIcon {
            id: chevron

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            name: "chevron-down"
            size: select.size === GSize.S ? 12 : 16
            color: select.enabled ? select.gcolors.textSecondary : select.gcolors.textHint
        }
    }

    GMenu {
        id: menu

        anchorItem: select
        size: select.size
        minimumWidth: select.width
        options: select.options

        onTriggered: function (index, option) {
            select.value = option.value;
        }
    }
}
