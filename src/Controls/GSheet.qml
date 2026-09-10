pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Sheet: the bottom sheet, full width, hugging its
// content up to the height of the window.
//
// Sheet.css rounds the top corners by 20px only when there is a top bar, and
// the bar is 20px tall with a 40x4 grabber in the middle.
//
// Same split as GDrawer: the popup covers the window (.g-sheet) and the panel
// inside it slides (.g-sheet__sheet). It also keeps the panel's height honest
// -- it follows its own content instead of the popup's implicit size, which
// settles before wrapped text has found its height.
//
// Not ported: swipe-to-dismiss. .g-sheet-swipe-area is a 40px drag target and
// upstream follows the finger; that is gesture plumbing rather than styling.
T.Popup {
    id: sheet

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property bool topBar: true
    property string title: ""

    default property alias content: bodyColumn.data

    // 1 while fully below the window, 0 when open.
    property real slide: 1

    parent: T.Overlay.overlay
    popupType: T.Popup.Item

    modal: true
    dim: true
    padding: 0
    clip: true

    x: 0
    y: 0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    background: null

    T.Overlay.modal: Rectangle {
        color: sheet.gcolors.sfxVeil
        opacity: sheet.opened ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Metrics.drawerDuration } }
    }

    contentItem: Item {
        TapHandler {
            onTapped: sheet.close()
        }

        // .g-sheet__sheet
        Rectangle {
            id: panel

            color: sheet.gcolors.baseFloat
            // .g-sheet__sheet:has(> .g-sheet__sheet-top)
            topLeftRadius: sheet.topBar ? Metrics.sheetRadius : 0
            topRightRadius: sheet.topBar ? Metrics.sheetRadius : 0

            width: parent.width
            height: Math.min(column.implicitHeight, parent.height)
            y: parent.height - height + height * sheet.slide
            clip: true

            TapHandler {}

            Column {
                id: column

                width: parent.width
                spacing: 0

                // .g-sheet__sheet-top with its resizer grabber
                Item {
                    width: parent.width
                    height: Metrics.sheetTopHeight
                    visible: sheet.topBar

                    Rectangle {
                        anchors.centerIn: parent
                        width: Metrics.sheetGrabberWidth
                        height: Metrics.sheetGrabberHeight
                        radius: Metrics.sheetGrabberHeight
                        color: sheet.gcolors.lineGeneric
                    }
                }

                // .g-sheet-content-area__content-title
                GText {
                    width: parent.width
                    visible: sheet.title !== ""
                    variant: GVariant.Body2
                    text: sheet.title
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    bottomPadding: 8
                }

                // .g-sheet-content-area__content
                Column {
                    id: bodyColumn

                    x: Metrics.sheetContentPadding
                    width: parent.width - 2 * Metrics.sheetContentPadding
                    spacing: Metrics.spacing(2)
                    bottomPadding: Metrics.sheetContentPadding
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation {
            target: sheet
            property: "slide"
            from: 1
            to: 0
            duration: Metrics.drawerDuration
            easing.type: Easing.OutQuad
        }
    }

    exit: Transition {
        NumberAnimation {
            target: sheet
            property: "slide"
            from: 0
            to: 1
            duration: Metrics.drawerDuration
            easing.type: Easing.InQuad
        }
    }
}
