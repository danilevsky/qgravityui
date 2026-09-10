import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Accordion: a bordered box holding GAccordionItem
// rows, radius by size.
//
//   size: GSize.M (default) | L | Xl -- the box's own radius
//   view: GView.Outlined (default) | GView.Clear, standing in for upstream's
//         "top-bottom": no radius and no side borders
//
// Rows carry their own size and draw their own separator; the accordion only
// provides the frame and the width they stretch to.
Item {
    id: accordion

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int view: GView.Outlined

    default property alias content: column.data

    readonly property bool _outlined: view !== GView.Clear

    implicitWidth: 320
    implicitHeight: column.implicitHeight + (_outlined ? 2 : 2)

    Rectangle {
        anchors.fill: parent
        visible: accordion._outlined
        color: "transparent"
        radius: Metrics.accordionRadius(accordion.size)
        border.width: 1
        border.color: accordion.gcolors.lineGeneric
    }

    // .g-accordion_view_top-bottom: only the two horizontal rules survive.
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        visible: !accordion._outlined
        color: accordion.gcolors.lineGeneric
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        visible: !accordion._outlined
        color: accordion.gcolors.lineGeneric
    }

    Column {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 1
        spacing: 0
        clip: true
    }
}
