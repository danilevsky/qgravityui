import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit HelpMark: a question mark that opens a popover.
//   size: GSize.S | M (default) | L | Xl -> 14 / 16 / 18 / 20
Item {
    id: helpMark

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property string title: ""
    property string message: ""

    readonly property int _side: ComponentMetrics.helpMarkSize(size)

    implicitWidth: _side
    implicitHeight: _side

    GIcon {
        anchors.fill: parent
        name: "circle-question"
        size: helpMark._side
        color: hover.hovered ? helpMark.gcolors.textSecondary : helpMark.gcolors.textHint
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: popover.opened ? popover.close() : popover.open()
    }

    GPopover {
        id: popover

        anchorItem: helpMark
        title: helpMark.title
        message: helpMark.message
        // .g-help-mark__popover
        padding: Metrics.spacing(3)
    }
}
