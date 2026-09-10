pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Toaster: the bottom-right stack the toasts land
// in. 312px wide, 10px from the edge, 10px between items (ToastList.css and
// Toast.css --_--item-gap).
//
// Declare one somewhere that fills the window and call add():
//     toaster.add({title: "Saved", content: "...", theme: GTheme.Success})
//
// The queue is a ListModel, not a JS array, and that is the whole design:
// a Repeater over `property var toasts` tears down every delegate the moment
// the array is reassigned, so each add() or remove() replayed the enter
// animation on every toast already on screen -- the stack blinked out and
// faded back in together. A ListModel row is inserted or removed on its own
// and the neighbouring delegates are never touched.
Item {
    id: toaster

    // Auto-dismiss in ms; 0 keeps a toast until it is closed.
    property int defaultTimeout: 5000

    readonly property int count: queue.count

    property int _nextId: 1

    // Every field is written here rather than defaulted at the delegate:
    // ListModel fixes its roles from the first row it is given, so a toast
    // added without a title would otherwise define the role away for good.
    // The roles are prefixed because the delegate declares each of them as
    // a required property -- typed, checkable by qmllint, compiled by qmlsc
    // and, unlike `model.title`, not read back off a row that has just been
    // removed. `title`, `content`, `theme` and `closable` are all names GToast
    // already has, and a delegate cannot redeclare its own property.
    function add(toast): int {
        const id = _nextId++;
        queue.append({
            toastId: id,
            toastTitle: toast.title !== undefined ? toast.title : "",
            toastContent: toast.content !== undefined ? toast.content : "",
            toastTheme: toast.theme !== undefined ? toast.theme : GTheme.Normal,
            toastClosable: toast.closable !== false,
            toastTimeout: toast.timeout !== undefined ? toast.timeout : defaultTimeout,
            toastClosing: false
        });
        return id;
    }

    // Two-phase, so the toast can play g-toast-leave-desktop before its row
    // goes: `closing` is what the delegate watches, and the delegate is what
    // calls _drop() when the animation is done.
    function remove(id: int) {
        const at = _indexOf(id);
        if (at !== -1 && !queue.get(at).toastClosing)
            queue.setProperty(at, "toastClosing", true);
    }

    function removeAll() {
        for (let i = 0; i < queue.count; ++i)
            queue.setProperty(i, "toastClosing", true);
    }

    function _indexOf(id: int): int {
        for (let i = 0; i < queue.count; ++i) {
            if (queue.get(i).toastId === id)
                return i;
        }
        return -1;
    }

    function _drop(id: int) {
        const at = _indexOf(id);
        if (at !== -1)
            queue.remove(at);
    }

    ListModel {
        id: queue
    }

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Metrics.toastGap
        anchors.bottomMargin: Metrics.toastGap
        width: Metrics.toastWidth
        spacing: Metrics.toastGap

        // Closing one toast in the middle of the stack slides the ones below
        // it up instead of teleporting them.
        move: Transition {
            NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutQuad }
        }

        Repeater {
            model: queue

            GToast {
                id: toastItem

                required property int toastId
                required property string toastTitle
                required property string toastContent
                required property int toastTheme
                required property bool toastClosable
                required property int toastTimeout
                required property bool toastClosing

                width: parent.width
                theme: toastItem.toastTheme
                title: toastItem.toastTitle
                content: toastItem.toastContent
                closable: toastItem.toastClosable

                onCloseRequested: toaster.remove(toastItem.toastId)

                // g-toast-enter-desktop, 0.6s ease-out in two halves: the row
                // first opens up to its height while still invisible, then
                // fades in and slides the last 10px into place.
                opacity: 0
                x: 10

                SequentialAnimation {
                    id: enter

                    running: true
                    NumberAnimation {
                        target: toastItem
                        property: "openProgress"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                    ParallelAnimation {
                        NumberAnimation { target: toastItem; property: "opacity"; to: 1.0; duration: 300 }
                        NumberAnimation { target: toastItem; property: "x"; to: 0; duration: 300; easing.type: Easing.OutQuad }
                    }
                }

                // g-toast-leave-desktop: fade and slide out, then collapse the
                // row, and only then drop it from the queue -- a row removed
                // first would take its delegate with it and there would be
                // nothing left to animate.
                SequentialAnimation {
                    running: toastItem.toastClosing
                    // A toast closed before it finished arriving would
                    // otherwise have both animations writing its opacity.
                    ScriptAction { script: enter.stop() }
                    ParallelAnimation {
                        NumberAnimation { target: toastItem; property: "opacity"; to: 0; duration: 200 }
                        NumberAnimation { target: toastItem; property: "x"; to: 10; duration: 200; easing.type: Easing.InQuad }
                    }
                    NumberAnimation {
                        target: toastItem
                        property: "openProgress"
                        to: 0
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                    ScriptAction {
                        script: toaster._drop(toastItem.toastId)
                    }
                }

                Timer {
                    interval: toastItem.toastTimeout
                    running: interval > 0 && !toastItem.toastClosing
                    onTriggered: toaster.remove(toastItem.toastId)
                }
            }
        }
    }
}
