pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Alert.
//   theme: GTheme.Normal (default) | Info | Success | Warning | Danger | Utility
//   view:  GView.Filled (default) | Outlined
//   size:  GSize.S|M|L
//
// Upstream renders a Card with the same theme/view, so the colour table below
// is Card.css's .g-card_theme_* -- the paddings and type scale are Alert.css.
Rectangle {
    id: alert

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int theme: GTheme.Normal
    property int view: GView.Filled
    property int size: GSize.M
    property string title: ""
    property string message: ""
    property bool closable: false
    property var actions: []

    signal closeRequested()
    signal actionTriggered(int index, var action)

    readonly property var _spec: {
        const t = alert.gcolors;
        switch (theme) {
        case GTheme.Info: return {bg: t.baseInfoLight, line: t.lineInfo, icon: "circle-info", fg: t.textInfo};
        case GTheme.Success: return {bg: t.basePositiveLight, line: t.linePositive, icon: "circle-check", fg: t.textPositive};
        case GTheme.Warning: return {bg: t.baseWarningLight, line: t.lineWarning, icon: "triangle-exclamation", fg: t.textWarning};
        case GTheme.Danger: return {bg: t.baseDangerLight, line: t.lineDanger, icon: "circle-xmark", fg: t.textDanger};
        case GTheme.Utility: return {bg: t.baseUtilityLight, line: t.lineUtility, icon: "thunderbolt", fg: t.textUtility};
        // themes normal and clear draw no icon upstream
        default: return {bg: t.baseGeneric, line: t.lineGeneric, icon: "", fg: t.textPrimary};
        }
    }

    // alertSizeToIconSize(): 16 / 18 / 22, its own scale
    readonly property int _iconSize: {
        switch (size) {
        case GSize.S: return 16;
        case GSize.L: return 22;
        default: return 18;
        }
    }

    // AlertIcon switches to the outlined glyph for view="outlined"
    readonly property string _iconName: _spec.icon === ""
                                        ? ""
                                        : _spec.icon + (view === GView.Outlined ? "" : "-fill")

    radius: Metrics.alertRadius(size)
    color: view === GView.Outlined ? "transparent" : _spec.bg
    border.width: view === GView.Outlined ? 1 : 0
    border.color: _spec.line

    implicitWidth: 320
    implicitHeight: column.implicitHeight + 2 * Metrics.alertVerticalPadding(size)

    GIcon {
        id: themeIcon

        visible: alert._iconName !== ""
        name: alert._iconName
        size: alert._iconSize
        color: alert._spec.fg
        x: Metrics.alertHorizontalPadding(alert.size)
        // .g-alert_align_baseline puts the icon on the first text line, one
        // pixel up (.g-alert__icon-wrapper_align_baseline).
        y: Metrics.alertVerticalPadding(alert.size) - 1
           + Math.round((alert._firstLineHeight - height) / 2)
    }

    readonly property int _firstLineHeight: Typography.token(
        title !== "" ? Metrics.alertTitleVariant(size)
                     : Metrics.alertMessageVariant(size)).lineHeight

    Column {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Metrics.alertHorizontalPadding(alert.size)
                            + (themeIcon.visible ? themeIcon.width + Metrics.alertIconGap(alert.size) : 0)
        anchors.rightMargin: Metrics.alertHorizontalPadding(alert.size)
                             + (alert.closable ? closeButton.width + Metrics.alertCloseMargin(alert.size) : 0)
        anchors.topMargin: Metrics.alertVerticalPadding(alert.size)
        spacing: 0

        GText {
            width: parent.width
            visible: alert.title !== ""
            variant: Metrics.alertTitleVariant(alert.size)
            text: alert.title
            wrapMode: Text.Wrap
        }

        Item {
            // .g-alert__message_with-top-margin
            width: 1
            height: Metrics.alertTitleIndent(alert.size)
            visible: alert.title !== "" && alert.message !== ""
        }

        GText {
            width: parent.width
            visible: alert.message !== ""
            variant: Metrics.alertMessageVariant(alert.size)
            text: alert.message
            wrapMode: Text.Wrap
        }

        Item {
            // .g-alert__main gap between the text block and the actions
            width: 1
            height: alert.size === GSize.S ? Metrics.spacing(2) : Metrics.spacing(5)
            visible: alert.actions.length > 0
        }

        Flow {
            width: parent.width
            visible: alert.actions.length > 0
            // .g-alert__actions gap
            spacing: Metrics.spacing(3)

            Repeater {
                model: alert.actions

                GButton {
                    required property int index
                    required property var modelData

                    text: modelData.text !== undefined ? modelData.text : ""
                    view: modelData.view !== undefined ? modelData.view : GView.Normal
                    size: alert.size === GSize.L ? GSize.L : GSize.M
                    onClicked: alert.actionTriggered(index, modelData)
                }
            }
        }
    }

    GButton {
        id: closeButton

        visible: alert.closable
        view: GView.Flat
        size: alert.size === GSize.L ? GSize.L : GSize.M
        icon.name: "xmark"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Metrics.alertHorizontalPadding(alert.size)
        anchors.topMargin: Metrics.alertVerticalPadding(alert.size)
        onClicked: alert.closeRequested()
    }
}
