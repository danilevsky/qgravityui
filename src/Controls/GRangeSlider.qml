pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Slider in its range form -- upstream is one
// component whose value is either a number or a [number, number] pair;
// QML has no such dual-typed property, so the pair gets its own control,
// the way Qt's own Slider/RangeSlider are already split. Everything else
// -- size, orientation, tooltipDisplay, tooltipPlacement, marks,
// errorMessage -- is the same vocabulary as GSlider and means the same
// thing here; see that file for the reasoning behind each.
//
//   first.value / second.value: the two ends of the range (from T.RangeSlider)
//   size: GSize.S | M (default) | L | Xl
//   inputState: GInputState.Normal (default) | Error
//   tooltipDisplay: GTooltipDisplay.Auto (default) | On | Off -- shown per
//                   handle while that handle is pressed or hovered (there is
//                   no per-handle keyboard focus to read here, unlike
//                   GSlider's single handle, so Auto does not react to it)
//   marks: a count or an explicit array, ticked between `from` and `to` but
//          never drawn on `from` or `to` themselves -- see GSlider.
//
// Handle/rail metrics match GSlider exactly, so a range and a plain slider
// sitting next to each other read as the same control family.
T.RangeSlider {
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
    readonly property int _bar: _handleBorder

    readonly property int _effectivePlacement: {
        if (_vertical)
            return (tooltipPlacement === GPlacement.Left || tooltipPlacement === GPlacement.Right)
                   ? tooltipPlacement : GPlacement.Right;
        return (tooltipPlacement === GPlacement.Top || tooltipPlacement === GPlacement.Bottom)
               ? tooltipPlacement : GPlacement.Top;
    }

    // A node has no visualFocus of its own to read (T.RangeSlider keeps
    // keyboard focus on the control as a whole), so Auto here answers to
    // pointer interaction only.
    function _showTooltipFor(node): bool {
        if (tooltipDisplay === GTooltipDisplay.Off)
            return false;
        if (tooltipDisplay === GTooltipDisplay.On)
            return true;
        return node.pressed || node.hovered;
    }

    readonly property int _tooltipThickness: Typography.caption2.lineHeight + 2 * Metrics.spacing(1)
    readonly property int _tooltipTailSize: 8

    readonly property var _marks: _marksList()
    readonly property var _tickMarks: _marks.filter(v => v > from && v < to)
    readonly property int _marksReserve: _marks.length === 0 ? 0
        : _vertical ? (Metrics.spacing(1) + 28)
                    : (Metrics.spacing(1) + Typography.caption2.lineHeight)

    readonly property int _errorReserve: errorMessage !== ""
                                          ? (Metrics.spacing(1) + Typography.caption2.lineHeight) : 0

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

    function _formatValue(v: real): string {
        const decimals = (String(control.stepSize).split(".")[1] || "").length;
        return decimals > 0 ? v.toFixed(decimals) : String(Math.round(v));
    }

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

        // Fills between the two handles rather than from an edge -- the only
        // real difference from GSlider's track. Taking the min/max of the
        // two raw visualPositions sidesteps the vertical-axis inversion
        // (see GSlider.qml) instead of having to reason about it here too.
        Rectangle {
            readonly property real _lo: Math.min(control.first.visualPosition,
                                                  control.second.visualPosition)
            readonly property real _hi: Math.max(control.first.visualPosition,
                                                  control.second.visualPosition)

            x: control._vertical ? 0 : _lo * parent.width
            y: control._vertical ? _lo * parent.height : 0
            width: control._vertical ? parent.width : (_hi - _lo) * parent.width
            height: control._vertical ? (_hi - _lo) * parent.height : parent.height
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
                color: control.gcolors.baseBrand
                opacity: 0.4
                x: control._vertical ? (rail.width - width) / 2 : _t * rail.width - width / 2
                y: control._vertical ? (1 - _t) * rail.height - height / 2 : (rail.height - height) / 2
            }
        }
    }

    first.handle: Rectangle {
        id: firstHandle

        x: control._vertical ? control.leftPadding + (control.availableWidth - width) / 2
                              : control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
        y: control._vertical ? control.topPadding + control.first.visualPosition * (control.availableHeight - height)
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

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 2 * _ring
            height: parent.height + 2 * _ring
            radius: width / 2
            z: -1
            readonly property int _ring: control.first.pressed ? 4 : 0
            visible: _ring > 0 && control.enabled
            color: control._error ? control.gcolors.baseDangerLightHover
                                  : control.gcolors.baseSelectionHover
        }
    }

    second.handle: Rectangle {
        id: secondHandle

        x: control._vertical ? control.leftPadding + (control.availableWidth - width) / 2
                              : control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
        y: control._vertical ? control.topPadding + control.second.visualPosition * (control.availableHeight - height)
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

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 2 * _ring
            height: parent.height + 2 * _ring
            radius: width / 2
            z: -1
            readonly property int _ring: control.second.pressed ? 4 : 0
            visible: _ring > 0 && control.enabled
            color: control._error ? control.gcolors.baseDangerLightHover
                                  : control.gcolors.baseSelectionHover
        }
    }

    // One value bubble per handle -- same geometry as GSlider's, just keyed
    // off whichever node this instance was handed.
    Repeater {
        model: 2

        Item {
            id: tooltip

            required property int index
            readonly property var node: tooltip.index === 0 ? control.first : control.second
            readonly property bool _tailNear: control._effectivePlacement === GPlacement.Bottom
                                               || control._effectivePlacement === GPlacement.Right
            readonly property real _seam: _tailNear ? control._tooltipTailSize : control._tooltipThickness

            visible: control._showTooltipFor(node)
            z: 5
            width: control._vertical ? control._tooltipThickness + control._tooltipTailSize
                                      : Math.max(control._tooltipThickness,
                                                 bubbleText.implicitWidth + 2 * Metrics.spacing(2))
            height: control._vertical ? Math.max(control._tooltipThickness,
                                                  bubbleText.implicitHeight + 2 * Metrics.spacing(1))
                                       : control._tooltipThickness + control._tooltipTailSize
            x: control._vertical
               ? (control._effectivePlacement === GPlacement.Left
                  ? node.handle.x - width : node.handle.x + node.handle.width)
               : Math.max(0, Math.min(control.width - width,
                                       node.handle.x + node.handle.width / 2 - width / 2))
            y: control._vertical
               ? Math.max(0, Math.min(control.height - height,
                                       node.handle.y + node.handle.height / 2 - height / 2))
               : (control._effectivePlacement === GPlacement.Top
                  ? node.handle.y - height : node.handle.y + node.handle.height)

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
                text: control._formatValue(tooltip.node.value)
                font.family: Typography.fontFamily
                font.pixelSize: Typography.caption2.size
                font.weight: Font.Medium
                color: control._error ? control.gcolors.textLightPrimary : control.gcolors.textBrandContrast
            }
        }
    }

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
