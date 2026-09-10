pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Modal: a centred sheet over an sfx-veil scrim.
//
// Modal.css puts the radius at 5px and the viewport margin at 20px, and
// animates the content from scale(0.75) over 150ms while the veil fades.
T.Popup {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    parent: T.Overlay.overlay
    anchors.centerIn: parent

    popupType: T.Popup.Item

    modal: true
    dim: true
    padding: 0

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    // The sheet is bounded by the viewport minus --g-modal-margin on each side.
    property int viewportMargin: Metrics.modalMargin

    T.Overlay.modal: Rectangle {
        color: control.gcolors.sfxVeil
    }

    background: Rectangle {
        radius: Metrics.modalRadius
        color: control.gcolors.baseModal
    }

    // Content is clipped to the radius upstream (clip-path: inset(0 round ...)).
    clip: true

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { property: "scale"; from: 0.75; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.75; duration: 150; easing.type: Easing.OutQuad }
        }
    }
}
