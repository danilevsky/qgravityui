import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Popover: a Popup carrying a title, a body and an
// optional close button.
//
// Popover ships no stylesheet of its own in 7.49.0 -- upstream composes it
// from Popup plus layout props -- so the padding (--g-spacing-4), the 8px
// title/body gap and the body width are our choices, not transcribed values.
GPopup {
    id: popover

    property string title: ""
    property string message: ""
    property bool closable: true
    property int bodyWidth: 280

    signal closeRequested()

    padding: Metrics.spacing(4)
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside

    // An Item rather than the Column itself: a positioner's implicitWidth is
    // read-only, so it cannot state the width the popup should take.
    contentItem: Item {
        implicitWidth: popover.bodyWidth
        implicitHeight: column.implicitHeight

        Column {
            id: column

            width: parent.width
            spacing: Metrics.spacing(2)

            Item {
                width: parent.width
                height: Math.max(titleText.implicitHeight, closeButton.height)
                visible: popover.title !== "" || popover.closable

                GText {
                    id: titleText
                    variant: GVariant.Subheader2
                    text: popover.title
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: closeButton.visible ? closeButton.left : parent.right
                    anchors.rightMargin: closeButton.visible ? Metrics.spacing(2) : 0
                    elide: Text.ElideRight
                }

                GButton {
                    id: closeButton
                    visible: popover.closable
                    view: GView.Flat
                    size: GSize.S
                    icon.name: "xmark"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        popover.closeRequested();
                        popover.close();
                    }
                }
            }

            GText {
                width: parent.width
                text: popover.message
                visible: text !== ""
                wrapMode: Text.Wrap
            }
        }
    }
}
