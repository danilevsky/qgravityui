import QtQuick
import QtQuick.Window
import QGravityUI.Core
import QGravityUI.Tokens
import QGravityUI.Controls

Window {
    width: 320
    height: 140
    visible: true
    color: Theme.colors.baseBackground
    title: "QGravityUI consumer"

    Column {
        anchors.centerIn: parent
        spacing: Metrics.spacing(3)

        GText { variant: GVariant.Header1; text: "It links" }

        Row {
            spacing: Metrics.spacing(2)
            GButton { view: GView.Action; icon.name: "circle-check"; text: "Action" }
            GButton { view: GView.Outlined; text: "Outlined" }
        }
    }

    // Exits on its own so CI can run it as a smoke test.
    Timer {
        interval: 1500
        running: true
        onTriggered: Qt.exit(0)
    }
}
