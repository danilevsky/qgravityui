import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// CSS `outline` for QML: a ring drawn outside the element's box, shown only
// while focus arrived from the keyboard.
//
// Qt has no outline. A border would eat into the control's own box and shift
// its content, so the ring is a sibling rectangle grown past the control:
// CSS puts the ring's inner edge `offset` px outside the border box and grows
// it outward by `thickness`, and a negative offset pulls it inside instead --
// which is what TextInput (-1) and Tabs (-2) ask for.
//
// Declare it inside the control it decorates:
//     GFocusRing { boxRadius: Metrics.radiusForSize(control.size) }
Rectangle {
    id: ring

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    // The control whose focus the ring follows; the parent, normally.
    property Item control: parent
    // outline-offset
    property real offset: 0
    // outline-width
    property real thickness: 2
    // The radius of the box being ringed, so the ring stays concentric.
    property real boxRadius: 0
    property color ringColor: ring.gcolors.lineFocus

    anchors.fill: parent
    anchors.margins: -(offset + thickness)

    visible: control !== null && control.enabled && control.activeFocus
             && GInputMode.keyboardNavigation

    color: "transparent"
    border.width: thickness
    border.color: ringColor
    radius: Math.max(0, boxRadius + offset + thickness)

    // Above the control's own background and content.
    z: 10
}
