pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Loader: three bars pulsing 200ms apart.
//   size: GSize.S|M|L -> 20/28/36px tall, bar width 5/7/9; the outer bars are
//   1/1.5 of the full height and the gap equals the bar width.
Row {
    id: loader

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property color color: loader.gcolors.baseBrand

    readonly property int _bar: Metrics.loaderBar(size)
    readonly property int _full: Metrics.loaderHeight(size)

    spacing: _bar

    Repeater {
        model: 3

        Rectangle {
            id: bar

            required property int index

            anchors.verticalCenter: parent.verticalCenter
            width: loader._bar
            height: index === 1 ? loader._full : Math.round(loader._full / 1.5)
            color: loader.color

            // animation-delay in CSS offsets the first pass only, so the pause
            // sits outside the loop rather than inside it -- inside, it would
            // stretch the period instead of shifting the phase.
            SequentialAnimation on opacity {
                running: true
                PauseAnimation { duration: 200 * (bar.index + 1) }
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.15; duration: 400; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
