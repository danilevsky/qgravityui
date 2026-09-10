import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of .g-control-label__text -- the label half of @gravity-ui/uikit
// ControlLabel, used as the contentItem of GCheckbox, GRadio and GSwitch.
// The indicator half has no counterpart here: in QML the QQC2 control owns it.
//
// Note the label scale is its own: s/m use body-1 and l/xl use body-2, unlike
// buttons and inputs where only xl steps up.
Text {
    id: label

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)
    property int size: GSize.M

    // Upstream dims a disabled label to 60% of text-primary rather than
    // switching it to text-hint.
    property bool controlEnabled: true

    font.family: Typography.fontFamily
    font.pixelSize: Metrics.controlLabelFontSize(size)
    font.weight: Typography.body1.weight
    lineHeight: Metrics.controlLabelLineHeight(size)
    lineHeightMode: Text.FixedHeight
    color: label.gcolors.textPrimary
    opacity: controlEnabled ? 1.0 : 0.6
    verticalAlignment: Text.AlignVCenter
}
