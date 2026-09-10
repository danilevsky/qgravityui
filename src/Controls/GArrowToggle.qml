import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit ArrowToggle: one ChevronDown rotated to point
// where you ask, over 0.1s ease-out.
//   direction: GPlacement.Bottom (default) | Top | Left | Right
GIcon {
    id: toggle

    property int direction: GPlacement.Bottom

    name: "chevron-down"
    size: 16

    // .g-arrow-toggle_direction_*: the CSS matrices are quarter turns.
    rotation: {
        switch (direction) {
        case GPlacement.Top: return 180;
        case GPlacement.Left: return 90;
        case GPlacement.Right: return -90;
        default: return 0;
        }
    }

    Behavior on rotation {
        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
    }
}
