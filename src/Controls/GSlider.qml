pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Slider (BaseSlider.css), extended with a couple
// of things upstream does not have:
//
//   - `orientation`: Qt.Horizontal (default) | Qt.Vertical. Upstream is
//     horizontal-only; T.Slider already tracks pointer input on either axis
//     (that is what `orientation` already meant on the base type), this only
//     had to draw the vertical rail, handle and tooltip.
//   - `tooltipPlacement`: which side of the handle the value bubble opens on.
//     GPlacement carries all four directions for every overlay in this
//     library; a slider only ever wants the two that fit its own axis, so
//     Top/Bottom apply when horizontal and Left/Right when vertical -- same
//     "accepts the subset that fits, falls back otherwise" rule as every
//     other Gravity enum here.
//
//   size: GSize.S | M (default) | L | Xl
//   inputState: GInputState.Normal (default) | Error -- a non-empty
//               `errorMessage` also switches the slider into the error
//               palette, same as setting inputState directly.
//   tooltipDisplay: GTooltipDisplay.Auto (default, shown while dragging,
//                   hovered or focused) | On (always) | Off (never)
//   marks: how many evenly spaced ticks to draw from `from` to `to` (a
//          number, upstream's own shorthand), or the exact values to mark
//          (an array) -- empty (the default) draws none.
//
// Handle 15/18/21/24 with border 3/4/5/6; rail and track 3/4/5/6 tall. The
// tooltip bubble and the mark labels are sized generously off the caption
// type step rather than measured against the formatted value, the same
// fixed-chrome trade-off GList's row height makes -- a caller formatting
// unusually long values may want extra room around the slider.
T.Slider {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int inputState: GInputState.Normal
    property int tooltipDisplay: GTooltipDisplay.Auto
    property int tooltipPlacement: GPlacement.Top
    property string errorMessage: ""
    property var marks: []

    orientation: Qt.Horizontal

    readonly property bool _vertical: control.orientation === Qt.Vertical
    readonly property bool _error: control.inputState === GInputState.Error
                                    || control.errorMessage !== ""

    readonly property int _handle: {
        switch (size) {
        case GSize.S: return 15;
        case GSize.L: return 21;
        case GSize.Xl: return 24;
        default: return 18;
        }
    }
    readonly property int _handleBorder: {
        switch (size) {
        case GSize.S: return 3;
        case GSize.L: return 5;
        case GSize.Xl: return 6;
        default: return 4;
        }
    }
    readonly property int _bar: _handleBorder // rail/track heights match the border widths

    // Top/Bottom only make sense on a horizontal rail and Left/Right only on
    // a vertical one; a placement from the other pair falls back to this
    // axis's own default instead of being silently ignored mid-drag.
    readonly property int _effectivePlacement: {
        if (_vertical)
            return (tooltipPlacement === GPlacement.Left || tooltipPlacement === GPlacement.Right)
                   ? tooltipPlacement : GPlacement.Right;
        return (tooltipPlacement === GPlacement.Top || tooltipPlacement === GPlacement.Bottom)
               ? tooltipPlacement : GPlacement.Top;
    }

    readonly property bool _showTooltip: {
        if (tooltipDisplay === GTooltipDisplay.Off)
            return false;
        if (tooltipDisplay === GTooltipDisplay.On)
            return true;
        return control.pressed || control.hovered || control.visualFocus;
    }

    // One line of caption text plus its own vertical padding -- the bubble's
    // thickness across the rail, regardless of how long the value inside it
    // happens to be (that dimension is sized to the text instead, see the
    // tooltip Item below). Unlike marks and the error message, the tooltip
    // reserves no layout space of its own: in the default Auto display it
    // only exists while the handle is being interacted with, and a slider
    // that grew every time a caller touched it would be worse than one whose
    // tooltip is free to draw outside its own bounds -- the same trade every
    // hover tooltip in this library already makes.
    readonly property int _tooltipThickness: Typography.caption2.lineHeight + 2 * Metrics.spacing(1)
    readonly property int _tooltipTailSize: 8

    readonly property var _marks: _marksList()
    // The dot at `from` or `to` would land right on the rail's own rounded
    // end-cap (or under the handle, at rest on a fresh slider) and just
    // muddies it -- upstream leaves both ends bare and only ticks the values
    // in between. The label under/beside them is unaffected, `_marks` still
    // carries the endpoints for that.
    readonly property var _tickMarks: _marks.filter(v => v > from && v < to)
    // Caption line plus a small gap, on whichever side the marks sit on
    // (below the rail when horizontal, beside it when vertical). The width a
    // vertical column needs depends on the labels' own text, which is why it
    // gets a flatter, more generous guess than the horizontal case.
    readonly property int _marksReserve: _marks.length === 0 ? 0
        : _vertical ? (Metrics.spacing(1) + 28)
                    : (Metrics.spacing(1) + Typography.caption2.lineHeight)

    readonly property int _errorReserve: errorMessage !== ""
                                          ? (Metrics.spacing(1) + Typography.caption2.lineHeight) : 0

    // marks: N -> N evenly spaced ticks including both ends; marks: [...] ->
    // ticks at exactly those values. Mirrors the two forms upstream accepts.
    function _marksList() {
        const out = [];
        if (Array.isArray(marks)) {
            for (const v of marks) {
                if (v >= from && v <= to)
                    out.push(v);
            }
            out.sort((a, b) => a - b);
        } else if (typeof marks === "number" && marks >= 2 && to > from) {
            const count = Math.floor(marks);
            const step = (to - from) / (count - 1);
            for (let i = 0; i < count; ++i)
                out.push(from + i * step);
        }
        return out;
    }

    // Mirrors `stepSize`'s own precision instead of the raw float, so a
    // step of 0.5 reads "11.5" rather than "11.500000000000002".
    function _formatValue(v: real): string {
        const decimals = (String(control.stepSize).split(".")[1] || "").length;
        return decimals > 0 ? v.toFixed(decimals) : String(Math.round(v));
    }

    // Marks and the error message are permanent chrome, so they get real
    // layout space: below the rail when horizontal, beside it when vertical.
    topPadding: 0
    bottomPadding: (!_vertical ? _marksReserve : 0) + _errorReserve
    leftPadding: 0
    rightPadding: _vertical ? _marksReserve : 0

    implicitWidth: _vertical ? (leftPadding + _handle + rightPadding) : 200
    implicitHeight: _vertical ? 200 : (topPadding + _handle + bottomPadding)
    hoverEnabled: true

    background: Rectangle {
        id: rail

        x: control._vertical ? control.leftPadding + control.availableWidth / 2 - width / 2
                              : control.leftPadding
        y: control._vertical ? control.topPadding
                              : control.topPadding + control.availableHeight / 2 - height / 2
        width: control._vertical ? control._bar : control.availableWidth
        height: control._vertical ? control.availableHeight : control._bar
        radius: 4
        color: {
            const t = control.gcolors;
            if (!control.enabled) return t.baseGenericAccentDisabled;
            return control._error ? t.baseDangerHeavy : t.baseSelection;
        }

        // .g-base-slider__track is hidden entirely in the disabled and error states.
        // Vertical fills from the bottom (the minimum) up to the handle, same
        // as horizontal fills from the left -- both grow from `from` towards
        // the current value.
        Rectangle {
            x: 0
            y: control._vertical ? control.visualPosition * parent.height : 0
            width: control._vertical ? parent.width : control.visualPosition * parent.width
            height: control._vertical ? (1 - control.visualPosition) * parent.height : parent.height
            radius: parent.radius
            color: control.gcolors.baseBrand
            visible: control.enabled && !control._error
        }

        Repeater {
            model: control._tickMarks

            Rectangle {
                id: tick

                required property real modelData
                readonly property real _t: (modelData - control.from) / (control.to - control.from)

                width: 4
                height: 4
                radius: 2
                // Same hue as the fill, not a colour of its own -- a dim tint
                // of it, so a tick reads as "part of the rail" rather than a
                // separate mark drawn over it.
                color: control.gcolors.baseBrand
                opacity: 0.4
                x: control._vertical ? (rail.width - width) / 2 : _t * rail.width - width / 2
                y: control._vertical ? (1 - _t) * rail.height - height / 2 : (rail.height - height) / 2
            }
        }
    }

    handle: Rectangle {
        id: handleRect

        x: control._vertical ? control.leftPadding + (control.availableWidth - width) / 2
                              : control.leftPadding + control.visualPosition * (control.availableWidth - width)
        // T.Slider's own vertical convention already puts the maximum at the
        // top: visualPosition is 0 there and 1 at the bottom. Flipping it
        // again here (an earlier version of this file did) drew the handle
        // opposite of where a click or a drag actually landed it.
        y: control._vertical ? control.topPadding + control.visualPosition * (control.availableHeight - height)
                              : control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: control._handle
        implicitHeight: control._handle
        radius: width / 2
        color: control.gcolors.baseBackground
        border.width: control._handleBorder
        border.color: {
            const t = control.gcolors;
            if (!control.enabled) return t.baseGenericAccent;
            return control._error ? t.baseDangerHeavy : t.baseBrand;
        }

        // :focus and :active grow a 3px / 4px ring around the handle
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 2 * _ring
            height: parent.height + 2 * _ring
            radius: width / 2
            z: -1
            readonly property int _ring: control.pressed ? 4 : (control.visualFocus ? 3 : 0)
            visible: _ring > 0 && control.enabled
            color: control._error ? control.gcolors.baseDangerLightHover
                                  : control.gcolors.baseSelectionHover
        }
    }

    // The value bubble. Tail is always the edge touching the rail; the
    // bubble itself sits on the far side of it, away from the rail.
    Item {
        id: tooltip

        readonly property bool _tailNear: control._effectivePlacement === GPlacement.Bottom
                                           || control._effectivePlacement === GPlacement.Right
        readonly property real _seam: _tailNear ? control._tooltipTailSize : control._tooltipThickness

        visible: control._showTooltip
        z: 5
        width: control._vertical ? control._tooltipThickness + control._tooltipTailSize
                                  : Math.max(control._tooltipThickness,
                                             bubbleText.implicitWidth + 2 * Metrics.spacing(2))
        height: control._vertical ? Math.max(control._tooltipThickness,
                                              bubbleText.implicitHeight + 2 * Metrics.spacing(1))
                                   : control._tooltipThickness + control._tooltipTailSize
        // The axis across the rail is measured off the handle, not the
        // control's own bounds -- Top/Left placements land above or beside
        // it, in negative coordinates the control never clips, exactly like
        // any other hover tooltip floating clear of its owner. The axis
        // along the rail stays clamped, since that direction usually does
        // have a sibling on either side to run into.
        x: control._vertical
           ? (control._effectivePlacement === GPlacement.Left
              ? control.handle.x - width : control.handle.x + control.handle.width)
           : Math.max(0, Math.min(control.width - width,
                                   control.handle.x + control.handle.width / 2 - width / 2))
        y: control._vertical
           ? Math.max(0, Math.min(control.height - height,
                                   control.handle.y + control.handle.height / 2 - height / 2))
           : (control._effectivePlacement === GPlacement.Top
              ? control.handle.y - height : control.handle.y + control.handle.height)

        Rectangle {
            id: bubble

            radius: Metrics.radiusS
            color: control._error ? control.gcolors.baseDangerHeavy : control.gcolors.baseBrand
            x: control._vertical ? (tooltip._tailNear ? control._tooltipTailSize : 0) : 0
            y: control._vertical ? 0 : (tooltip._tailNear ? control._tooltipTailSize : 0)
            width: control._vertical ? control._tooltipThickness : parent.width
            height: control._vertical ? parent.height : control._tooltipThickness
        }

        Rectangle {
            width: control._tooltipTailSize
            height: control._tooltipTailSize
            rotation: 45
            color: bubble.color
            z: -1
            x: control._vertical ? tooltip._seam - width / 2 : tooltip.width / 2 - width / 2
            y: control._vertical ? tooltip.height / 2 - height / 2 : tooltip._seam - height / 2
        }

        Text {
            id: bubbleText

            anchors.centerIn: bubble
            text: control._formatValue(control.value)
            font.family: Typography.fontFamily
            font.pixelSize: Typography.caption2.size
            font.weight: Font.Medium
            color: control._error ? control.gcolors.textLightPrimary : control.gcolors.textBrandContrast
        }
    }

    // Mark labels, below the rail when horizontal and beside it when
    // vertical; the dot on the rail itself is drawn as part of `background`.
    Repeater {
        model: control._marks

        GText {
            id: markLabel

            required property real modelData
            readonly property real _t: (modelData - control.from) / (control.to - control.from)

            variant: GVariant.Caption2
            colorRole: GTextColor.Hint
            text: control._formatValue(modelData)
            x: control._vertical ? control.leftPadding + control._handle + Metrics.spacing(1)
                                  : control.leftPadding + _t * control.availableWidth - implicitWidth / 2
            y: control._vertical ? control.topPadding + (1 - _t) * control.availableHeight - implicitHeight / 2
                                  : control.topPadding + control.availableHeight + Metrics.spacing(1)
        }
    }

    GText {
        visible: control.errorMessage !== ""
        variant: GVariant.Caption2
        colorRole: GTextColor.Danger
        text: control.errorMessage
        elide: Text.ElideRight
        x: 0
        y: control.height - implicitHeight
        width: control.width
    }
}
