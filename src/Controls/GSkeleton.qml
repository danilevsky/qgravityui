import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Skeleton.
//   size:      Xs..Xl -> 20/24/28/36/44, each with its matching radius
//   variant:   GShape.Rectangle (default) | Circle | Square
//   animation: GAnimation.Gradient (default) | Pulse | None
//
// Upstream also has a size-less state: auto height with the s radius. There
// is no "unset" step in GSize, so give the skeleton a height of your own for
// that case; Xs is the closest fixed step (20px).
Rectangle {
    id: skeleton

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.Xs
    property int variant: GShape.Rectangle
    property int animation: GAnimation.Gradient

    readonly property bool _square: variant === GShape.Circle || variant === GShape.Square

    implicitWidth: _square ? implicitHeight : 200
    implicitHeight: Metrics.heightForSize(size)

    // With the gradient animation on, the sweep *is* the fill: `color` is
    // ignored by Rectangle as soon as `gradient` is set. That is the point --
    // see the comment on the gradient below.
    color: skeleton.gcolors.baseGeneric
    radius: variant === GShape.Circle
            ? height / 2
            : Metrics.radiusForSize(size)

    // .g-skeleton_animation_gradient::after: a transparent -> base-generic
    // sweep travelling from -100% to +100% of the width.
    //
    // Upstream is a child element inside an `overflow: hidden` parent, and
    // the obvious port -- a moving Rectangle under `clip: true` -- is what
    // this used to be. It is wrong on every rounded skeleton: Qt's `clip` is
    // the item's bounding rectangle, `radius` has no say in it, so on the
    // circle and square variants the sweep painted square corners inside a
    // round shape.
    //
    // So the sweep is folded into the skeleton's own fill instead. Both
    // layers are the same token, so the overlay is exactly `base-generic`
    // composited over `base-generic` where the ramp is at 1 and plain
    // `base-generic` where it is at 0 -- reproducible as a gradient on the
    // one rounded Rectangle, which then clips itself for free and stays
    // antialiased at the corners. No mask, no extra render target.
    property real _sweep: 0
    readonly property real _t: _sweep * 2 - 1
    // The travelling ramp, sampled at u: `transparent` where the sweep has
    // not arrived, full at its trailing edge, and nothing past it.
    function _ramp(u: real): real {
        const v = u - skeleton._t;
        return v < 0 || v > 1 ? 0 : v;
    }
    // base-generic under base-generic*a, both the same hue: only the alpha
    // composites (a_over + a_base * (1 - a_over)).
    function _blend(a: real): color {
        const c = skeleton.gcolors.baseGeneric;
        const over = c.a * a;
        return Qt.rgba(c.r, c.g, c.b, over + c.a * (1 - over));
    }
    readonly property real _edge: Math.min(1, Math.max(0, _t + 1))
    // A pixel wide, so the trailing edge stays a hard edge rather than a
    // second ramp back down; upstream's is the element's own border.
    readonly property real _epsilon: width > 0 ? 1 / width : 0

    gradient: skeleton.animation === GAnimation.Gradient ? sweep : null

    Gradient {
        id: sweep

        orientation: Gradient.Horizontal
        stops: [
            GradientStop {
                position: 0
                color: skeleton._blend(skeleton._ramp(0))
            },
            GradientStop {
                position: Math.min(1, Math.max(0, skeleton._t))
                color: skeleton._blend(skeleton._ramp(Math.min(1, Math.max(0, skeleton._t))))
            },
            GradientStop {
                position: skeleton._edge
                color: skeleton._blend(skeleton._ramp(skeleton._edge))
            },
            GradientStop {
                // Once the trailing edge is off the right side there is no
                // edge to draw, and the colour has to stay continuous.
                position: Math.min(1, skeleton._edge + skeleton._epsilon)
                color: skeleton._edge >= 1 ? skeleton._blend(skeleton._ramp(1))
                                           : skeleton._blend(0)
            }
        ]
    }

    // .g-skeleton_animation_pulse: 1 -> 0.5 -> 1 over 1.5s
    SequentialAnimation on opacity {
        running: skeleton.animation === GAnimation.Pulse
        loops: Animation.Infinite
        NumberAnimation { from: 1.0; to: 0.5; duration: 750 }
        NumberAnimation { from: 0.5; to: 1.0; duration: 750 }
    }

    NumberAnimation on _sweep {
        running: skeleton.animation === GAnimation.Gradient
        loops: Animation.Infinite
        from: 0
        to: 1
        duration: 1200
        easing.type: Easing.OutQuad
    }
}
