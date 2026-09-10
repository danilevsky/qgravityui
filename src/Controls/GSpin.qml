import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Spin: a half-ring turning once per second.
//   size: GSize.Xs|S|M|L|Xl -> 16/24/28/32/36
//
// Upstream builds the arc from a half-width box with three borders and a 25px
// corner radius. A QML Rectangle cannot drop one side of its border, so the
// same shape is a full ring clipped to its trailing half.
Item {
    id: spin

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property color color: spin.gcolors.baseBrand
    property bool running: true

    readonly property int _side: Metrics.spinSize(size)

    implicitWidth: _side
    implicitHeight: _side

    Item {
        id: rotor
        anchors.fill: parent

        Item {
            x: parent.width / 2
            width: parent.width / 2
            height: parent.height
            clip: true

            Rectangle {
                x: -parent.width
                width: spin._side
                height: spin._side
                radius: spin._side / 2
                color: "transparent"
                border.width: Metrics.spinBorder
                border.color: spin.color
            }
        }

        RotationAnimator on rotation {
            running: spin.running && spin.visible
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 1000
        }
    }
}
