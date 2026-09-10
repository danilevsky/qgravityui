pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit ActionsPanel: the brand-coloured bar that appears
// over a table once rows are selected.
//
//   note:     the text on the left ("3 selected"), subheader-2 on brand
//   actions:  [{text, icon, view, enabled, collapsed}] -- rendered as
//             flat-contrast buttons, and folded into an overflow menu when
//             they stop fitting. `collapsed: true` sends one straight there.
//   maxRowActions: hard cap on how many stay in the row; 0 means "as many as
//             fit"
//   closable: the xmark on the far right
//
// Upstream measures the buttons with an IntersectionObserver and hides the
// ones that fall outside. There is no observer here: the widths are computed
// from the label metrics before anything is laid out, which is the same
// arithmetic done a frame earlier and avoids a binding loop between "how many
// fit" and "how wide is the row".
Rectangle {
    id: panel

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string note: ""
    property var actions: []
    property int maxRowActions: 0
    property bool closable: true

    signal actionTriggered(int index, var action)
    signal closeRequested()

    // .g-actions-panel
    readonly property int _padding: 20
    readonly property int _noteGap: 40
    readonly property int _actionMargin: 4
    readonly property int _menuSlot: 32

    // The width at which nothing has to collapse. It must not be derived from
    // _collapse: the panel's own width is what _collapse reads, and a Rectangle
    // takes its width from implicitWidth unless a layout overrides it.
    readonly property real _naturalRowWidth: {
        let total = 0;
        for (const action of actions)
            total += _actionWidth(action) + 2 * _actionMargin;
        return total;
    }

    implicitWidth: Math.max(200, _padding * 2 + (note !== "" ? note0.width + _noteGap : 0)
                            + _naturalRowWidth + 8
                            + (closable ? closeButton.implicitWidth : 0))
    implicitHeight: 52
    radius: 10
    color: gcolors.baseBrand

    // Width of one flat-contrast button, from Button.css's box: padding on
    // both sides, a 16px icon slot, the label, and the gap between them.
    function _actionWidth(action): real {
        const hasIcon = action.icon !== undefined && action.icon !== "";
        const hasText = action.text !== undefined && action.text !== "";
        let inner = 0;
        if (hasIcon)
            inner += 16;
        if (hasText) {
            // FontMetrics, not TextMetrics: writing `text` on a shared
            // TextMetrics from inside a binding makes the binding depend on
            // something it just changed, and _collapse loops.
            inner += Math.ceil(measure.advanceWidth(action.text));
            if (hasIcon)
                inner += Metrics.buttonIconGap(GSize.M);
        }
        return inner + 2 * Metrics.buttonPadding(GSize.M);
    }

    // {row: [indices], menu: [indices]}. Computed twice: once assuming the
    // overflow button is there, and again without it if nothing overflowed --
    // otherwise reserving its slot could push out the very action that made
    // it necessary.
    readonly property var _collapse: {
        const available = Math.max(0, width - 2 * _padding
                                   - (note !== "" ? noteBox.width + _noteGap : 0)
                                   - (closable ? closeButton.implicitWidth : 0)
                                   // .g-actions-panel-collapse padding-inline-end
                                   - 8);

        const fit = function (reserve) {
            const row = [];
            const menu = [];
            let used = reserve ? panel._menuSlot : 0;
            for (let i = 0; i < panel.actions.length; ++i) {
                const action = panel.actions[i];
                const capped = panel.maxRowActions > 0 && row.length >= panel.maxRowActions;
                if (action.collapsed === true || capped) {
                    menu.push(i);
                    continue;
                }
                const w = panel._actionWidth(action) + 2 * panel._actionMargin;
                if (used + w > available) {
                    menu.push(i);
                    continue;
                }
                used += w;
                row.push(i);
            }
            return {row: row, menu: menu};
        };

        const withMenu = fit(true);
        if (withMenu.menu.length === 0)
            return withMenu;
        const plain = fit(false);
        return plain.menu.length === 0 ? plain : withMenu;
    }

    FontMetrics {
        id: measure

        font.family: Typography.fontFamily
        font.pixelSize: Metrics.fontSizeForSize(GSize.M)
        font.weight: Typography.body1.weight
    }

    // Only here to give implicitWidth something to ask about: the visible note
    // is elided to whatever room is left, so its own width cannot be used.
    TextMetrics {
        id: note0

        font.family: Typography.fontFamily
        font.pixelSize: Typography.subheader2.size
        font.weight: Typography.subheader2.weight
        text: panel.note
    }

    Item {
        id: noteBox

        visible: panel.note !== ""
        x: panel._padding
        y: 0
        height: parent.height
        // flex-shrink is 1 on the note and 2 on the actions, so the actions
        // give way first: the note keeps its natural width down to the point
        // where only the overflow button would be left, and never goes below
        // min-width: 100px. Reserving just that slot -- rather than the row's
        // real width -- is what keeps this independent of _collapse, which
        // reads this width in turn.
        width: visible
               ? Math.max(100, Math.min(note0.width,
                                        panel.width - 2 * panel._padding - panel._noteGap
                                        - panel._menuSlot - 8
                                        - (panel.closable ? closeButton.implicitWidth : 0)))
               : 0

        GText {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            variant: GVariant.Subheader2
            color: panel.gcolors.textLightPrimary
            text: panel.note
            elide: Text.ElideRight
        }
    }

    Row {
        id: actionsRow

        x: panel._padding + (panel.note !== "" ? noteBox.width + panel._noteGap : 0)
        height: parent.height

        Repeater {
            model: panel._collapse.row

            Item {
                id: slot

                required property int modelData

                width: button.implicitWidth + 2 * panel._actionMargin
                height: actionsRow.height

                GButton {
                    id: button

                    readonly property var spec: panel.actions[slot.modelData]

                    anchors.centerIn: parent
                    view: button.spec.view !== undefined ? button.spec.view : GView.FlatContrast
                    size: GSize.M
                    text: button.spec.text !== undefined ? button.spec.text : ""
                    icon.name: button.spec.icon !== undefined ? button.spec.icon : ""
                    enabled: button.spec.enabled !== undefined ? button.spec.enabled : true
                    onClicked: panel.actionTriggered(slot.modelData, button.spec)
                }
            }
        }

        // .g-actions-panel-collapse__menu-placeholder is a 32px slot; the
        // button inside it is an ordinary 28px one, centred, like every
        // other action. Letting the switcher fill the slot instead painted
        // its hover fill as a band down the whole 52px bar.
        Item {
            visible: panel._collapse.menu.length > 0
            width: visible ? panel._menuSlot : 0
            height: actionsRow.height

            GDropdownMenu {
                id: overflow

                anchors.centerIn: parent
                // The menu rows are small upstream, the switcher is not.
                size: GSize.S
                switcherSize: GSize.M
                switcherView: GView.FlatContrast
                switcherIcon: "ellipsis"
                // GMenu reads `content`, not `text`: with the wrong key the
                // popup opened as an empty white box.
                options: panel._collapse.menu.map(function (i) {
                    const action = panel.actions[i];
                    return {content: action.text !== undefined ? action.text : "",
                            disabled: action.enabled === false,
                            _index: i};
                })

                onTriggered: function (index, option) {
                    panel.actionTriggered(option._index, panel.actions[option._index]);
                }
            }
        }
    }

    GButton {
        id: closeButton

        visible: panel.closable
        anchors.right: parent.right
        anchors.rightMargin: panel._padding
        anchors.verticalCenter: parent.verticalCenter
        view: GView.FlatContrast
        size: GSize.M
        icon.name: "xmark"
        onClicked: panel.closeRequested()
    }
}
