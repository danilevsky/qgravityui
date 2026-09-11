import QtQuick
import QtQuick.Layouts
import QGravityUI.Tokens
import QGravityUI.Controls

GCard {
    id:root
    view: GView.Filled
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight
    readonly property IconCatalog _catalog: IconCatalog {}
    property ListModel _iconsModel : ListModel {}

    WorkerScript {
        id: worker
        source: "dataloader.js"
    }

    Component.onCompleted : {
        var msg = { 'action':'append_icons', 'icons': root._catalog.names,'model':root._iconsModel};
        worker.sendMessage(msg);
    }

    ColumnLayout {
        id: mainLayout
        width: parent.width
        height: parent.height
        spacing: Metrics.spacing(3)

        GText { variant: GVariant.Header1; text: "Icons" }

        GridView {
            id:iconsListView
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root._iconsModel
            delegate:
                GButton {
                    view: GView.Flat
                    icon.name: model.name
                    size: GSize.L
                }
        }

    }
}
