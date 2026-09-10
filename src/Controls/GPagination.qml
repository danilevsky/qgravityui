pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Pagination.
//   size: GSize.S|M|L|Xl -- passed straight to the page buttons
//
// PaginationPage picks view="normal" for the current page and "flat" for the
// rest; the arrows are ChevronLeft / ChevronRight at 16px.
Row {
    id: pagination

    property int size: GSize.M
    property int page: 1
    property int pageCount: 1
    // How many numbered pages to show around the current one.
    property int visiblePages: 5

    signal pageRequested(int page)

    // .g-pagination__pagination-item margin-inline-end
    spacing: Metrics.paginationGap

    readonly property var _pages: {
        const total = Math.max(1, pageCount);
        const span = Math.max(1, visiblePages);
        let first = Math.max(1, page - Math.floor(span / 2));
        const last = Math.min(total, first + span - 1);
        first = Math.max(1, last - span + 1);

        const result = [];
        if (first > 1) {
            result.push(1);
            if (first > 2)
                result.push(0); // 0 marks the ellipsis
        }
        for (let i = first; i <= last; ++i)
            result.push(i);
        if (last < total) {
            if (last < total - 1)
                result.push(0);
            result.push(total);
        }
        return result;
    }

    GButton {
        view: GView.Flat
        size: pagination.size
        icon.name: "chevron-left"
        enabled: pagination.page > 1
        onClicked: pagination.pageRequested(pagination.page - 1)
    }

    Repeater {
        model: pagination._pages

        Item {
            id: cell

            required property int modelData

            width: cell.modelData === 0 ? ellipsis.implicitWidth : button.implicitWidth
            height: Metrics.heightForSize(pagination.size)

            GText {
                id: ellipsis
                anchors.centerIn: parent
                visible: cell.modelData === 0
                colorRole: GTextColor.Secondary
                text: "…"
                leftPadding: Metrics.spacing(1)
                rightPadding: Metrics.spacing(1)
            }

            GButton {
                id: button
                anchors.centerIn: parent
                visible: cell.modelData !== 0
                size: pagination.size
                view: cell.modelData === pagination.page ? GView.Normal : GView.Flat
                text: cell.modelData === 0 ? "" : String(cell.modelData)
                onClicked: pagination.pageRequested(cell.modelData)
            }
        }
    }

    GButton {
        view: GView.Flat
        size: pagination.size
        icon.name: "chevron-right"
        enabled: pagination.page < pagination.pageCount
        onClicked: pagination.pageRequested(pagination.page + 1)
    }
}
