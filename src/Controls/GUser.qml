import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit User: an avatar with a name and a description.
//   size: GSize.Xxxs..Xl -- drives both the avatar and the gap (6 / 8 / 12)
Row {
    id: user

    property int size: GSize.M
    property string name: ""
    property string description: ""
    property string avatarText: ""
    property url avatarSource

    spacing: Metrics.userGap(size)

    GAvatar {
        anchors.verticalCenter: parent.verticalCenter
        size: user.size
        text: user.avatarText
        imageSource: user.avatarSource
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        GText {
            // .g-user__name: body-short everywhere but xl
            variant: user.size === GSize.Xl ? GVariant.Body2 : GVariant.BodyShort
            text: user.name
            elide: Text.ElideRight
        }

        GText {
            visible: user.description !== ""
            variant: GVariant.BodyShort
            colorRole: GTextColor.Secondary
            text: user.description
            elide: Text.ElideRight
        }
    }
}
