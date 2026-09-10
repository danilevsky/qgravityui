pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit PlaceholderContainer: the empty-state block --
// picture, title, description, a row of buttons.
//
//   size:      GPlaceholderSize.S|M|L (default)|Promo
//   direction: GDirection.Horizontal (default, picture beside the text)
//              | Vertical (picture above it, everything centred)
//   align:     GAlign.Center (default) | Start -- where the body sits inside
//              the container, not how the text is aligned
//   maxWidth:  overrides the body cap the size would pick; 0 keeps it
//
// `actions` is a list of {text, view, size, enabled} objects, same shape as
// Alert's.
Item {
    id: placeholder

    property int size: GPlaceholderSize.L
    property int direction: GDirection.Horizontal
    property int align: GAlign.Center
    property string title: ""
    property string description: ""
    property url image
    property var actions: []
    property real maxWidth: 0

    signal actionTriggered(int index, var action)

    readonly property bool _row: direction === GDirection.Horizontal
    readonly property real _padding: Metrics.placeholderPadding(size, direction)
    readonly property real _bodyCap: maxWidth > 0
                                     ? maxWidth
                                     : Metrics.placeholderBodyMaxWidth(size, direction)

    implicitWidth: 2 * _padding + _bodyCap
    implicitHeight: 2 * _padding + body.height

    Item {
        id: body

        // align-items: center on the container puts the body in the middle;
        // align="left" pulls it back to the padding edge.
        x: placeholder.align === GAlign.Center
           ? Math.round((placeholder.width - width) / 2)
           : placeholder._padding
        y: placeholder._padding
        width: Math.min(placeholder._bodyCap,
                        Math.max(0, placeholder.width - 2 * placeholder._padding))
        height: placeholder._row
                ? Math.max(picture.height, content.implicitHeight,
                           Metrics.placeholderContentMinHeight(placeholder.size))
                : picture.height + (picture.visible ? Metrics.spacing(5) : 0) + content.implicitHeight

        Image {
            id: picture

            // A row sizes the picture by width and a column by height; the
            // other side follows the source's own proportions.
            readonly property real _aspect: implicitWidth > 0 ? implicitHeight / implicitWidth : 1
            readonly property int _cap: Metrics.placeholderImageSize(placeholder.size)

            source: placeholder.image
            fillMode: Image.PreserveAspectFit
            visible: placeholder.image.toString() !== ""
            width: !visible ? 0
                            : (placeholder._row ? _cap : Math.round(_cap / _aspect))
            height: !visible ? 0
                             : (placeholder._row ? Math.round(_cap * _aspect) : _cap)
            x: placeholder._row ? 0 : Math.round((body.width - width) / 2)
            y: placeholder._row ? Math.round((body.height - height) / 2) : 0
        }

        Column {
            id: content

            readonly property real _indent: placeholder._row && picture.visible
                                            ? picture.width + Metrics.placeholderImageGap(placeholder.size)
                                            : 0

            x: _indent
            // justify-content: center inside a body that may be taller than
            // the text, because of the row min-height.
            y: placeholder._row
               ? Math.round((body.height - implicitHeight) / 2)
               : picture.height + (picture.visible ? Metrics.spacing(5) : 0)
            width: body.width - _indent
            spacing: 0

            GText {
                width: parent.width
                visible: placeholder.title !== ""
                variant: Metrics.placeholderTitleVariant(placeholder.size)
                text: placeholder.title
                wrapMode: Text.Wrap
                horizontalAlignment: placeholder._row ? Text.AlignLeft : Text.AlignHCenter
            }

            Item {
                // .g-placeholder-container__description margin-block-start
                width: 1
                height: Metrics.placeholderDescriptionIndent(placeholder.size)
                visible: placeholder.title !== "" && placeholder.description !== ""
            }

            GText {
                width: parent.width
                visible: placeholder.description !== ""
                text: placeholder.description
                wrapMode: Text.Wrap
                horizontalAlignment: placeholder._row ? Text.AlignLeft : Text.AlignHCenter
            }

            Item {
                // .g-placeholder-container__actions margin-block-start
                width: 1
                height: Metrics.spacing(5)
                visible: placeholder.actions.length > 0
            }

            Row {
                visible: placeholder.actions.length > 0
                // .g-placeholder-container__action margin-inline-end
                spacing: Metrics.spacing(5)
                x: placeholder._row ? 0 : Math.round((content.width - width) / 2)

                Repeater {
                    model: placeholder.actions

                    GButton {
                        required property int index
                        required property var modelData

                        text: modelData.text !== undefined ? modelData.text : ""
                        view: modelData.view !== undefined ? modelData.view : GView.Normal
                        size: modelData.size !== undefined ? modelData.size : GSize.M
                        enabled: modelData.enabled !== undefined ? modelData.enabled : true
                        onClicked: placeholder.actionTriggered(index, modelData)
                    }
                }
            }
        }
    }
}
