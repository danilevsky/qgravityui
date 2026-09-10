pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Menu, driven by a model rather than by declared
// children: the size has to reach every row, and pushing it into
// user-declared items after the fact is exactly the kind of implicit coupling
// that breaks the moment someone nests a row.
//
//   options: [{ content, theme, disabled, active, separatorBefore }]
//   size:    GSize.S|M|L|Xl
GPopup {
    id: menu

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property var options: []
    // Select drives its dropdown to at least the width of the control.
    property real minimumWidth: 0

    signal triggered(int index, var option)

    // Rows stretch to the menu width, so asking the laid-out rows how wide
    // they want to be is a binding loop. The width comes from measuring the
    // model's text up front instead.
    property real _maxTextWidth: 0

    function _measure() {
        let w = 0;
        for (let i = 0; i < options.length; ++i) {
            metrics.text = options[i].content !== undefined ? String(options[i].content) : "";
            w = Math.max(w, metrics.advanceWidth);
        }
        _maxTextWidth = w;
    }

    onOptionsChanged: _measure()
    onSizeChanged: _measure()
    Component.onCompleted: _measure()

    TextMetrics {
        id: metrics
        font.family: Typography.fontFamily
        font.pixelSize: Metrics.menuFontSize(menu.size)
    }

    padding: 0
    // .g-menu_size_* padding: --g-spacing-1 0
    topPadding: Metrics.spacing(1)
    bottomPadding: Metrics.spacing(1)

    implicitWidth: Math.max(minimumWidth,
                            Math.ceil(_maxTextWidth) + 2 * Metrics.menuItemPadding(size))
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    contentItem: Column {
        spacing: 0

        Repeater {
            model: menu.options

            Column {
                id: row

                required property int index
                required property var modelData

                width: parent.width

                Rectangle {
                    // .g-menu__list-group-item border-block-start
                    visible: row.modelData.separatorBefore === true && row.index > 0
                    width: parent.width
                    height: 1
                    color: menu.gcolors.lineGeneric
                }

                GMenuItem {
                    width: parent.width
                    size: menu.size
                    text: row.modelData.content !== undefined ? row.modelData.content : ""
                    theme: row.modelData.theme !== undefined ? row.modelData.theme : GTheme.Normal
                    enabled: row.modelData.disabled !== true
                    active: row.modelData.active === true
                    onClicked: {
                        menu.triggered(row.index, row.modelData);
                        menu.close();
                    }
                }
            }
        }
    }
}
