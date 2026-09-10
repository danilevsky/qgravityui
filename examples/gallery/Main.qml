import QtQuick
import QGravityUI.Core
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QGravityUI.Tokens
import QGravityUI.Controls

ApplicationWindow {
    id: window
    // Read before the window is shown, not in Component.onCompleted: a window
    // created larger than the screen never gets a frame -- at 2x scaling the
    // default 1180x900 is 2950x2250 physical -- and then nothing renders and
    // no screenshot ever completes.
    function intArgument(name: string, fallback: int): int {
        const args = Qt.application.arguments;
        const i = args.indexOf(name);
        return (i !== -1 && i + 1 < args.length) ? parseInt(args[i + 1], 10) : fallback;
    }

    width: intArgument("--width", 1180)
    height: intArgument("--height", 900)
    visible: true
    title: "QGravityUI demo"
    color: Theme.colors.baseBackground

    // Dev affordance: `qgravityui_gallery --shot <file.png> [--theme dark] [--height N] [--scroll Y]` renders the
    // gallery once, writes a PNG and exits. This is what the phase 4 visual
    // regression pass drives; it is inert without the flag.
    Component.onCompleted: {
        const args = Qt.application.arguments;
        const ti = args.indexOf("--theme");
        if (ti !== -1 && ti + 1 < args.length)
            Theme.mode = window.themeModeFromName(args[ti + 1]);
        const ci = args.indexOf("--scroll");
        if (ci !== -1 && ci + 1 < args.length)
            window.scrollTo = parseInt(args[ci + 1], 10);
        const pi = args.indexOf("--probe");
        if (pi !== -1)
            probeTimer.start();
        // The toaster lives inside `root`, so unlike the popups it does show
        // up in a screenshot.
        if (args.indexOf("--toast") !== -1) {
            toaster.add({title: "Deployed", content: "Build 412 is live.", theme: GTheme.Success, timeout: 0});
            toaster.add({title: "Quota warning", content: "82% of the storage quota is used.", theme: GTheme.Warning, timeout: 0});
            toaster.add({content: "A toast with no title.", timeout: 0});
        }
        // `--tab N` (handled in main.cpp) posts real Tab presses; this reports
        // where focus landed, so the ring can be checked without a human.
        if (args.indexOf("--tab") !== -1)
            focusProbe.start();
        // Opens one overlay so `--shot-window` has something to capture.
        // Deferred: a popup parented to the window overlay has nothing to
        // size itself against until the overlay itself exists.
        const oi = args.indexOf("--open");
        if (oi !== -1 && oi + 1 < args.length) {
            openTimer.which = args[oi + 1];
            openTimer.start();
        }
        const si = args.indexOf("--shot");
        if (si !== -1 && si + 1 < args.length) {
            shotTimer.path = args[si + 1];
            shotTimer.start();
        }
    }

    Timer {
        id: shotTimer
        property string path
        interval: 1200
        onTriggered: {
            const started = root.grabToImage(function (result) {
                result.saveToFile(path);
                Qt.exit(0);
            });
            // A window larger than the screen never renders, and then the
            // grab silently never completes -- worth saying out loud.
            if (!started)
                console.warn("--shot: grabToImage refused",
                             root.width + "x" + root.height,
                             "dpr=" + Screen.devicePixelRatio);
        }
    }

    // Popups render in the window overlay, which grabToImage(root) cannot see,
    // so `--probe` checks their geometry numerically instead of by pixels.
    Timer {
        id: probeTimer
        interval: 600
        onTriggered: {
            function report(name, popup) {
                console.log(name, "opened=" + popup.opened,
                            "x=" + Math.round(popup.x), "y=" + Math.round(popup.y),
                            "w=" + Math.round(popup.width), "h=" + Math.round(popup.height));
            }
            menuDemo.open();
            popoverDemo.open();
            dialogDemo.open();
            drawerDemo.open();
            sheetDemo.open();
            // Report a beat later: open() starts a transition, and the popup
            // is not laid out until it has run.
            probeReport.callback = function () {
                report("menu", menuDemo);
                report("popover", popoverDemo);
                report("dialog", dialogDemo);
                report("drawer", drawerDemo);
                report("sheet", sheetDemo);
                Qt.exit(0);
            };
            probeReport.start();
        }
    }

    Timer {
        id: probeReport
        property var callback
        interval: 400
        onTriggered: callback()
    }

    // The command line still speaks the upstream names; the property does not.
    function themeModeFromName(name: string): int {
        switch (name) {
        case "dark": return GThemeMode.Dark;
        case "light-hc": return GThemeMode.LightHc;
        case "dark-hc": return GThemeMode.DarkHc;
        default: return GThemeMode.Light;
        }
    }

    Timer {
        id: openTimer
        property string which
        interval: 300
        onTriggered: {
            switch (which) {
            case "menu": menuDemo.open(); break;
            case "popover": popoverDemo.open(); break;
            case "dialog": dialogDemo.open(); break;
            case "drawer": drawerDemo.open(); break;
            case "sheet": sheetDemo.open(); break;
            default: console.log("--open: unknown overlay", which); break;
            }
        }
    }

    Timer {
        id: focusProbe
        interval: 800
        onTriggered: {
            const item = window.activeFocusItem;
            console.log("focus:", item ? item.toString() : "none",
                        "keyboardNavigation=" + GInputMode.keyboardNavigation);
        }
    }

    // --scroll, as a binding rather than a one-off assignment: the gallery's
    // content height is still growing while the delegates lay out, and a
    // value written once would be clamped against a height that is not final
    // yet -- "scroll to the end" would stop on the first screen.
    property int scrollTo: -1

    Binding {
        target: scroller.contentItem
        property: "contentY"
        when: window.scrollTo >= 0
        value: Math.max(0, Math.min(window.scrollTo,
                                    scroller.contentHeight - scroller.availableHeight))
    }

    // Inline SVG for the GIcon demo -- upstream would import this from
    // @gravity-ui/icons, which we do not bundle.
    readonly property string demoStarSvg:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">' +
        '<path d="M8 1l2.1 4.6 5 .6-3.7 3.4 1 4.9L8 12.1 3.6 14.5l1-4.9L.9 6.2l5-.6z"/></svg>'

    Rectangle {
        id: root
        anchors.fill: parent
        color: Theme.colors.baseBackground

        GDrawer {
            id: drawerDemo
            panelSize: 360

            GText {
                anchors.fill: parent
                anchors.margins: Metrics.spacing(5)
                wrapMode: Text.Wrap
                text: "Drawer, 360px from the left edge, sliding over the veil in 300ms."
            }
        }

        GSheet {
            id: sheetDemo
            title: "Bottom sheet"

            GText {
                width: parent.width
                wrapMode: Text.Wrap
                text: "Full width, hugging its content, rounded 20px on the top corners " +
                      "because the top bar is there."
            }
            GButton {
                text: "Close"
                view: GView.Action
                onClicked: sheetDemo.close()
            }
        }

        GDialog {
            id: dialogDemo
            size: GSize.S
            title: "Delete the environment?"
            actions: [{text: "Delete", view: GView.Action}, {text: "Cancel", view: GView.Flat}]
            onActionTriggered: dialogDemo.close()

            GText {
                width: parent.width
                wrapMode: Text.Wrap
                text: "This removes the environment and every deployment in it. " +
                      "The action cannot be undone."
            }
        }


    ScrollView {
        id: scroller
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: window.width
            spacing: Metrics.spacing(5)


            Item { Layout.preferredHeight: Metrics.spacing(1) }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)
                spacing: Metrics.spacing(3)

                GText {
                    Layout.fillWidth: true
                    variant: GVariant.Header1
                    text: "QGravityUI"
                }
                GSwitch {
                    text: Theme.mode === GThemeMode.Dark ? "Dark" : "Light"
                    checked: Theme.mode === GThemeMode.Dark
                    onToggled: Theme.toggle()
                }

                GSwitch {
                    text: Theme.mode === GThemeMode.DarkHc ? "DarkHc" : "LightHc"
                    checked: Theme.mode === GThemeMode.DarkHc
                    onToggled: Theme.toggle()
                }

                GButton {
                    text: "Set DarkHC"
                    onClicked: Theme.mode = GThemeMode.DarkHc
                }

                GButton {
                    text: "Set LightHc"
                    onClicked: Theme.mode = GThemeMode.LightHc
                }

                GButton {
                    text: "Set Dark"
                    onClicked: Theme.mode = GThemeMode.Dark
                }

                GButton {
                    text: "Set Light"
                    onClicked: Theme.mode = GThemeMode.Light
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "Theme scopes" }
                    GText {
                        Layout.fillWidth: true
                        variant: GVariant.BodyShort
                        colorRole: GTextColor.Secondary
                        wrapMode: Text.Wrap
                        text: "GThemeScope.mode overrides the theme for one subtree, the way " +
                              "ThemeProvider does upstream. The switches above keep driving " +
                              "everything that has no scope of its own."
                    }

                    GFlex {
                        Layout.fillWidth: true
                        gap: 3

                        Repeater {
                            model: [{name: "Light", mode: GThemeMode.Light},
                                    {name: "Dark", mode: GThemeMode.Dark},
                                    {name: "LightHc", mode: GThemeMode.LightHc},
                                    {name: "DarkHc", mode: GThemeMode.DarkHc}]

                            Rectangle {
                                id: scopeCard

                                required property var modelData

                                GThemeScope.mode: scopeCard.modelData.mode

                                readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

                                implicitWidth: scopeBody.implicitWidth + Metrics.spacing(6)
                                implicitHeight: scopeBody.implicitHeight + Metrics.spacing(6)
                                radius: Metrics.radiusM
                                color: gcolors.baseBackground
                                border.width: 1
                                border.color: gcolors.lineGeneric

                                ColumnLayout {
                                    id: scopeBody
                                    anchors.centerIn: parent
                                    spacing: Metrics.spacing(2)

                                    GText { variant: GVariant.Subheader1; text: scopeCard.modelData.name }
                                    GButton { text: "Action"; view: GView.Action }
                                    GCheckbox { text: "Checked"; checked: true }
                                    GLabel { theme: GTheme.Info; content: "label" }
                                }
                            }
                        }

                        // A scope inside a scope: the inner one wins for its own
                        // subtree, and everything between the two follows the outer.
                        Rectangle {
                            GThemeScope.mode: GThemeMode.Dark

                            readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

                            implicitWidth: nestedBody.implicitWidth + Metrics.spacing(6)
                            implicitHeight: nestedBody.implicitHeight + Metrics.spacing(6)
                            radius: Metrics.radiusM
                            color: gcolors.baseBackground
                            border.width: 1
                            border.color: gcolors.lineGeneric

                            ColumnLayout {
                                id: nestedBody
                                anchors.centerIn: parent
                                spacing: Metrics.spacing(2)

                                GText { variant: GVariant.Subheader1; text: "Dark" }
                                GButton { text: "Outer" }

                                Rectangle {
                                    GThemeScope.mode: GThemeMode.Light

                                    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

                                    Layout.fillWidth: true
                                    implicitWidth: inner.implicitWidth + Metrics.spacing(4)
                                    implicitHeight: inner.implicitHeight + Metrics.spacing(4)
                                    radius: Metrics.radiusM
                                    color: gcolors.baseBackground

                                    GButton {
                                        id: inner
                                        anchors.centerIn: parent
                                        text: "Inner light"
                                    }
                                }
                            }
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Label" }
                    GFlex {
                        Layout.fillWidth: true
                        gap: 2
                        Repeater {
                            model: [{name: "normal", theme: GTheme.Normal},
                                    {name: "success", theme: GTheme.Success},
                                    {name: "info", theme: GTheme.Info},
                                    {name: "warning", theme: GTheme.Warning},
                                    {name: "danger", theme: GTheme.Danger},
                                    {name: "utility", theme: GTheme.Utility},
                                    {name: "unknown", theme: GTheme.Unknown},
                                    {name: "clear", theme: GTheme.Clear}]
                            GLabel {
                                required property var modelData
                                theme: modelData.theme
                                content: modelData.name
                            }
                        }
                        GLabel { theme: GTheme.Info; content: "key"; value: "value" }
                        GLabel { theme: GTheme.Danger; content: "closable"; closable: true }
                        GLabel { theme: GTheme.Success; content: "interactive"; interactive: true }
                        GLabel { content: "disabled"; enabled: false }
                    }
                    GFlex {
                        Layout.fillWidth: true
                        gap: 2
                        Repeater {
                            model: [{name: "xxs", size: GSize.Xxs, px: "18"},
                                    {name: "xs", size: GSize.Xs, px: "20"},
                                    {name: "s", size: GSize.S, px: "24"},
                                    {name: "m", size: GSize.M, px: "28"}]
                            GLabel {
                                required property var modelData
                                size: modelData.size
                                content: "size " + modelData.name
                                value: modelData.px
                            }
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Spin / Loader / Icon / Link" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)

                        Row {
                            spacing: Metrics.spacing(3)
                            Repeater {
                                model: [GSize.Xs, GSize.S, GSize.M, GSize.L, GSize.Xl]
                                GSpin {
                                    required property int modelData
                                    size: modelData
                                }
                            }
                        }

                        Row {
                            spacing: Metrics.spacing(4)
                            Repeater {
                                model: [GSize.S, GSize.M, GSize.L]
                                GLoader {
                                    required property int modelData
                                    size: modelData
                                }
                            }
                        }

                        Row {
                            spacing: Metrics.spacing(3)
                            GIcon { svg: window.demoStarSvg; size: 16 }
                            GIcon { svg: window.demoStarSvg; size: 24 }
                            GIcon { svg: window.demoStarSvg; size: 24; color: Theme.colors.textDanger }
                        }

                        Column {
                            spacing: Metrics.spacing(1)
                            GLink { text: "normal link" }
                            GLink { text: "underlined"; underline: true }
                            GLink { text: "secondary"; view: GLinkView.Secondary }
                            GLink { text: "visited"; visited: true }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Skeleton" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GSkeleton { Layout.fillWidth: true; size: GSize.M }
                        GSkeleton { size: GSize.L; variant: GShape.Circle }
                        GSkeleton { size: GSize.L; variant: GShape.Square }
                        GSkeleton { Layout.preferredWidth: 160; size: GSize.S; animation: GAnimation.Pulse }
                    }

                    GText { variant: GVariant.Subheader2; text: "Divider" }
                    GDivider { Layout.fillWidth: true }
                    GDivider { Layout.fillWidth: true; text: "centered" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GDivider { Layout.fillWidth: true; text: "align start"; align: GAlign.Start }
                        GDivider { Layout.fillWidth: true; text: "align end"; align: GAlign.End }
                        GDivider { Layout.preferredHeight: 24; orientation: GDirection.Vertical }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "Avatar (16 / 20 / 24 / 28 / 32 / 42 / 50) and User" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)

                        Row {
                            spacing: Metrics.spacing(2)
                            Repeater {
                                model: [GSize.Xxxs, GSize.Xxs, GSize.Xs, GSize.S,
                                        GSize.M, GSize.L, GSize.Xl]
                                GAvatar {
                                    required property int modelData
                                    anchors.verticalCenter: parent.verticalCenter
                                    size: modelData
                                    text: "AB"
                                }
                            }
                        }

                        Row {
                            spacing: Metrics.spacing(2)
                            GAvatar { shape: GShape.Square; text: "SQ" }
                            GAvatar { view: GView.Outlined; text: "OL" }
                            GAvatar { theme: GTheme.Brand; text: "BR" }
                            GAvatar { theme: GTheme.Brand; view: GView.Outlined; text: "BO" }
                            GAvatar { iconName: "person" }
                        }

                        GUser {
                            name: "Ada Lovelace"
                            description: "ada@example.org"
                            avatarText: "AL"
                        }

                        GUser {
                            size: GSize.Xl
                            name: "Size xl"
                            description: "body-2 name, 12px gap"
                            avatarText: "XL"
                        }

                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Progress (4 / 10 / 20)" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GProgress { Layout.fillWidth: true; size: GSize.Xs; value: 30 }
                        GProgress { Layout.fillWidth: true; size: GSize.S; value: 55; theme: GTheme.Info }
                        GProgress { Layout.fillWidth: true; value: 70; text: "70%" }
                        GProgress { Layout.fillWidth: true; value: 45; theme: GTheme.Success; loading: true }
                        GProgress { Layout.fillWidth: true; value: 90; theme: GTheme.Danger; text: "90%" }
                    }

                    GText { variant: GVariant.Subheader2; text: "Breadcrumbs / Tabs" }
                    GBreadcrumbs {
                        items: [{text: "Home"}, {text: "Projects"}, {text: "QGravityUI"}]
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)
                        Repeater {
                            model: [GSize.M, GSize.L, GSize.Xl]
                            GTabs {
                                required property int modelData
                                size: modelData
                                value: "overview"
                                items: [{id: "overview", title: "Overview"},
                                        {id: "issues", title: "Issues", counter: "12"},
                                        {id: "wiki", title: "Wiki", disabled: true}]
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Disclosure / DefinitionList" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)

                        ColumnLayout {
                            Layout.preferredWidth: 320
                            spacing: Metrics.spacing(3)
                            GDisclosure {
                                Layout.fillWidth: true
                                summary: "Collapsed by default"
                                GText { text: "Hidden until the chevron turns." }
                            }
                            GDisclosure {
                                Layout.fillWidth: true
                                size: GSize.L
                                summary: "Expanded, size l"
                                expanded: true
                                GText { text: "The body fades in over 200ms." }
                            }
                        }

                        GDefinitionList {
                            Layout.fillWidth: true
                            termWidth: 200
                            items: [{term: "Version", definition: "7.49.0"},
                                    {term: "Tokens", definition: "130 x 4 themes"},
                                    {term: "Icons", definition: "799"}]
                        }

                        GDefinitionList {
                            Layout.preferredWidth: 220
                            direction: GDirection.Vertical
                            items: [{term: "Vertical", definition: "term above definition"},
                                    {term: "Gap", definition: "12px between items"}]
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Pagination / Table" }
                    GPagination {
                        id: paginationDemo
                        page: 4
                        pageCount: 42
                        onPageRequested: function (p) { paginationDemo.page = p; }
                    }
                    GTable {
                        Layout.fillWidth: true
                        interactive: true
                        columns: [{id: "name", name: "Component", width: 220},
                                  {id: "tier", name: "Tier", width: 90},
                                  {id: "views", name: "Views", width: 90, align: GAlign.End},
                                  {id: "note", name: "Note", width: 320}]
                        rows: [{name: "GButton", tier: "1", views: 21, note: "Full view table"},
                               {name: "GSelect", tier: "2", views: 2, note: "Single choice only"},
                               {name: "GTable", tier: "3", views: 1, note: "No sorting or sticky columns"}]
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "ArrowToggle / Hotkey / HelpMark / AvatarStack" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)

                        Row {
                            spacing: Metrics.spacing(3)
                            GArrowToggle { direction: GPlacement.Bottom }
                            GArrowToggle { direction: GPlacement.Top }
                            GArrowToggle { direction: GPlacement.Left }
                            GArrowToggle { direction: GPlacement.Right }
                        }

                        Row {
                            spacing: Metrics.spacing(2)
                            GHotkey { value: "Ctrl+S" }
                            GHotkey { value: "Ctrl+Shift+P" }
                        }

                        GHelpMark {
                            title: "HelpMark"
                            message: "Question mark that opens a popover."
                        }

                        Row {
                            spacing: Metrics.spacing(4)
                            GAvatarStack {
                                overlapSize: GSize.S
                                items: [{text: "AB"}, {text: "CD"}, {text: "EF"}, {text: "GH"}, {text: "IJ"}]
                            }
                            GAvatarStack {
                                overlapSize: GSize.L
                                size: GSize.S
                                visibleCount: 2
                                items: [{text: "AB"}, {text: "CD"}, {text: "EF"}]
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "UserLabel / Stepper" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GUserLabel { text: "Ada Lovelace"; avatarText: "AL"; view: GView.Outlined }
                        GUserLabel { text: "Clickable"; avatarText: "CL"; clickable: true }
                        GUserLabel { size: GSize.M; text: "Closable"; avatarText: "CB"; closable: true }
                        Item { Layout.fillWidth: true }
                    }
                    GStepper {
                        value: "build"
                        items: [{value: "plan", content: "Plan", view: GTheme.Success},
                                {value: "build", content: "Build"},
                                {value: "ship", content: "Ship", view: GTheme.Danger},
                                {value: "done", content: "Done", disabled: true}]
                    }

                    GText { variant: GVariant.Subheader2; text: "Accordion / Toc" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)

                        GAccordion {
                            Layout.preferredWidth: 340

                            GAccordionItem {
                                summary: "First section"
                                expanded: true
                                GText { width: parent.width; wrapMode: Text.Wrap
                                        text: "Details of the first row." }
                            }
                            GAccordionItem {
                                summary: "Second section"
                                GText { text: "Hidden until opened." }
                            }
                            GAccordionItem {
                                summary: "Disabled"
                                enabled: false
                            }
                        }

                        GToc {
                            Layout.preferredWidth: 260
                            value: "tokens"
                            items: [{value: "intro", content: "Introduction"},
                                    {value: "tokens", content: "Tokens", depth: 1},
                                    {value: "colors", content: "Colors", depth: 2},
                                    {value: "components", content: "Components", depth: 1}]
                        }

                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Alert" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        Repeater {
                            model: [{name: "info", theme: GTheme.Info},
                                    {name: "success", theme: GTheme.Success},
                                    {name: "warning", theme: GTheme.Warning},
                                    {name: "danger", theme: GTheme.Danger}]
                            GAlert {
                                required property var modelData
                                Layout.fillWidth: true
                                theme: modelData.theme
                                title: modelData.name
                                message: "Alert message, theme " + modelData.name + "."
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GAlert {
                            Layout.fillWidth: true
                            size: GSize.S
                            theme: GTheme.Utility
                            view: GView.Outlined
                            title: "Outlined, size s"
                            message: "Border instead of a fill."
                        }
                        GAlert {
                            Layout.fillWidth: true
                            size: GSize.L
                            theme: GTheme.Normal
                            title: "Size l with actions"
                            message: "Padding 24, radius 12, body-2."
                            closable: true
                            actions: [{text: "Apply", view: GView.Action}, {text: "Cancel", view: GView.Flat}]
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Toast (placed inline here; the real stack sits bottom-right)" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GToast { title: "Saved"; content: "Changes written to disk." }
                        GToast { theme: GTheme.Danger; title: "Failed"; content: "Could not reach the server." }
                        GToast { theme: GTheme.Success; title: "Deployed"; content: "Build 412 is live." }
                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Menu surface (the rows a GMenu popup shows)" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)
                        Repeater {
                            model: [GSize.S, GSize.M, GSize.L]
                            GSurface {
                                id: menuSurface
                                required property int modelData
                                borderWidth: 1
                                implicitWidth: 200
                                implicitHeight: menuRows.implicitHeight + 2 * Metrics.spacing(1)
                                Column {
                                    id: menuRows
                                    y: Metrics.spacing(1)
                                    width: parent.width
                                    GMenuItem { width: parent.width; size: menuSurface.modelData; text: "Open" }
                                    GMenuItem { width: parent.width; size: menuSurface.modelData; text: "Rename"; active: true }
                                    GMenuItem { width: parent.width; size: menuSurface.modelData; text: "Duplicate"; enabled: false }
                                    Rectangle { width: parent.width; height: 1; color: Theme.colors.lineGeneric }
                                    GMenuItem { width: parent.width; size: menuSurface.modelData; text: "Delete"; theme: GTheme.Danger }
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Select" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GSelect {
                            implicitWidth: 220
                            placeholder: "Pick an environment"
                            options: [{value: "dev", content: "Development"},
                                      {value: "stage", content: "Staging"},
                                      {value: "prod", content: "Production"}]
                        }
                        GSelect {
                            implicitWidth: 220
                            size: GSize.L
                            value: "b"
                            options: [{value: "a", content: "Size l"}, {value: "b", content: "Selected"}]
                        }
                        GSelect { implicitWidth: 180; enabled: false; placeholder: "Disabled" }
                        Item { Layout.fillWidth: true }
                    }

                    GText { variant: GVariant.Subheader2; text: "Interactive: hover or click these" }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(3)

                        GButton {
                            text: "Tooltip on hover"
                            GTooltip { text: "Popup chrome with a 1px shadow and no border." }
                        }

                        GButton {
                            text: "Popover"
                            onClicked: popoverDemo.opened ? popoverDemo.close() : popoverDemo.open()
                            GPopover {
                                id: popoverDemo
                                title: "Popover"
                                message: "Anchored below, 4px away, sliding 10px on open."
                            }
                        }

                        GButton {
                            text: "Menu"
                            onClicked: menuDemo.opened ? menuDemo.close() : menuDemo.open()
                            GMenu {
                                id: menuDemo
                                minimumWidth: 200
                                options: [{content: "Open"},
                                          {content: "Rename", active: true},
                                          {content: "Duplicate", disabled: true},
                                          {content: "Delete", theme: GTheme.Danger, separatorBefore: true}]
                            }
                        }

                        GButton {
                            text: "Dialog"
                            view: GView.Action
                            onClicked: dialogDemo.open()
                        }

                        GButton {
                            text: "Toast"
                            onClicked: toaster.add({title: "Saved", content: "Changes written to disk.", theme: GTheme.Success})
                        }

                        GButton {
                            text: "Action tooltip"
                            GActionTooltip {
                                title: "Save"
                                hotkey: "Ctrl+S"
                                description: "Dark surface, light text, a hotkey on the right."
                            }
                        }

                        GDropdownMenu {
                            menuMinimumWidth: 180
                            options: [{content: "Rename"},
                                      {content: "Duplicate"},
                                      {content: "Delete", theme: GTheme.Danger, separatorBefore: true}]
                        }

                        GButton {
                            text: "Drawer"
                            onClicked: drawerDemo.open()
                        }

                        GButton {
                            text: "Sheet"
                            onClicked: sheetDemo.open()
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "Button views" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(2)
                        Repeater {
                            model: [{name: "normal", view: GView.Normal},
                                    {name: "action", view: GView.Action},
                                    {name: "raised", view: GView.Raised},
                                    {name: "outlined", view: GView.Outlined},
                                    {name: "outlined-info", view: GView.OutlinedInfo},
                                    {name: "outlined-success", view: GView.OutlinedSuccess},
                                    {name: "outlined-warning", view: GView.OutlinedWarning},
                                    {name: "outlined-danger", view: GView.OutlinedDanger},
                                    {name: "outlined-utility", view: GView.OutlinedUtility},
                                    {name: "outlined-action", view: GView.OutlinedAction},
                                    {name: "flat", view: GView.Flat},
                                    {name: "flat-secondary", view: GView.FlatSecondary},
                                    {name: "flat-info", view: GView.FlatInfo},
                                    {name: "flat-success", view: GView.FlatSuccess},
                                    {name: "flat-warning", view: GView.FlatWarning},
                                    {name: "flat-danger", view: GView.FlatDanger},
                                    {name: "flat-utility", view: GView.FlatUtility},
                                    {name: "flat-action", view: GView.FlatAction}]
                            GButton {
                                required property var modelData
                                text: modelData.name
                                view: modelData.view
                            }
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Contrast views (drawn over a dark surface)" }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 60
                        radius: 8
                        color: "#3A3A3A"
                        Row {
                            anchors.centerIn: parent
                            spacing: Metrics.spacing(2)
                            GButton { text: "normal-contrast"; view: GView.NormalContrast }
                            GButton { text: "outlined-contrast"; view: GView.OutlinedContrast }
                            GButton { text: "flat-contrast"; view: GView.FlatContrast }
                            GButton { text: "disabled"; view: GView.NormalContrast; enabled: false }
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Disabled" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(2)
                        GButton { text: "Normal"; enabled: false }
                        GButton { text: "Action"; view: GView.Action; enabled: false }
                        GButton { text: "Outlined"; view: GView.Outlined; enabled: false }
                        GButton { text: "Flat"; view: GView.Flat; enabled: false }
                    }

                    GText { variant: GVariant.Subheader2; text: "Sizes (20 / 24 / 28 / 36 / 44)" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(2)
                        GButton { text: "XS"; size: GSize.Xs; view: GView.Action }
                        GButton { text: "S"; size: GSize.S; view: GView.Action }
                        GButton { text: "M"; size: GSize.M; view: GView.Action }
                        GButton { text: "L"; size: GSize.L; view: GView.Action }
                        GButton { text: "XL"; size: GSize.Xl; view: GView.Action }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "Text inputs" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(3)
                        GTextField { placeholderText: "Size s"; size: GSize.S }
                        GTextField { placeholderText: "Size m" }
                        GTextField { placeholderText: "Size l"; size: GSize.L }
                        GTextField { placeholderText: "Size xl"; size: GSize.Xl }
                        GTextField { placeholderText: "Disabled"; enabled: false }
                    }

                    GText { variant: GVariant.Subheader2; text: "Checkboxes (14 / 17 / 24)" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GCheckbox { text: "Size m"; checked: true }
                        GCheckbox { text: "Size l"; size: GSize.L; checked: true }
                        GCheckbox { text: "Size xl"; size: GSize.Xl; checked: true }
                        GCheckbox { text: "Indeterminate"; tristate: true; checkState: Qt.PartiallyChecked }
                        GCheckbox { text: "Disabled"; checked: true; enabled: false }
                        GCheckbox { text: "Disabled off"; enabled: false }
                    }

                    GText { variant: GVariant.Subheader2; text: "Switches (28 / 36 / 42)" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GSwitch { text: "Size s"; size: GSize.S; checked: true }
                        GSwitch { text: "Size m"; checked: true }
                        GSwitch { text: "Size l"; size: GSize.L; checked: true }
                        GSwitch { text: "Disabled"; checked: true; enabled: false }
                        GSwitch { text: "Disabled off"; enabled: false }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "Radio / RadioGroup" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)
                        GRadioGroup {
                            direction: GDirection.Horizontal
                            value: "b"
                            options: [{value: "a", content: "Size m"},
                                      {value: "b", content: "Second"},
                                      {value: "c", content: "Disabled", disabled: true}]
                        }
                        GRadioGroup {
                            size: GSize.Xl
                            value: "y"
                            options: [{value: "x", content: "Vertical xl"},
                                      {value: "y", content: "Selected"}]
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "SegmentedRadioGroup (24 / 28 / 36)" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        Repeater {
                            model: [GSize.S, GSize.M, GSize.L]
                            GSegmentedRadioGroup {
                                required property int modelData
                                size: modelData
                                value: "day"
                                options: [{value: "day", content: "Day"},
                                          {value: "week", content: "Week"},
                                          {value: "month", content: "Month"}]
                            }
                        }
                        GSegmentedRadioGroup {
                            enabled: false
                            value: "off"
                            options: [{value: "on", content: "On"}, {value: "off", content: "Off"}]
                        }
                    }

                    GText { variant: GVariant.Subheader2; text: "Slider (15 / 18 / 21 / 24)" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)
                        GSlider { width: 170; size: GSize.S; value: 0.3 }
                        GSlider { width: 170; value: 0.5 }
                        GSlider { width: 170; size: GSize.L; value: 0.7 }
                        GSlider { width: 170; size: GSize.Xl; value: 0.9 }
                        GSlider { width: 170; value: 0.4; inputState: GInputState.Error }
                        GSlider { width: 170; value: 0.4; enabled: false }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "TextArea / NumberInput / PinInput" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)
                        GTextArea { width: 250; placeholderText: "Multi-line text area" }
                        GTextArea { width: 250; inputState: GInputState.Error; text: "Error state" }
                        GNumberInput { width: 150; value: 42; to: 999 }
                        GNumberInput { width: 150; value: 7; size: GSize.L }
                        GNumberInput { width: 150; value: 3; enabled: false }
                    }
                    Flow {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)
                        GPinInput { value: "12" }
                        GPinInput { size: GSize.L; length: 6; mask: true; value: "4821" }
                        GPinInput { inputState: GInputState.Error; value: "99" }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)
                spacing: Metrics.spacing(4)

                GCard {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width
                        spacing: Metrics.spacing(1)

                        GText { variant: GVariant.Subheader2; text: "Typography" }
                        GText { variant: GVariant.Display2; text: "Display 2" }
                        GText { variant: GVariant.Header1; text: "Header 1" }
                        GText { variant: GVariant.Body2; text: "Body 2 — обычный текст интерфейса." }
                        GText { variant: GVariant.Code2; text: "code-2: monospace" }
                        GText { variant: GVariant.Caption2; colorRole: GTextColor.Secondary; text: "Caption 2, secondary" }
                        GText { variant: GVariant.Body1; colorRole: GTextColor.Link; text: "Ссылка / link color" }
                        GText { variant: GVariant.Body1; colorRole: GTextColor.Danger; text: "Danger text" }
                    }
                }

                GCard {
                    view: GView.Filled
                    ColumnLayout {
                        spacing: Metrics.spacing(1)
                        GText { variant: GVariant.Subheader2; text: "Card filled" }
                        GText { variant: GVariant.Body1; colorRole: GTextColor.Secondary; text: "view: \"filled\"" }
                    }
                }

                GCard {
                    view: GView.Raised
                    ColumnLayout {
                        spacing: Metrics.spacing(1)
                        GText { variant: GVariant.Subheader2; text: "Card raised" }
                        GText { variant: GVariant.Body1; colorRole: GTextColor.Secondary; text: "view: \"raised\"" }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "PlaceholderContainer" }

                    GPlaceholderContainer {
                        Layout.fillWidth: true
                        size: GPlaceholderSize.M
                        title: "No environments yet"
                        description: "Create one to start deploying. Everything you add here " +
                                     "is visible to the whole team."
                        actions: [{text: "Create", view: GView.Action}, {text: "Docs", view: GView.Flat}]
                    }

                    GPlaceholderContainer {
                        Layout.fillWidth: true
                        size: GPlaceholderSize.S
                        direction: GDirection.Vertical
                        title: "Nothing found"
                        description: "Try a different query."
                        actions: [{text: "Reset", view: GView.Normal}]
                    }

                    GText { variant: GVariant.Subheader2; text: "ActionsPanel" }

                    GActionsPanel {
                        Layout.fillWidth: true
                        note: "3 selected"
                        actions: [{text: "Move", icon: "arrow-right-from-square"},
                                  {text: "Copy", icon: "copy"},
                                  {text: "Archive", icon: "archive"},
                                  {text: "Delete", icon: "trash-bin"},
                                  {text: "Rename", collapsed: true}]
                        onActionTriggered: function (index, action) {
                            toaster.add({title: action.text, theme: GTheme.Info});
                        }
                        onCloseRequested: toaster.add({title: "Selection cleared"})
                    }

                    // The same panel with no room: everything but the first
                    // action folds into the overflow menu.
                    GActionsPanel {
                        Layout.preferredWidth: 360
                        note: "3 selected"
                        actions: [{text: "Move", icon: "arrow-right-from-square"},
                                  {text: "Copy", icon: "copy"},
                                  {text: "Archive", icon: "archive"},
                                  {text: "Delete", icon: "trash-bin"}]
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "ClipboardButton / Palette / FilePreview" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(4)

                        GClipboardButton { content: "gravity-ui/uikit" }
                        GClipboardButton { content: "with a label"; text: "Copy id" }
                        GClipboardButton { content: "raised"; view: GView.Raised; size: GSize.L }
                        Item { Layout.fillWidth: true }
                    }

                    GPalette {
                        id: emojiPalette

                        options: [{value: "🙂"}, {value: "🎉"}, {value: "🚀"}, {value: "🐛"},
                                  {value: "🔥"}, {value: "📦"}, {value: "✅"}, {value: "❌"},
                                  {value: "💡"}, {value: "🧪", enabled: false}]
                        columns: 6
                        value: ["🎉"]
                        size: GSize.L
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(5)

                        GFilePreview {
                            fileName: "report-2026-q3.pdf"
                            description: "1.2 MB"
                            fileType: GFileType.Pdf
                            actions: [{icon: "arrow-down-to-line", title: "Download"},
                                      {icon: "trash-bin", title: "Delete"}]
                        }
                        GFilePreview {
                            fileName: "budget.xlsx"
                            fileType: GFileType.Table
                            selected: true
                        }
                        GFilePreview {
                            fileName: "main.qml"
                            fileType: GFileType.Code
                        }
                        GFilePreview {
                            fileName: "compact"
                            fileType: GFileType.Image
                            view: GView.Clear
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            GCard {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.spacing(5)
                Layout.rightMargin: Metrics.spacing(5)

                ColumnLayout {
                    width: parent.width
                    spacing: Metrics.spacing(4)

                    GText { variant: GVariant.Subheader2; text: "List / TreeList / TreeSelect / TableColumnSetup" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(6)

                        GList {
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 180
                            filterable: true
                            sortable: true
                            selectedIndexes: [1]
                            items: ["production", "staging", "review-1284", "review-1290",
                                    "sandbox", {text: "archived", disabled: true}]
                        }

                        GTreeList {
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 180
                            multiple: true
                            value: ["api"]
                            expanded: ["services"]
                            items: [{id: "services", title: "Services", children: [
                                         {id: "api", title: "api", subtitle: "3 replicas"},
                                         {id: "worker", title: "worker", subtitle: "1 replica"},
                                         {id: "cron", title: "cron", disabled: true}]},
                                    {id: "storage", title: "Storage", children: [
                                         {id: "pg", title: "postgres"},
                                         {id: "s3", title: "object storage"}]},
                                    {id: "readme", title: "README.md"}]
                        }

                        ColumnLayout {
                            spacing: Metrics.spacing(3)

                            GTreeSelect {
                                Layout.preferredWidth: 220
                                placeholder: "Pick a service"
                                hasClear: true
                                expanded: ["services"]
                                items: [{id: "services", title: "Services", children: [
                                             {id: "api", title: "api"},
                                             {id: "worker", title: "worker"}]},
                                        {id: "storage", title: "Storage", children: [
                                             {id: "pg", title: "postgres"}]}]
                            }

                            GTableColumnSetup {
                                showStatus: true
                                items: [{id: "name", title: "Name", selected: true, required: true},
                                        {id: "status", title: "Status", selected: true},
                                        {id: "owner", title: "Owner", selected: true},
                                        {id: "created", title: "Created"},
                                        {id: "region", title: "Region"}]
                                onUpdated: function (next) {
                                    toaster.add({title: "Columns updated",
                                                 content: next.length + " columns"});
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            Item { Layout.preferredHeight: Metrics.spacing(3) }
        }
    }

        // Last child of root on purpose: toasts float over the page, and a
        // sibling declared earlier is painted under it.
        GToaster { id: toaster; anchors.fill: parent }
    }
}
