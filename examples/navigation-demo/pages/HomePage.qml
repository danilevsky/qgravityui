import QtQuick
import QtQuick.Layouts
import QGravityUI.Tokens
import QGravityUI.Controls

GCard {
    view: GView.Filled
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    ColumnLayout {
        width: parent.width
        spacing: Metrics.spacing(3)

        GText { variant: GVariant.Header1; text: "Home" }
        GText {
            Layout.fillWidth: true
            variant: GVariant.Body1
            colorRole: GTextColor.Secondary
            wrapMode: Text.Wrap
            text: "This page is swapped in by the Loader in Main.qml whenever "
                  + "GNavigationAside.activated fires for a leaf item."
        }
    }
}
