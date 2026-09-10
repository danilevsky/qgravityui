import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Checkbox.
//   size: GSize.M (default) | L | Xl   -- indicator 14 / 17 / 24 px
T.CheckBox {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M

    // Templates leave focusPolicy at NoFocus and let the style decide; without
    // this the control never enters the tab chain and the ring never shows.
    focusPolicy: Qt.StrongFocus

    readonly property int _box: Metrics.toggleIndicator(size)

    // .g-checkbox_size_* .g-checkbox__icon-svg_type_tick / _type_dash
    readonly property size _tickSize: {
        if (checkState === Qt.PartiallyChecked) {
            switch (size) {
            case GSize.L: return Qt.size(15, 15);
            case GSize.Xl: return Qt.size(22, 22);
            default: return Qt.size(12, 12);
            }
        }
        switch (size) {
        case GSize.L: return Qt.size(11, 9);
        case GSize.Xl: return Qt.size(16, 13);
        default: return Qt.size(8, 10);
        }
    }

    readonly property string _tickSvg:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 10" fill="currentColor">' +
        '<path d="M.49 5.385l1.644-1.644 4.385 4.385L4.874 9.77.49 5.385zm4.384 1.096L10.356 1 12 2.644' +
        ' 6.519 8.126 4.874 6.48v.001z"/></svg>'

    readonly property string _dashSvg:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 17 17" fill="currentColor">' +
        '<path d="M4 7h9v3H4z"/></svg>'

    spacing: Metrics.spacing(2) // --g-spacing-2, ControlLabel.css
    hoverEnabled: true

    implicitHeight: Math.max(_box, contentItem.implicitHeight)
    implicitWidth: _box + (text ? spacing + contentItem.implicitWidth : 0)

    indicator: Rectangle {
        implicitWidth: control._box
        implicitHeight: control._box
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: 4 // Checkbox.css hardcodes 4px, it does not follow the size scale

        readonly property bool _on: control.checked || control.checkState === Qt.PartiallyChecked

        color: {
            const t = control.gcolors;
            if (!control.enabled) return t.baseGenericAccentDisabled;
            if (!_on) return "transparent";
            return control.hovered ? t.baseBrandHover : t.baseBrand;
        }
        border.width: (_on || !control.enabled) ? 0 : 1
        border.color: control.hovered ? control.gcolors.lineGenericAccentHover
                                      : control.gcolors.lineGenericAccent
        Behavior on color { ColorAnimation { duration: 100 } }

        // CheckboxTickIcon / CheckboxDashIcon: Checkbox ships its own two
        // glyphs rather than pulling them from @gravity-ui/icons, so they are
        // inline here too. Both are wider than tall and are sized per the
        // .g-checkbox__icon-svg_type_* rules, not by the indicator box.
        GIcon {
            anchors.centerIn: parent
            visible: parent._on
            width: control._tickSize.width
            height: control._tickSize.height
            svg: control.checkState === Qt.PartiallyChecked ? control._dashSvg : control._tickSvg
            color: control.enabled ? control.gcolors.textBrandContrast : control.gcolors.textHint
        }
    }

    GFocusRing {
        // .g-checkbox__outline: the whole control, radius 4
        boxRadius: 4
    }

    contentItem: GControlLabel {
        text: control.text
        size: control.size
        controlEnabled: control.enabled
        leftPadding: control.indicator.width + control.spacing
    }
}
