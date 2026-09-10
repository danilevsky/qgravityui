import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Divider.
//   orientation: GDirection.Horizontal (default) | Vertical
//   text:        optional label; the line is split around it, gap 8px
//   align:       GAlign.Center (default) | Start | End -- which half of the line is
//                dropped, so the label sits flush against that edge
Item {
    id: divider

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int orientation: GDirection.Horizontal
    property int align: GAlign.Center
    property string text: ""
    property color lineColor: divider.gcolors.lineGeneric

    // --g-divider-size
    readonly property int lineSize: 1
    // .g-divider --_--content-gap
    readonly property int contentGap: 8

    readonly property bool _vertical: orientation === GDirection.Vertical
    readonly property bool _labelled: text !== ""

    implicitWidth: _vertical
                   ? (_labelled ? Math.max(lineSize, vLabel.implicitWidth) : lineSize)
                   : (_labelled ? hLabel.implicitWidth + 2 * contentGap : 0)
    implicitHeight: _vertical
                    ? (_labelled ? vLabel.implicitHeight + 2 * contentGap : 0)
                    : (_labelled ? hLabel.implicitHeight : lineSize)

    Item {
        anchors.fill: parent
        visible: !divider._vertical

        GText {
            id: hLabel
            visible: divider._labelled
            text: divider.text
            anchors.verticalCenter: parent.verticalCenter
            // Set as x rather than three conditional anchors: qmllint rejects
            // left + right + horizontalCenter on one item even when only one
            // of them is ever bound.
            x: divider.align === GAlign.Start
               ? 0
               : (divider.align === GAlign.End
                  ? Math.max(0, parent.width - width)
                  : Math.round((parent.width - width) / 2))
        }

        Rectangle {
            // ::before -- hidden by .g-divider_align_start
            visible: divider.align !== GAlign.Start || !divider._labelled
            color: divider.lineColor
            height: divider.lineSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: divider._labelled ? hLabel.left : parent.right
            anchors.rightMargin: divider._labelled ? divider.contentGap : 0
        }

        Rectangle {
            // ::after -- hidden by .g-divider_align_end
            visible: divider._labelled && divider.align !== GAlign.End
            color: divider.lineColor
            height: divider.lineSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: hLabel.right
            anchors.leftMargin: divider.contentGap
            anchors.right: parent.right
        }
    }

    Item {
        anchors.fill: parent
        visible: divider._vertical

        GText {
            id: vLabel
            visible: divider._labelled
            text: divider.text
            anchors.horizontalCenter: parent.horizontalCenter
            y: divider.align === GAlign.Start
               ? 0
               : (divider.align === GAlign.End
                  ? Math.max(0, parent.height - height)
                  : Math.round((parent.height - height) / 2))
        }

        Rectangle {
            visible: divider.align !== GAlign.Start || !divider._labelled
            color: divider.lineColor
            width: divider.lineSize
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: divider._labelled ? vLabel.top : parent.bottom
            anchors.bottomMargin: divider._labelled ? divider.contentGap : 0
        }

        Rectangle {
            visible: divider._labelled && divider.align !== GAlign.End
            color: divider.lineColor
            width: divider.lineSize
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: vLabel.bottom
            anchors.topMargin: divider.contentGap
            anchors.bottom: parent.bottom
        }
    }
}
