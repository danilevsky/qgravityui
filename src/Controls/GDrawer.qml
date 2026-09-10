pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Drawer: a panel that slides in from an edge over
// an sfx-veil.
//
//   placement: GPlacement.Left (default) | Right | Top | Bottom
//   panelSize: thickness across the edge -- width for left/right, height for
//              top/bottom. Named so it is not mistaken for a GSize step.
//   hideVeil:  no scrim; the panel gets a 0 1px 5px shadow instead, as
//              .g-drawer_hide-veil does.
//
// The popup covers the whole window and the panel inside it is what moves,
// exactly as .g-drawer / .g-drawer__item are split upstream. Sliding the
// popup itself does not work: QQuickPopup repositions popups to keep them on
// screen, and that assignment overwrites the binding driving the animation.
//
// Not ported: the resize handle (.g-drawer__resizer).
T.Popup {
    id: drawer

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int placement: GPlacement.Left
    property int panelSize: 320
    property bool hideVeil: false

    default property alias content: panelContent.data

    // 1 while fully off-screen, 0 when open; animated by the transitions.
    property real slide: 1

    readonly property bool _horizontal: placement === GPlacement.Left
                                        || placement === GPlacement.Right

    parent: T.Overlay.overlay
    // Item-based, so the panel is part of the window's scene rather than a
    // separate native window.
    popupType: T.Popup.Item

    modal: !hideVeil
    dim: !hideVeil
    padding: 0
    clip: true

    x: 0
    y: 0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    background: null

    T.Overlay.modal: Rectangle {
        color: drawer.gcolors.sfxVeil
        // .g-drawer transitions its background-color over the same 300ms
        opacity: drawer.opened ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Metrics.drawerDuration } }
    }

    contentItem: Item {
        // Clicking beside the panel dismisses, the way the veil does.
        TapHandler {
            onTapped: drawer.close()
        }

        // .g-drawer__item
        GSurface {
            id: panel

            color: drawer.gcolors.baseBackground
            radius: 0
            shadowEnabled: drawer.hideVeil
            shadowBlurPx: 5
            shadowOffsetY: 1

            width: drawer._horizontal ? drawer.panelSize : parent.width
            height: drawer._horizontal ? parent.height : drawer.panelSize

            x: {
                if (!drawer._horizontal)
                    return 0;
                return drawer.placement === GPlacement.Left
                        ? -width * drawer.slide
                        : parent.width - width + width * drawer.slide;
            }

            y: {
                if (drawer._horizontal)
                    return 0;
                return drawer.placement === GPlacement.Top
                        ? -height * drawer.slide
                        : parent.height - height + height * drawer.slide;
            }

            // Swallow taps so they do not reach the dismissing handler behind.
            TapHandler {}

            Item {
                id: panelContent
                anchors.fill: parent
            }
        }
    }

    enter: Transition {
        NumberAnimation {
            target: drawer
            property: "slide"
            from: 1
            to: 0
            duration: Metrics.drawerDuration
            easing.type: Easing.OutQuad
        }
    }

    exit: Transition {
        NumberAnimation {
            target: drawer
            property: "slide"
            from: 0
            to: 1
            duration: Metrics.drawerDuration
            easing.type: Easing.InQuad
        }
    }
}
