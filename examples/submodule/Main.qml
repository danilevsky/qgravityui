import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens
import QGravityUI.Controls

Window {
    width: 420
    height: 160
    visible: true
    color: Theme.colors.baseBackground

    Column {
        anchors.centerIn: parent
        spacing: Metrics.spacing(4)

        GText { variant: GVariant.Header1; text: "Submodule consumer" }

        Row {
            spacing: Metrics.spacing(3)
            GButton { text: "Action"; view: GView.Action }
            GButton { text: "Outlined"; view: GView.Outlined; icon.name: "circle-check" }
            GLabel { content: "works" ; theme: GTheme.Success }
        }
    }
}
