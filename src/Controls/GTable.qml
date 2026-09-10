pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Table.
//   columns: [{ id, name, width, align }]  align: start (default) | center | end
//   rows:    array of objects keyed by column id
//
// Table.css: cells are 11px/10px vertical and --g-spacing-2 inline, with the
// first and last column giving up their outer padding; the head row is the
// accent weight; the last body row's rule is transparent.
//
// Not ported: sorting, selection, sticky columns and the shadowed horizontal
// scrollbar -- those are Table's own machinery rather than its look.
Column {
    id: table

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var columns: []
    property var rows: []
    property bool interactive: false

    signal rowClicked(int index, var row)

    spacing: 0

    function _cellX(index) {
        let x = 0;
        for (let i = 0; i < index; ++i)
            x += table.columns[i].width;
        return x;
    }

    // .g-table__cell:first-child / :last-child drop the outer padding
    function _padding(index: int, leading: bool): int {
        if (leading && index === 0)
            return 0;
        if (!leading && index === table.columns.length - 1)
            return 0;
        return Metrics.spacing(2);
    }

    function _alignment(column) {
        switch (column.align) {
        case GAlign.Center: return Text.AlignHCenter;
        case GAlign.End: return Text.AlignRight;
        default: return Text.AlignLeft;
        }
    }

    // --- head ---------------------------------------------------------
    Item {
        width: table.width
        height: Metrics.tableCellPaddingTop + Metrics.tableCellLineHeight
                + Metrics.tableCellPaddingBottom

        Repeater {
            model: table.columns

            GText {
                required property int index
                required property var modelData

                x: table._cellX(index) + table._padding(index, true)
                y: Metrics.tableCellPaddingTop
                width: modelData.width - table._padding(index, true)
                        - table._padding(index, false)
                text: modelData.name !== undefined ? modelData.name : ""
                // .g-table__head .g-table__cell font-weight: accent
                font.weight: Font.DemiBold
                horizontalAlignment: table._alignment(modelData)
                elide: Text.ElideRight
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: table.gcolors.lineGeneric
        }
    }

    // --- body ---------------------------------------------------------
    Repeater {
        model: table.rows

        Item {
            id: row

            required property int index
            required property var modelData

            width: table.width
            height: Metrics.tableCellPaddingTop + Metrics.tableCellLineHeight
                    + Metrics.tableCellPaddingBottom

            Rectangle {
                anchors.fill: parent
                // .g-table__row_interactive:hover
                visible: table.interactive && hover.hovered
                color: table.gcolors.baseSimpleHoverSolid
            }

            Repeater {
                model: table.columns

                GText {
                    required property int index
                    required property var modelData

                    x: table._cellX(index) + table._padding(index, true)
                    y: Metrics.tableCellPaddingTop
                    width: modelData.width - table._padding(index, true)
                            - table._padding(index, false)
                    text: {
                        const key = modelData.id;
                        const value = row.modelData[key];
                        return value === undefined ? "" : String(value);
                    }
                    horizontalAlignment: table._alignment(modelData)
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                // The last row's rule is cleared upstream
                color: row.index === table.rows.length - 1
                       ? "transparent"
                       : table.gcolors.lineGeneric
            }

            HoverHandler {
                id: hover
                enabled: table.interactive
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                enabled: table.interactive
                onTapped: table.rowClicked(row.index, row.modelData)
            }
        }
    }
}
