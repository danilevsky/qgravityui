import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Button.
//   size: GSize.Xs | S | M (default) | L | Xl
//   icon.name: an icon from QGravityUI.Icons, drawn before the label with
//         Button.css's --_--icon-offset between them
//   view: GView.Normal (default) | Action | Raised | Outlined | Flat
//         outlined-{info,success,warning,danger,utility,action}
//         flat-{secondary,info,success,warning,danger,utility,action}
//         normal-contrast | outlined-contrast | flat-contrast
//
// Views are a table of overrides on top of the base .g-button declaration,
// mirroring how the stylesheet layers --_--* custom properties.
T.Button {
    id: control

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int view: GView.Normal

    // .g-button_selected: the pressed-in look of a toggle, used by Palette
    // and by toolbar buttons that stay on.
    property bool selected: false

    // Upstream's `pin` prop reshapes the two ends of the box; the only shape
    // the library actually asks for is circle-circle, on FilePreview's action
    // buttons, so it is exposed as a radius override rather than as a
    // nine-value enum nothing else would use. -1 keeps the size ladder.
    property real cornerRadius: -1

    readonly property real _radius: cornerRadius >= 0 ? cornerRadius
                                                      : Metrics.radiusForSize(size)

    // Templates leave focusPolicy at NoFocus and let the style decide; without
    // this the control never enters the tab chain and the ring never shows.
    focusPolicy: Qt.StrongFocus
    property int size: GSize.M

    // The flat and contrast families, spelled out. Enum values have no
    // "flat-" prefix to test for, and keying off their numeric order would
    // break the moment someone inserts a value in GView.
    readonly property bool _flat: [GView.Flat, GView.FlatSecondary, GView.FlatInfo,
                                   GView.FlatSuccess, GView.FlatWarning, GView.FlatDanger,
                                   GView.FlatUtility, GView.FlatAction,
                                   GView.FlatContrast].indexOf(view) !== -1
    readonly property bool _contrast: view === GView.NormalContrast
                                      || view === GView.OutlinedContrast
                                      || view === GView.FlatContrast

    // { text, textHover, bg, bgHover, borderWidth, borderColor }
    readonly property var _spec: {
        const t = control.gcolors;
        // .g-button
        const base = {text: t.textPrimary, textHover: undefined,
                      bg: "transparent", bgHover: t.baseSimpleHover,
                      borderWidth: 0, borderColor: "transparent"};
        const outlined = function (text, line) {
            return {text: text, borderWidth: 1, borderColor: line};
        };
        let over;
        switch (view) {
        case GView.Action:            over = {text: t.textBrandContrast, bg: t.baseBrand, bgHover: t.baseBrandHover}; break;
        case GView.Raised:            over = {bg: t.baseFloat, bgHover: t.baseFloatHover}; break;

        case GView.Outlined:          over = outlined(t.textPrimary, t.lineGeneric); break;
        case GView.OutlinedInfo:     over = outlined(t.textInfo, t.lineInfo); break;
        case GView.OutlinedSuccess:  over = outlined(t.textPositive, t.linePositive); break;
        case GView.OutlinedWarning:  over = outlined(t.textWarning, t.lineWarning); break;
        case GView.OutlinedDanger:   over = outlined(t.textDanger, t.lineDanger); break;
        case GView.OutlinedUtility:  over = outlined(t.textUtility, t.lineUtility); break;
        case GView.OutlinedAction:   over = outlined(t.textBrand, t.lineBrand); break;

        case GView.Flat:              over = {}; break;
        case GView.FlatSecondary:    over = {text: t.textSecondary, textHover: t.textPrimary}; break;
        case GView.FlatInfo:         over = {text: t.textInfo}; break;
        case GView.FlatSuccess:      over = {text: t.textPositive}; break;
        case GView.FlatWarning:      over = {text: t.textWarning}; break;
        case GView.FlatDanger:       over = {text: t.textDanger}; break;
        case GView.FlatUtility:      over = {text: t.textUtility}; break;
        case GView.FlatAction:       over = {text: t.textBrand}; break;

        case GView.NormalContrast:   over = {text: t.textDarkPrimary, bg: t.baseLight, bgHover: t.baseLightHover}; break;
        case GView.OutlinedContrast: over = {text: t.textLightPrimary, bgHover: t.baseLightSimpleHover,
                                          borderWidth: 1, borderColor: t.lineLight}; break;
        case GView.FlatContrast:     over = {text: t.textLightPrimary, bgHover: t.baseLightSimpleHover}; break;

        default:                  over = {bg: t.baseGeneric, bgHover: t.baseGenericHover}; break; // normal
        }
        const spec = Object.assign(base, over);
        if (selected)
            Object.assign(spec, _selectedOver(t));
        if (spec.textHover === undefined)
            spec.textHover = spec.text; // --_--text-color-hover defaults to --_--text-color
        return spec;
    }

    // .g-button_selected drops the border and repaints the fill. The
    // contrast family is excluded upstream, and the semantic families each
    // get their own -heavy text on a -light fill.
    function _selectedOver(t: ColorTokens): var {
        if (_contrast)
            return {borderWidth: view === GView.OutlinedContrast ? 1 : 0};
        const semantic = function (text, bg, bgHover) {
            return {text: text, textHover: text, bg: bg, bgHover: bgHover, borderWidth: 0};
        };
        switch (view) {
        case GView.OutlinedInfo:
        case GView.FlatInfo:
            return semantic(t.textInfoHeavy, t.baseInfoLight, t.baseInfoLightHover);
        case GView.OutlinedSuccess:
        case GView.FlatSuccess:
            return semantic(t.textPositiveHeavy, t.basePositiveLight, t.basePositiveLightHover);
        case GView.OutlinedWarning:
        case GView.FlatWarning:
            return semantic(t.textWarningHeavy, t.baseWarningLight, t.baseWarningLightHover);
        case GView.OutlinedDanger:
        case GView.FlatDanger:
            return semantic(t.textDangerHeavy, t.baseDangerLight, t.baseDangerLightHover);
        case GView.OutlinedUtility:
        case GView.FlatUtility:
            return semantic(t.textUtilityHeavy, t.baseUtilityLight, t.baseUtilityLightHover);
        default:
            return semantic(t.textBrandHeavy, t.baseSelection, t.baseSelectionHover);
        }
    }

    // Every Gravity color ships its own -hover token; deriving one with
    // Qt.lighter/darker would be wrong anyway, since most of these fills are
    // translucent black/white.
    readonly property color _bgColor: {
        if (!enabled) {
            if (_flat) return "transparent";
            return _contrast ? control.gcolors.baseLightDisabled : control.gcolors.baseGenericAccentDisabled;
        }
        return hovered ? _spec.bgHover : _spec.bg;
    }

    readonly property color _textColor: {
        if (!enabled) {
            if (view === GView.FlatContrast) return control.gcolors.textLightHint;
            if (_contrast) return control.gcolors.textLightSecondary;
            return control.gcolors.textHint;
        }
        return hovered ? _spec.textHover : _spec.text;
    }

    // Button.css sizes the icon slot from the control, not the label.
    readonly property int _glyphSize: size === GSize.Xl ? 20 : 16

    // The glyph follows the label unless a caller paints it apart, which is
    // what Stepper does: .g-stepper__item-icon_view_{idle,error,success} give
    // the status icon its own colour on top of the button's text colour.
    property color iconColor: control._textColor
    readonly property bool _iconOnly: text === "" && icon.name !== ""

    implicitHeight: Metrics.heightForSize(size)
    // .g-button:has(.g-button__icon:only-child) { width: --_--height }: a
    // button that is nothing but an icon is square, not padded text-width.
    implicitWidth: _iconOnly ? implicitHeight
                             : implicitContentWidth + leftPadding + rightPadding
    // The square is narrower than two text paddings plus the glyph, so
    // keeping those paddings would push the glyph off-centre -- 4px to the
    // right on a size-s close button. Upstream centres with flex; here the
    // padding has to be recomputed for the box the button actually gets.
    leftPadding: _iconOnly ? Math.round((Metrics.heightForSize(size) - _glyphSize) / 2)
                           : Metrics.buttonPadding(size)
    rightPadding: leftPadding
    spacing: Metrics.buttonIconGap(size)
    hoverEnabled: true

    font.family: Typography.fontFamily
    font.pixelSize: Metrics.fontSizeForSize(size)
    font.weight: Typography.body1.weight // --g-text-body-font-weight: 400

    // Upstream presses the whole control instead of darkening it
    // (.g-button:active { transform: scale(0.96) }).
    scale: pressed && enabled ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

    // The row is centred inside the content box instead of filling it: when a
    // caller pins the button to a square smaller than padding + glyph -- a
    // Palette cell is 36px with l-size padding of 16 on each side -- a filling
    // row starts at leftPadding and the glyph spills off to the right. Centring
    // keeps it on the button's own centre line whatever the box does, and for
    // an ordinary button, where the box is exactly the content, it is a no-op.
    contentItem: Item {
        // Built from the children's own sizes rather than from
        // contentRow.implicitWidth: the row is centred, so its position
        // already depends on this item's width, and reading its implicit
        // size back here is one edit away from a binding loop.
        implicitWidth: (glyph.visible ? glyph.width : 0)
                       + (label.visible ? label.implicitWidth : 0)
                       + contentRow.spacing
        implicitHeight: Math.max(glyph.visible ? glyph.height : 0,
                                 label.visible ? label.implicitHeight : 0)

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: control.text !== "" && glyph.visible ? Metrics.buttonIconGap(control.size) : 0

            GIcon {
                id: glyph
                anchors.verticalCenter: parent.verticalCenter
                visible: control.icon.name !== ""
                name: control.icon.name
                size: control._glyphSize
                color: control.iconColor
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                visible: control.text !== ""
                text: control.text
                font: control.font
                color: control._textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                // No elide on purpose: .g-button is `white-space: nowrap`
                // with `overflow: visible`, so a caller that caps the width
                // (Stepper's item max-width) gets a label that overflows the
                // box symmetrically, not an ellipsis. Nothing upstream
                // declares text-overflow on a button.
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    background: Rectangle {
        radius: control._radius
        color: control._bgColor
        border.width: control.enabled ? control._spec.borderWidth : 0
        border.color: control._spec.borderColor
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    GFocusRing {
        boxRadius: control._radius
        // .g-button_view_action --_--focus-outline-offset
        offset: control.view === GView.Action ? 1 : 0
        ringColor: {
            const t = control.gcolors;
            if (control._contrast)
                return t.lineLight;
            return control.view === GView.Action ? t.baseBrand : t.lineFocus;
        }
    }
}
