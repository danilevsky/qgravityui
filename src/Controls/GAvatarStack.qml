pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit AvatarStack: avatars sliding under one another,
// with a "+N" circle when the list is longer than `visibleCount`.
//
//   items:       [{ text, imageSource }]
//   overlapSize: GSize.S | M (default) | L -> 4 / 8 / 12 px of overlap
//
// Source order runs left to right and each avatar slides under the one
// before it, so the z order counts down rather than the row being reversed.
Row {
    id: stack

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property int size: GSize.M
    property int overlapSize: GSize.M
    property int visibleCount: 3

    signal moreClicked()

    readonly property int _side: Metrics.avatarSize(size)
    readonly property int _shown: Math.min(visibleCount, items.length)
    readonly property int _hidden: items.length - _shown

    // .g-avatar-stack__item:not(:last-child) margin-inline-end
    spacing: -Metrics.avatarStackOverlap(overlapSize)

    Repeater {
        model: stack._shown

        GAvatar {
            required property int index

            // Earlier avatars sit on top of later ones.
            z: stack._shown - index
            size: stack.size
            text: {
                const item = stack.items[index];
                return item.text !== undefined ? item.text : "";
            }
            imageSource: {
                const item = stack.items[index];
                return item.imageSource !== undefined ? item.imageSource : "";
            }
        }
    }

    // .g-avatar-stack__more
    Rectangle {
        visible: stack._hidden > 0
        width: stack._side
        height: stack._side
        radius: width / 2
        color: stack.gcolors.baseGeneric
        border.width: 1
        border.color: stack.gcolors.baseBackground
        z: 0

        GText {
            anchors.centerIn: parent
            variant: Metrics.avatarTextVariant(stack.size)
            text: "+" + stack._hidden
        }

        TapHandler {
            onTapped: stack.moreClicked()
        }
    }

}
