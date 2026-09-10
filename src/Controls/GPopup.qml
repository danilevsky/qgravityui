import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Popup: the floating primitive Tooltip, Popover,
// Menu and Select are all built from.
//
//   anchorItem: the item to position against (defaults to the parent)
//   placement:  GPlacement.Bottom (default) | Top | Left | Right
//   distance:   gap to the anchor, 4px like the floating-ui offset upstream
//
// Positioning rides on QQuickPopup's own `parent`: the popup still renders in
// the window overlay, but its x/y are read relative to the anchor, so it
// follows the anchor around without recomputing scene coordinates.
T.Popup {
    id: popup

    property Item anchorItem: parent
    property int placement: GPlacement.Bottom

    property int distance: Metrics.popupDistance

    // Animated by the enter/exit transitions; folded into x/y so the slide
    // does not fight the positioning bindings.
    property real slideOffset: 0

    parent: anchorItem

    // Since Qt 6.8 a popup may become its own native window. Gravity's popups
    // are nodes inside the page, so item-based is the closer analogue -- and
    // it keeps them in the window's scene, where they scale with it and can
    // be screenshotted. The cost is that a popup cannot spill outside the
    // window; nothing here is big enough for that to bite.
    popupType: T.Popup.Item

    padding: 0

    // QtQuick.Templates deliberately leaves this to the style: without it a
    // popup is 0x0 and only its shadow shows up.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    x: {
        if (!anchorItem)
            return 0;
        switch (placement) {
        case GPlacement.Left: return -width - distance - slideOffset;
        case GPlacement.Right: return anchorItem.width + distance + slideOffset;
        default: return Math.round((anchorItem.width - width) / 2);
        }
    }

    y: {
        if (!anchorItem)
            return 0;
        switch (placement) {
        case GPlacement.Top: return -height - distance - slideOffset;
        case GPlacement.Bottom: return anchorItem.height + distance + slideOffset;
        default: return Math.round((anchorItem.height - height) / 2);
        }
    }

    background: GSurface {
        borderWidth: Metrics.popupBorderWidth
        radius: Metrics.popupRadius
        shadowBlurPx: 20
        shadowOffsetY: 8
    }

    // [data-floating-ui-status]: 100ms ease-out on opacity plus a 10px slide
    // away from the anchor.
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: popup; property: "slideOffset"; from: 10; to: 0; duration: 100; easing.type: Easing.OutQuad }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: popup; property: "slideOffset"; from: 0; to: 10; duration: 100; easing.type: Easing.OutQuad }
        }
    }
}
