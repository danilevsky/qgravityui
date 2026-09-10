pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit DefinitionList.
//   items:     [{ term, definition }]
//   direction: GDirection.Horizontal (default) | Vertical
//   termWidth: 300px upstream (--_--term-width)
//
// The dotted leader between term and definition is a CSS dotted border there;
// QML borders have no dash pattern, so it is a row of 1px dots.
Column {
    id: list

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property int direction: GDirection.Horizontal
    property int termWidth: Metrics.definitionTermWidth

    readonly property bool _vertical: direction === GDirection.Vertical

    // --_--item-block-start: 16 horizontal, 12 vertical
    spacing: _vertical ? Metrics.spacing(3) : Metrics.spacing(4)

    Repeater {
        model: list.items

        Item {
            id: entry

            required property var modelData

            width: list.width
            implicitHeight: list._vertical
                            ? verticalBox.implicitHeight
                            : Math.max(term.implicitHeight, definition.implicitHeight)

            // --- horizontal: term, dotted leader, definition ---------------
            GText {
                id: term
                visible: !list._vertical
                colorRole: GTextColor.Secondary
                text: entry.modelData.term !== undefined ? entry.modelData.term : ""
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.top: parent.top
                width: Math.min(implicitWidth, list.termWidth)
            }

            Item {
                id: leader

                visible: !list._vertical
                clip: true
                height: 1
                // .g-definition-list__dots margin: 0 2px, min-width 25px
                anchors.left: term.right
                anchors.leftMargin: 2
                anchors.right: definition.left
                anchors.rightMargin: 2
                anchors.top: term.top
                anchors.topMargin: term.implicitHeight - 3

                Row {
                    spacing: 2
                    Repeater {
                        model: Math.max(0, Math.ceil(leader.width / 3))
                        Rectangle {
                            width: 1
                            height: 1
                            color: list.gcolors.lineGenericActive
                        }
                    }
                }
            }

            GText {
                id: definition
                visible: !list._vertical
                text: entry.modelData.definition !== undefined ? entry.modelData.definition : ""
                elide: Text.ElideRight
                anchors.right: parent.right
                anchors.top: parent.top
                width: Math.min(implicitWidth, parent.width - list.termWidth - 30)
                horizontalAlignment: Text.AlignRight
            }

            // --- vertical: term above definition ---------------------------
            Column {
                id: verticalBox

                visible: list._vertical
                width: parent.width
                // --g-spacing-half
                spacing: 2

                GText {
                    colorRole: GTextColor.Secondary
                    text: entry.modelData.term !== undefined ? entry.modelData.term : ""
                }

                GText {
                    width: parent.width
                    text: entry.modelData.definition !== undefined ? entry.modelData.definition : ""
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
