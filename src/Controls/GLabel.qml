import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Label.
//   theme: GTheme.Normal (default) | Success | Info | Warning | Danger | Utility |
//          unknown | clear
//   size:  GSize.Xxs|Xs|S|M -> 18/20/24/28
//   content / value: rendered as "content: value", with the ": value" half at
//          70% opacity, exactly as .g-label__value does
//   interactive: hover highlight + clicked()
//   closable:    trailing addon button + closeClicked()
Rectangle {
    id: label

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int theme: GTheme.Normal
    property int size: GSize.M
    property string content: ""
    property string value: ""
    property bool interactive: false
    property bool closable: false

    signal clicked()
    signal closeClicked()

    readonly property var _spec: {
        const t = label.gcolors;
        switch (theme) {
        case GTheme.Success: return {bg: t.basePositiveLight, bgHover: t.basePositiveLightHover, fg: t.textPositiveHeavy};
        case GTheme.Info: return {bg: t.baseInfoLight, bgHover: t.baseInfoLightHover, fg: t.textInfoHeavy};
        case GTheme.Warning: return {bg: t.baseWarningLight, bgHover: t.baseWarningLightHover, fg: t.textWarningHeavy};
        case GTheme.Danger: return {bg: t.baseDangerLight, bgHover: t.baseDangerLightHover, fg: t.textDangerHeavy};
        case GTheme.Utility: return {bg: t.baseUtilityLight, bgHover: t.baseUtilityLightHover, fg: t.textUtilityHeavy};
        case GTheme.Unknown: return {bg: t.baseNeutralLight, bgHover: t.baseNeutralLightHover, fg: t.textComplementary};
        case GTheme.Clear: return {bg: "transparent", bgHover: t.baseSimpleHover, fg: t.textComplementary};
        default: return {bg: t.baseMiscLight, bgHover: t.baseMiscLightHover, fg: t.textMiscHeavy};
        }
    }

    readonly property int _height: Metrics.labelHeight(size)
    readonly property int _margin: Metrics.labelMarginInline(size)

    implicitHeight: _height
    implicitWidth: _margin + textRow.implicitWidth
                   + (closable ? Metrics.labelAddonMargin(size) : _margin)

    radius: Metrics.labelRadius(size)
    color: interactive && bodyHover.hovered && !closeHover.hovered ? _spec.bgHover : _spec.bg
    // .g-label_theme_clear draws its outline with an inset box-shadow
    border.width: theme === GTheme.Clear ? 1 : 0
    border.color: label.gcolors.lineGeneric
    // .g-label_disabled
    opacity: enabled ? 1.0 : 0.7

    HoverHandler {
        id: bodyHover
        enabled: label.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: label.interactive
        onTapped: label.clicked()
    }

    Row {
        id: textRow

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: label._margin
        spacing: 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: label.content
            color: label._spec.fg
            font.family: Typography.fontFamily
            font.pixelSize: Typography.bodyShort.size
            font.weight: Typography.bodyShort.weight
        }

        Row {
            // .g-label__value -- separator included, hence the shared opacity
            anchors.verticalCenter: parent.verticalCenter
            visible: label.value !== ""
            spacing: 0
            opacity: 0.7

            Text {
                text: ":"
                color: label._spec.fg
                font.family: Typography.fontFamily
                font.pixelSize: Typography.bodyShort.size
                // .g-label__separator margin: 0 4px
                rightPadding: 4
                leftPadding: 4
            }

            Text {
                text: label.value
                color: label._spec.fg
                font.family: Typography.fontFamily
                font.pixelSize: Typography.bodyShort.size
            }
        }
    }

    Rectangle {
        // .g-label__addon_side_end: a square the height of the label, square
        // on its leading corners so it sits flush in the pill.
        id: closeAddon

        visible: label.closable
        width: label._height
        height: label._height
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        radius: label.radius
        topLeftRadius: 0
        bottomLeftRadius: 0
        color: closeHover.hovered ? label._spec.bgHover : "transparent"
        // .g-label__addon_type_button:active
        scale: closeTap.pressed ? 0.96 : 1.0

        GIcon {
            anchors.centerIn: parent
            name: "xmark"
            size: label.size === GSize.Xxs || label.size === GSize.Xs ? 12 : 16
            color: label._spec.fg
        }

        HoverHandler {
            id: closeHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: closeTap
            onTapped: label.closeClicked()
        }
    }
}
