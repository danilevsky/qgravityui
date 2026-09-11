pragma Singleton

import QtQuick

// The state matrix, as data.
//
// Each entry expands into one case per combination of its `axes`, so a whole
// view table is a few lines rather than a hundred hand-written snippets. The
// body is QML source compiled at run time -- this is a test tool, so paying
// for Qt.createQmlObject buys a matrix that is written once and grows by
// adding a value to a list.
//
// Anything that animates is left out or frozen: a screenshot of a spinner
// compares differently every run.
QtObject {
    readonly property var definitions: [
        {
            id: "button-view",
            axes: {view: ["Normal", "Action", "Raised", "Outlined", "Flat",
                          "OutlinedInfo", "OutlinedSuccess", "OutlinedWarning",
                          "OutlinedDanger", "OutlinedUtility", "OutlinedAction",
                          "FlatSecondary", "FlatInfo", "FlatSuccess", "FlatWarning",
                          "FlatDanger", "FlatUtility", "FlatAction",
                          "NormalContrast", "OutlinedContrast", "FlatContrast"]},
            body: 'GButton { view: GView.%view%; text: "Button" }'
        },
        {
            id: "button-size",
            axes: {size: ["Xs", "S", "M", "L", "Xl"]},
            body: 'GButton { size: GSize.%size%; text: "Button" }'
        },
        {
            id: "button-state",
            axes: {},
            body: 'GButton { text: "Disabled"; enabled: false }'
        },
        {
            id: "button-pressed",
            axes: {},
            body: 'GButton { view: GView.Action; text: "Pressed"; down: true }'
        },
        {
            id: "button-icon",
            axes: {},
            body: 'GButton { icon.name: "plus"; text: "With icon" }'
        },
        {
            // A button with no label is square, and the glyph has to sit in
            // the middle of that square -- it was 4px right of centre until
            // the paddings were recomputed for the narrower box.
            id: "button-icon-only",
            axes: {size: ["Xs", "S", "M", "L", "Xl"]},
            body: 'GButton { size: GSize.%size%; icon.name: "xmark" }'
        },

        {
            id: "input-size",
            axes: {size: ["S", "M", "L", "Xl"]},
            body: 'GTextField { width: 160; size: GSize.%size%; text: "Value" }'
        },
        {
            id: "input-state",
            axes: {state: ["Normal", "Error"]},
            body: 'GTextField { width: 160; inputState: GInputState.%state%; text: "Value" }'
        },
        {
            id: "input-disabled",
            axes: {},
            body: 'GTextField { width: 160; enabled: false; text: "Value" }'
        },
        {
            id: "textarea",
            axes: {},
            body: 'GTextArea { width: 200; text: "Multi\nline" }'
        },
        {
            id: "numberinput",
            axes: {},
            body: 'GNumberInput { width: 140; value: 42 }'
        },
        {
            id: "pininput",
            axes: {size: ["S", "M", "L", "Xl"]},
            body: 'GPinInput { size: GSize.%size%; value: "12" }'
        },
        {
            id: "select",
            axes: {},
            body: 'GSelect { width: 180; placeholder: "Pick one" }'
        },

        {
            id: "checkbox",
            axes: {size: ["M", "L", "Xl"]},
            body: 'GCheckbox { size: GSize.%size%; text: "Checkbox"; checked: true }'
        },
        {
            id: "checkbox-state",
            axes: {},
            body: 'GCheckbox { text: "Indeterminate"; checkState: Qt.PartiallyChecked }'
        },
        {
            id: "radio",
            axes: {size: ["M", "L", "Xl"]},
            body: 'GRadio { size: GSize.%size%; text: "Radio"; checked: true }'
        },
        {
            id: "switch",
            axes: {size: ["S", "M", "L"]},
            body: 'GSwitch { size: GSize.%size%; text: "Switch"; checked: true }'
        },
        {
            id: "segmented",
            axes: {size: ["S", "M", "L", "Xl"]},
            body: 'GSegmentedRadioGroup { size: GSize.%size%; value: "a"; '
                  + 'options: [{value: "a", content: "One"}, {value: "b", content: "Two"}] }'
        },
        {
            id: "slider",
            axes: {size: ["S", "M", "L", "Xl"]},
            body: 'GSlider { width: 160; size: GSize.%size%; value: 0.6 }'
        },
        {
            // The tooltip floats outside the control's own bounds (see
            // GSlider.qml), so every case that shows one wraps it in a plain
            // Item that leaves room for it to draw into -- the same margin a
            // real caller would leave around a slider whose tooltip is not
            // Off.
            id: "slider-tooltip-on",
            axes: {},
            body: 'Item { width: 200; height: 80; GSlider { y: 40; width: 180; '
                  + 'from: 0; to: 100; value: 35; tooltipDisplay: GTooltipDisplay.On } }'
        },
        {
            id: "slider-tooltip-bottom",
            axes: {},
            body: 'Item { width: 200; height: 80; GSlider { width: 180; '
                  + 'from: 0; to: 100; value: 35; tooltipDisplay: GTooltipDisplay.On; '
                  + 'tooltipPlacement: GPlacement.Bottom } }'
        },
        {
            id: "slider-marks",
            axes: {},
            body: 'GSlider { width: 180; from: 0; to: 100; value: 60; marks: 6 }'
        },
        {
            id: "slider-error",
            axes: {},
            body: 'GSlider { width: 180; from: 0; to: 100; value: 50; '
                  + 'errorMessage: "Value must stay under the quota" }'
        },
        {
            id: "slider-vertical",
            axes: {},
            body: 'GSlider { height: 160; orientation: Qt.Vertical; from: 0; to: 100; '
                  + 'value: 40; marks: 5; tooltipDisplay: GTooltipDisplay.On }'
        },
        {
            id: "slider-vertical-tooltip-left",
            axes: {},
            body: 'Item { width: 200; height: 170; GSlider { x: 40; height: 160; '
                  + 'orientation: Qt.Vertical; from: 0; to: 100; value: 65; '
                  + 'tooltipDisplay: GTooltipDisplay.On; tooltipPlacement: GPlacement.Left } }'
        },
        {
            // A low value should sit near the bottom of a vertical rail
            // (max at top, same convention GSlider draws) -- this case is
            // the visual half of the fix for the click/drag inversion,
            // GListDrag-style coverage of the interaction itself lives in
            // the QtQuickTest alongside GList's.
            id: "slider-vertical-low-value",
            axes: {},
            body: 'GSlider { height: 160; orientation: Qt.Vertical; from: 0; to: 100; value: 15 }'
        },
        {
            id: "range-slider",
            axes: {},
            body: 'GRangeSlider { width: 180; from: 0; to: 100; first.value: 20; second.value: 70 }'
        },
        {
            id: "range-slider-marks",
            axes: {},
            body: 'GRangeSlider { width: 180; from: 0; to: 100; first.value: 25; second.value: 75; marks: 6 }'
        },
        {
            id: "range-slider-tooltip-on",
            axes: {},
            body: 'Item { width: 200; height: 80; GRangeSlider { y: 40; width: 180; '
                  + 'from: 0; to: 100; first.value: 20; second.value: 70; '
                  + 'tooltipDisplay: GTooltipDisplay.On } }'
        },
        {
            id: "range-slider-error",
            axes: {},
            body: 'GRangeSlider { width: 180; from: 0; to: 100; first.value: 20; second.value: 70; '
                  + 'errorMessage: "Range must stay under the quota" }'
        },
        {
            id: "range-slider-vertical",
            axes: {},
            body: 'GRangeSlider { height: 160; orientation: Qt.Vertical; from: 0; to: 100; '
                  + 'first.value: 25; second.value: 75; marks: 5 }'
        },

        {
            id: "label-theme",
            axes: {theme: ["Normal", "Info", "Success", "Warning", "Danger",
                           "Utility", "Unknown", "Clear"]},
            body: 'GLabel { theme: GTheme.%theme%; content: "Label" }'
        },
        {
            id: "label-size",
            axes: {size: ["Xxs", "Xs", "S", "M"]},
            body: 'GLabel { size: GSize.%size%; content: "Label"; value: "1" }'
        },
        {
            id: "alert",
            axes: {theme: ["Info", "Success", "Warning", "Danger", "Utility"],
                   view: ["Filled", "Outlined"]},
            body: 'GAlert { width: 260; theme: GTheme.%theme%; view: GView.%view%; '
                  + 'title: "Title"; message: "Message." }'
        },
        {
            id: "card",
            axes: {view: ["Outlined", "Filled", "Raised", "Clear"]},
            body: 'GCard { view: GView.%view%; GText { text: "Card" } }'
        },
        {
            id: "progress",
            axes: {theme: ["Normal", "Success", "Warning", "Danger", "Info", "Misc"]},
            body: 'GProgress { width: 180; theme: GTheme.%theme%; value: 60; text: "60%" }'
        },
        {
            id: "avatar",
            axes: {size: ["Xxxs", "Xxs", "Xs", "S", "M", "L", "Xl"]},
            body: 'GAvatar { size: GSize.%size%; text: "AB" }'
        },
        {
            id: "avatar-view",
            axes: {view: ["Filled", "Outlined"], theme: ["Normal", "Brand"]},
            body: 'GAvatar { view: GView.%view%; theme: GTheme.%theme%; text: "AB" }'
        },
        {
            id: "userlabel",
            axes: {},
            body: 'GUserLabel { text: "Ada Lovelace"; avatarText: "AL"; view: GView.Outlined }'
        },
        {
            id: "hotkey",
            axes: {},
            body: 'GHotkey { value: "Ctrl+Shift+P" }'
        },
        {
            id: "tabs",
            axes: {size: ["M", "L", "Xl"]},
            body: 'GTabs { size: GSize.%size%; value: "a"; '
                  + 'items: [{id: "a", title: "One"}, {id: "b", title: "Two", counter: "3"}] }'
        },
        {
            id: "breadcrumbs",
            axes: {},
            body: 'GBreadcrumbs { items: [{text: "Home"}, {text: "Here"}] }'
        },
        {
            id: "skeleton",
            axes: {size: ["Xs", "S", "M", "L", "Xl"]},
            body: 'GSkeleton { width: 160; size: GSize.%size%; animation: GAnimation.None }'
        },
        {
            id: "divider",
            axes: {},
            body: 'GDivider { width: 200; text: "or" }'
        },
        {
            // The switcher keeps its own size, independent of the menu's:
            // ActionsPanel puts an m button over an s menu, and letting the
            // button follow the menu shrank it out of line with the row.
            id: "dropdown-switcher",
            axes: {size: ["S", "M", "L"]},
            body: 'GDropdownMenu { size: GSize.S; switcherSize: GSize.%size%; '
                  + 'switcherView: GView.Outlined; options: [{content: "One"}] }'
        },
        {
            id: "placeholder",
            axes: {size: ["S", "M", "L", "Promo"]},
            body: 'GPlaceholderContainer { width: 400; size: GPlaceholderSize.%size%; '
                  + 'title: "Empty"; description: "Nothing here yet."; '
                  + 'actions: [{text: "Create", view: GView.Action}] }'
        },
        {
            id: "placeholder-column",
            axes: {},
            body: 'GPlaceholderContainer { width: 400; size: GPlaceholderSize.S; '
                  + 'direction: GDirection.Vertical; title: "Empty"; '
                  + 'description: "Nothing here yet." }'
        },
        {
            id: "actions-panel",
            axes: {},
            body: 'GActionsPanel { width: 380; note: "3 selected"; '
                  + 'actions: [{text: "Move"}, {text: "Copy"}, {text: "Delete"}] }'
        },
        {
            id: "actions-panel-collapsed",
            axes: {},
            body: 'GActionsPanel { width: 240; note: "3 selected"; '
                  + 'actions: [{text: "Move"}, {text: "Copy"}, {text: "Delete"}] }'
        },
        {
            id: "clipboard-button",
            axes: {},
            body: 'GClipboardButton { content: "x"; text: "Copy" }'
        },
        {
            // Pins the status-icon colours: the glyph is painted apart from
            // the label (.g-stepper__item-icon_view_*), which an ordinary
            // button glyph never is.
            id: "stepper",
            axes: {},
            body: 'GStepper { value: 2; '
                  + 'items: [{value: 1, content: "Done", view: GTheme.Success}, '
                  + '{value: 2, content: "Failed", view: GTheme.Danger}, '
                  + '{value: 3, content: "Next"}, '
                  + '{value: 4, content: "Off", disabled: true}] }'
        },
        {
            id: "palette",
            axes: {size: ["S", "M", "L"]},
            body: 'GPalette { size: GSize.%size%; columns: 4; value: ["b"]; '
                  + 'options: [{value: "a"}, {value: "b"}, {value: "c"}, {value: "d"}] }'
        },
        {
            id: "file-preview",
            axes: {type: ["Default", "Image", "Text", "Pdf", "Table"]},
            body: 'GFilePreview { fileName: "file.ext"; description: "1 MB"; '
                  + 'fileType: GFileType.%type% }'
        },
        {
            id: "file-preview-compact",
            axes: {},
            body: 'GFilePreview { fileType: GFileType.Code; view: GView.Clear }'
        },
        {
            id: "list",
            axes: {},
            body: 'GList { width: 200; height: 120; selectedIndexes: [1]; '
                  + 'items: ["one", "two", {text: "three", disabled: true}] }'
        },
        {
            id: "list-sortable",
            axes: {},
            body: 'GList { width: 200; height: 120; sortable: true; '
                  + 'items: ["one", "two", "three"] }'
        },
        {
            // The grip lane and the filter field share the row's padding, so
            // this is the case that shows a row lining up with the search box.
            id: "list-filterable-sortable",
            axes: {},
            body: 'GList { width: 200; height: 140; filterable: true; sortable: true; '
                  + 'selectedIndexes: [1]; items: ["one", "two", "three"] }'
        },
        {
            id: "treelist",
            axes: {size: ["S", "M", "L"]},
            body: 'GTreeList { width: 220; height: 140; size: GSize.%size%; multiple: true; '
                  + 'value: ["a1"]; expanded: ["a"]; '
                  + 'items: [{id: "a", title: "Group", children: ['
                  + '{id: "a1", title: "First", subtitle: "sub"}, {id: "a2", title: "Second"}]}, '
                  + '{id: "b", title: "Leaf"}] }'
        },
        {
            id: "treeselect",
            axes: {},
            body: 'GTreeSelect { width: 200; placeholder: "Pick one"; '
                  + 'items: [{id: "a", title: "Group", children: [{id: "a1", title: "First"}]}] }'
        },
        {
            id: "column-setup",
            axes: {},
            body: 'GTableColumnSetup { showStatus: true; '
                  + 'items: [{id: "n", title: "Name", selected: true, required: true}, '
                  + '{id: "s", title: "Status", selected: true}, {id: "r", title: "Region"}] }'
        },
        {
            id: "typography",
            axes: {variant: ["Body1", "Body2", "Body3", "Caption1", "Caption2",
                             "Header1", "Subheader2", "Display1", "Code1"]},
            body: 'GText { variant: GVariant.%variant%; text: "Ag" }'
        }
    ]
}
