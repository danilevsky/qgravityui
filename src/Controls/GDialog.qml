pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Dialog: a Modal with the header / body / footer
// frame. Every number below is from Dialog.css and its subcomponents --
// header 20/10 vertical, body 10, footer 28, all against a 32px side padding,
// footer buttons 10px apart with a 128px minimum, close button at 14/14.
//
//   size:    GSize.S|M|L -> 480 / 720 / 900
//   actions: [{ text, view }] -- the footer buttons, right aligned
GModal {
    id: dialog

    property string title: ""
    property int size: GSize.M
    property bool hasCloseButton: true
    property var actions: []

    default property alias body: bodyColumn.data

    signal actionTriggered(int index, var action)

    readonly property int _sidePadding: Metrics.dialogSidePadding

    implicitWidth: Metrics.dialogWidth(size)

    contentItem: Item {
        implicitHeight: frame.implicitHeight

        Column {
            id: frame
            width: parent.width

            // .g-dialog-header
            Item {
                width: parent.width
                height: dialog.title === "" ? 0 : 20 + 24 + 10
                visible: dialog.title !== ""

                GText {
                    variant: GVariant.Subheader3
                    text: dialog.title
                    elide: Text.ElideRight
                    anchors.left: parent.left
                    anchors.leftMargin: dialog._sidePadding
                    anchors.right: parent.right
                    // .g-dialog_has-close adds --_--close-button-space
                    anchors.rightMargin: dialog._sidePadding + (dialog.hasCloseButton ? 24 : 0)
                    anchors.top: parent.top
                    anchors.topMargin: 20
                }
            }

            // .g-dialog-body
            Item {
                width: parent.width
                implicitHeight: bodyColumn.implicitHeight + 20

                Column {
                    id: bodyColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: dialog._sidePadding
                    anchors.rightMargin: dialog._sidePadding
                    anchors.topMargin: 10
                    spacing: Metrics.spacing(2)
                }
            }

            // .g-dialog-footer
            Item {
                width: parent.width
                height: dialog.actions.length === 0 ? 0 : buttons.height + 2 * 28
                visible: dialog.actions.length > 0

                Row {
                    id: buttons
                    spacing: 10
                    anchors.right: parent.right
                    anchors.rightMargin: dialog._sidePadding
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: dialog.actions

                        GButton {
                            required property int index
                            required property var modelData

                            text: modelData.text !== undefined ? modelData.text : ""
                            view: modelData.view !== undefined ? modelData.view : GView.Normal
                            // .g-dialog-footer__button min-width
                            implicitWidth: Math.max(128, implicitContentWidth + leftPadding + rightPadding)
                            onClicked: dialog.actionTriggered(index, modelData)
                        }
                    }
                }
            }
        }

        // .g-dialog-btn-close
        GButton {
            visible: dialog.hasCloseButton
            view: GView.Flat
            size: GSize.S
            icon.name: "xmark"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 14
            anchors.topMargin: 14
            onClicked: dialog.close()
        }
    }
}
