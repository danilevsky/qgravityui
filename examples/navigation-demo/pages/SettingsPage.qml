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

        GText { variant: GVariant.Header1; text: "Settings" }
        GText {
            Layout.fillWidth: true
            variant: GVariant.Body1
            colorRole: GTextColor.Secondary
            wrapMode: Text.Wrap
            text: "Stand-in content."
        }
    }
}
