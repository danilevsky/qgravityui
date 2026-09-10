pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit FilePreview: one file as a tile -- a thumbnail
// or a type-coloured icon, the name under it, and a row of round action
// buttons that fade in on hover.
//
//   fileName / description
//   fileType: GFileType.Default | Image | Video | Code | Archive | Music
//             | Audio | Text | Pdf | Table
//   imageSource: a thumbnail; when set it replaces the icon
//   view: GView.Normal (default, 120px wide with a caption) | Clear for
//         upstream's `compact` -- a bare 48x48 square
//   selected: the brand outline
//   actions: [{icon, title, enabled}] -- 24px raised circles at the top
//            right corner
//
// Upstream reads the MIME type off a File object and picks the icon from it.
// There is no File here, so `fileType` is passed in; the mapping table it
// replaces is a hundred MIME strings long and belongs to whatever produced
// the file, not to the view.
Item {
    id: preview

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string fileName: ""
    property string description: ""
    property int fileType: GFileType.Default
    property url imageSource
    property int view: GView.Normal
    property bool selected: false
    property bool clickable: false
    property var actions: []

    signal clicked()
    signal actionTriggered(int index, var action)

    readonly property bool _compact: view === GView.Clear
    readonly property bool _hasImage: imageSource.toString() !== ""

    implicitWidth: _compact ? 48 : 120
    implicitHeight: _compact ? 48 : card.implicitHeight

    // .g-file-preview__icon background-color, by file kind
    readonly property color _iconFill: {
        const t = preview.gcolors;
        switch (fileType) {
        case GFileType.Image:
        case GFileType.Video:
        case GFileType.Code:
        case GFileType.Archive:
        case GFileType.Music:
        case GFileType.Audio:
            return t.baseMiscHeavy;
        case GFileType.Text: return t.baseInfoHeavy;
        case GFileType.Pdf: return t.baseDangerMedium;
        case GFileType.Table: return t.basePositiveMedium;
        default: return t.baseGenericMedium;
        }
    }

    readonly property string _iconName: {
        switch (fileType) {
        case GFileType.Image: return "picture";
        case GFileType.Video: return "filmstrip";
        case GFileType.Code: return "code";
        case GFileType.Archive: return "file-zipper";
        case GFileType.Music:
        case GFileType.Audio: return "music-note";
        case GFileType.Text: return "text-align-left";
        case GFileType.Pdf: return "logo-acrobat";
        case GFileType.Table: return "layout-header-cells-large";
        default: return "file-question";
        }
    }

    HoverHandler {
        id: hover
    }

    Rectangle {
        id: card

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        // .g-file-preview__card padding: 4px 10px, and 4px all round compact
        readonly property int hPadding: preview._compact ? 4 : 10
        readonly property int vPadding: 4

        height: preview._compact ? preview.height : implicitHeight
        implicitHeight: 2 * vPadding + thumb.height
                        + (preview._compact ? 0 : caption.implicitHeight + 4)

        radius: 8
        // Only a tile that does something reacts to the pointer.
        color: !preview.selected && (preview.clickable || preview.actions.length > 0)
               && (hover.hovered || preview.activeFocus)
               ? preview.gcolors.baseSimpleHover
               : "transparent"
        border.width: preview.selected ? 1 : 0
        border.color: preview.gcolors.lineBrand

        TapHandler {
            enabled: preview.clickable
            onTapped: preview.clicked()
        }

        // .g-file-preview__icon-container / __image-container: 96x64, or the
        // whole card in the compact view.
        Item {
            id: thumb

            x: Math.round((card.width - width) / 2)
            y: card.vPadding
            width: preview._compact ? card.width - 2 * card.hPadding : 96
            height: preview._compact ? card.height - 2 * card.vPadding : 64

            Rectangle {
                id: iconBox

                visible: !preview._hasImage
                anchors.centerIn: parent
                // 40x40 in the default view; the compact tile has the icon
                // fill the whole card instead.
                width: preview._compact ? parent.width : 40
                height: preview._compact ? parent.height : 40
                radius: 4
                color: preview._iconFill

                GIcon {
                    anchors.centerIn: parent
                    name: preview._iconName
                    size: 20
                    color: preview.gcolors.baseBackground
                }
            }

            Rectangle {
                visible: preview._hasImage
                anchors.fill: parent
                radius: 4
                clip: true
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: preview.imageSource
                    // object-fit: cover
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(width * Screen.devicePixelRatio,
                                        height * Screen.devicePixelRatio)
                }
            }
        }

        Column {
            id: caption

            visible: !preview._compact
            x: card.hPadding
            y: card.vPadding + thumb.height + 4
            width: card.width - 2 * card.hPadding
            spacing: 0

            GText {
                width: parent.width
                colorRole: GTextColor.Secondary
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: preview.fileName
            }

            GText {
                width: parent.width
                visible: preview.description !== ""
                colorRole: GTextColor.Secondary
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: preview.description
            }
        }
    }

    // .g-file-preview-actions-desktop: outside the card's top-right corner,
    // invisible until the tile is hovered or focused.
    Row {
        id: actionsRow

        visible: preview.actions.length > 0
        x: preview.width - width + 12
        y: -12
        z: 1
        spacing: Metrics.spacing(1)

        opacity: hover.hovered || preview.activeFocus ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Repeater {
            model: preview.actions

            GButton {
                id: actionButton

                required property int index
                required property var modelData

                width: 24
                height: 24
                size: GSize.S
                view: GView.Raised
                // pin="circle-circle"
                cornerRadius: 12
                icon.name: actionButton.modelData.icon !== undefined ? actionButton.modelData.icon : ""
                enabled: actionButton.modelData.enabled !== undefined ? actionButton.modelData.enabled : true
                onClicked: preview.actionTriggered(actionButton.index, actionButton.modelData)

                GActionTooltip {
                    title: actionButton.modelData.title !== undefined ? actionButton.modelData.title : ""
                    active: title !== ""
                }
            }
        }
    }
}
