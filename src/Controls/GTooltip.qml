import QtQuick
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Tooltip: hover-triggered text over a floating
// surface. Same primitive as GPopup, but Tooltip.css drops the hairline and
// uses a much shallower shadow (0 1px 5px against the popup's 0 8px 20px).
//
// Declare it inside the item it describes:
//     GButton { text: "Save"; GTooltip { text: "Ctrl+S" } }
GPopup {
    id: tip

    property string text: ""
    // The item whose hover opens the tooltip.
    property Item target: parent
    property int openDelay: 300
    property int closeDelay: 250
    // Upstream's `disabled` prop, inverted: a tooltip that is switched off
    // still exists and keeps its text, it just never shows.
    property bool active: true

    // Hover, not a click, so nothing here should steal focus or swallow the
    // press that the target itself is waiting for.
    closePolicy: T.Popup.NoAutoClose

    topPadding: Metrics.spacing(1)
    bottomPadding: Metrics.spacing(1)
    leftPadding: Metrics.spacing(2)
    rightPadding: Metrics.spacing(2)

    visible: _shown && active

    property bool _shown: false

    background: GSurface {
        borderWidth: 0
        radius: Metrics.tooltipRadius
        shadowBlurPx: 5
        shadowOffsetY: 1
    }

    // .g-tooltip max-width: 360px -- clamp the box, then let the text wrap
    // into whatever that leaves.
    implicitWidth: Math.min(implicitContentWidth, Metrics.tooltipMaxWidth)
                   + leftPadding + rightPadding

    contentItem: GText {
        text: tip.text
        wrapMode: Text.Wrap
        width: tip.availableWidth
    }

    HoverHandler {
        id: hoverHandler
        parent: tip.target
    }

    // Upstream delays both directions (openDelay/closeDelay); Popup's own
    // `delay` only covers opening, so both live in timers here.
    Timer {
        id: openTimer
        interval: tip.openDelay
        onTriggered: tip._shown = true
    }

    Timer {
        id: closeTimer
        interval: tip.closeDelay
        onTriggered: tip._shown = false
    }

    Connections {
        target: hoverHandler
        function onHoveredChanged() {
            if (hoverHandler.hovered) {
                closeTimer.stop();
                openTimer.restart();
            } else {
                openTimer.stop();
                closeTimer.restart();
            }
        }
    }
}
