import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QGravityUI.Core
import QGravityUI.Tokens
import QGravityUI.Controls
import QGravityUI.Navigation

// Demonstrates GNavigationAside driving real SPA-style page switching: the
// aside only ever emits `activated`, and this is the one place that decides
// what a page id means (a Loader source).
ApplicationWindow {
    id: window

    width: 960
    height: 600
    visible: true
    title: "QGravityUI Navigation demo"

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string pageId: "home"

    // {id -> page QML file}. A footer item's id ("theme") is not in here on
    // purpose -- onActivated below tells the two kinds of action apart by
    // whether the id resolves to a page at all.
    readonly property var _pages: ({
        "home": "pages/HomePage.qml",
        "dashboard": "pages/DashboardPage.qml",
        "icons":"pages/IconsPage.qml",
        "orders": "pages/OrdersPage.qml",
        "orders-all": "pages/OrdersPage.qml",
        "orders-pending": "pages/OrdersPage.qml",
        "orders-archived": "pages/OrdersPage.qml",
        "settings": "pages/SettingsPage.qml",
    })

    color: gcolors.baseBackground

    // Dev affordance for the smoke test, mirroring how the gallery reads its
    // own --theme/--scroll flags off Qt.application.arguments in Component.onCompleted.
    Component.onCompleted: {
        const args = Qt.application.arguments;
        if (args.indexOf("--compact") !== -1)
            aside.compact = true;
        const pi = args.indexOf("--page");
        if (pi !== -1 && pi + 1 < args.length)
            window.pageId = args[pi + 1];
        const oi = args.indexOf("--open-orders");
        if (oi !== -1)
            aside._expandedIndex = 2;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        GNavigationAside {
            id: aside

            Layout.fillHeight: true

            logo: ({text: "Acme", iconName: "gift"})
            current: window.pageId

            items: [
                {id: "home", title: "Home", iconName: "house"},
                {id: "dashboard", title: "Dashboard", iconName: "square-bars"},
                {id: "icons", title: "Icons", iconName: "square-bars"},
                {id: "orders", title: "Orders", iconName: "box", items: [
                    {id: "orders-all", title: "All"},
                    {id: "orders-pending", title: "Pending"},
                    {id: "orders-archived", title: "Archived"},
                ]},
                {id: "settings", title: "Settings", iconName: "gear"},
            ]

            footerItems: [
                {id: "theme", iconName: Theme.mode === GThemeMode.Dark ? "sun" : "moon",
                 tooltip: Theme.mode === GThemeMode.Dark ? "Switch to light" : "Switch to dark"},
                {id: "help", iconName: "circle-question", tooltip: "Help"},
            ]

            onActivated: function (id, item) {
                if (id === "theme") {
                    Theme.toggle();
                    return;
                }
                if (id === "help")
                    return;
                window.pageId = id;
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: window.gcolors.baseBackground

            Loader {
                anchors.fill: parent
                anchors.margins: Metrics.spacing(6)
                source: window._pages[window.pageId] !== undefined
                        ? window._pages[window.pageId] : ""
            }
        }
    }
}
