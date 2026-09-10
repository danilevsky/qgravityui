pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Progress.
//   size:  GSize.Xs|S|M -> 4/10/20px tall (only m shows the text)
//   theme: GTheme.Normal | Success | Warning | Danger | Info | Misc
//   loading: the 45-degree moving stripe overlay
Rectangle {
    id: progress

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int theme: GTheme.Normal
    // 0..100, like upstream's `value`
    property real value: 0
    property string text: ""
    property bool loading: false

    readonly property color _fill: {
        const t = progress.gcolors;
        switch (theme) {
        case GTheme.Success: return t.basePositiveMedium;
        case GTheme.Warning: return t.baseWarningMedium;
        case GTheme.Danger: return t.baseDangerMedium;
        case GTheme.Info: return t.baseInfoMedium;
        case GTheme.Misc: return t.baseMiscMedium;
        default: return t.baseNeutralMedium;
        }
    }

    implicitWidth: 200
    implicitHeight: Metrics.progressHeight(size)

    radius: Metrics.progressRadius
    color: progress.gcolors.baseGeneric
    clip: true

    Rectangle {
        id: bar

        width: parent.width * Math.max(0, Math.min(100, progress.value)) / 100
        height: parent.height
        color: progress._fill
        clip: true

        Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
        Behavior on color { ColorAnimation { duration: 600 } }

        // .g-progress__item_loading: repeating-linear-gradient(-45deg, ...)
        // drifting once every 0.5s. Rotated stripes have no QML gradient, so
        // they are drawn as a row of skewed bars.
        Item {
            id: stripes

            property real offset: 0

            visible: progress.loading
            anchors.fill: parent
            clip: true

            Row {
                x: stripes.offset - 2 * parent.height
                y: 0
                height: parent.height
                spacing: 4

                Repeater {
                    model: Math.ceil((stripes.width + 4 * stripes.height) / 8) + 1

                    Rectangle {
                        width: 4
                        height: stripes.height * 3
                        y: -stripes.height
                        color: Qt.rgba(1, 1, 1, 0.3)
                        transform: Rotation { angle: -45 }
                    }
                }
            }

            NumberAnimation on offset {
                running: stripes.visible
                loops: Animation.Infinite
                from: 0
                to: 8
                duration: 500
            }
        }
    }

    // .g-progress__text -- hidden below size m upstream
    GText {
        anchors.centerIn: parent
        visible: progress.size === GSize.M && progress.text !== ""
        variant: GVariant.BodyShort
        text: progress.text
    }
}
