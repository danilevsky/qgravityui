import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QGravityUI.Tokens
import QGravityUI.Controls
import QtQml.Models

GCard {
    id:root
    view: GView.Filled
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight
    readonly property IconCatalog _catalog: IconCatalog {}
    property ListModel _iconsModel : ListModel {}
    property int iconSize : GSize.Xl
    property int iconCellSize : Metrics.heightForSize(iconSize) + Metrics.buttonPadding(iconSize)

    GDialog {
        id: dialogIcon
        size: GSize.S
        title: "Icon"
        actions: [{text: "Close", view: GView.Filled}]
        onActionTriggered: dialogIcon.close()

        property string iconName : ""

        ColumnLayout
        {

            RowLayout {
                spacing: Metrics.spacing(GSize.M)

                GCard {
                    Layout.alignment: Qt.AlignTop
                    view: GView.Outlined

                    Layout.minimumWidth: 100
                    Layout.minimumHeight: 100

                    GIcon {
                        size : root.iconCellSize
                        name: dialogIcon.iconName
                        anchors.centerIn: parent
                    }
                }
                GClipboardButton {
                    Layout.alignment: Qt.AlignTop
                    content: dialogIcon.iconName
                    tooltipInitialText: "Copy icon name"
                    text: dialogIcon.iconName
                }
            }

            Item {
                height: Metrics.spacing(GSize.M)
            }
        }


    }

    SortFilterProxyModel {
        id: filterModel
        model: root._iconsModel
        property string filterText : ""
        filters: [
            FunctionFilter {
            component RoleData : QtObject { property string name }
            function filter(data : RoleData) : bool {
                return data.name.toLowerCase().includes(filterModel.filterText)
            }
            }
        ]
    }

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
        GTextField {
            id: textSearch
            placeholderText:"Search"
            onTextChanged: { filterModel.filterText = textSearch.text; filterModel.invalidate(); }
        }

        ScrollView
        {
            id: iconsScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            GridView {
                id:iconsView
                cellWidth: root.iconCellSize
                cellHeight: root.iconCellSize
                anchors.fill: iconsScrollView
                clip:true

                Component {
                    id:iconViewDelegate
                    GButton {
                        view: GView.Flat
                        icon.name: name
                        size: root.iconSize
                        onClicked: {
                            dialogIcon.iconName = name;
                            dialogIcon.open();
                        }

                        GTooltip { text: name }
                    }
                }

                model: filterModel
                delegate:iconViewDelegate

                focus: true
            }
        }
    }
}
