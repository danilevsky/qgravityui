import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit ClipboardButton: copies `content` and says so.
//
//   content:  the string that goes to the clipboard
//   text:     an optional label beside the icon (icon-only by default)
//   timeout:  how long the success state lasts, 1200ms upstream
//   hasTooltip / tooltipInitialText / tooltipSuccessText
//
// The glyph is upstream's ClipboardIcon: copy, copy-check after a successful
// copy, copy-xmark if the platform has no clipboard at all (a headless run,
// or a Wayland session with no window focus).
GButton {
    id: control

    property string content: ""
    property int timeout: 1200
    property bool hasTooltip: true
    property string tooltipInitialText: qsTr("Copy")
    property string tooltipSuccessText: qsTr("Copied")

    // "" | "success" | "error", mirroring CopyToClipboard's status
    readonly property string status: _status

    signal copied(string content, bool ok)

    property string _status: ""

    view: GView.Flat
    icon.name: _status === "success" ? "copy-check"
                                     : (_status === "error" ? "copy-xmark" : "copy")

    onClicked: {
        const ok = GClipboard.setText(control.content);
        control._status = ok ? "success" : "error";
        resetTimer.restart();
        control.copied(control.content, ok);
    }

    Timer {
        id: resetTimer

        interval: control.timeout
        onTriggered: control._status = ""
    }

    GActionTooltip {
        // Upstream swaps the tooltip's text in place while it is open, so the
        // label changes under the pointer rather than reopening.
        title: control._status === "success" ? control.tooltipSuccessText
                                             : control.tooltipInitialText
        active: control.hasTooltip
    }
}
