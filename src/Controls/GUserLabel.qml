import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit UserLabel: an avatar and a name in a pill.
//   size: GSize.Xxxs..Xl -- 16/20/24/28/32/42/50, the Avatar ladder
//   view: GView.Filled (default) | Outlined
//   closable adds the trailing xmark; clickable adds the hover fill
Rectangle {
    id: label

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.S
    property int view: GView.Filled
    property string text: ""
    property string avatarText: ""
    property url avatarSource
    property bool clickable: false
    property bool closable: false

    signal clicked()
    signal closeRequested()

    readonly property int _side: ComponentMetrics.userLabelSize(size)
    readonly property int _gap: ComponentMetrics.userLabelGap(size)
    readonly property int _padding: ComponentMetrics.userLabelPadding(size)

    implicitHeight: _side
    implicitWidth: _side + _gap + text_.implicitWidth
                   + (closable ? _gap + closeIcon.width + _padding : _padding)

    radius: ComponentMetrics.userLabelBorderRadius
    color: clickable && hover.hovered ? label.gcolors.baseSimpleHover : "transparent"
    // .g-user-label_view_outlined::after
    border.width: view === GView.Outlined && !(clickable && hover.hovered) ? 1 : 0
    border.color: label.gcolors.lineGenericSolid

    Behavior on color { ColorAnimation { duration: 100 } }

    HoverHandler {
        id: hover
        enabled: label.clickable
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: label.clickable
        onTapped: label.clicked()
    }

    GAvatar {
        id: avatar

        // .g-user-label__avatar overrides the avatar's own chrome
        anchors.verticalCenter: parent.verticalCenter
        size: label.size
        text: label.avatarText
        imageSource: label.avatarSource
    }

    GText {
        id: text_

        anchors.verticalCenter: parent.verticalCenter
        x: avatar.width + label._gap
        text: label.text
        elide: Text.ElideRight
        font.pixelSize: ComponentMetrics.userLabelTextFontSize(label.size)
        lineHeight: ComponentMetrics.userLabelTextLineHeight(label.size)
        lineHeightMode: Text.FixedHeight
    }

    GIcon {
        id: closeIcon

        visible: label.closable
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: label._padding
        name: "xmark"
        size: 16
        color: closeHover.hovered ? label.gcolors.textPrimary : label.gcolors.textSecondary

        HoverHandler {
            id: closeHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: label.closeRequested()
        }
    }
}
