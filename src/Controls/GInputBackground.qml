import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Shared chrome for the input family (.g-text-input__content and
// .g-text-area__content are the same declaration): a 1px border reacting to
// hover / focus / error, and a fill that only shows up when disabled.
//
// Named properties rather than reading a parent control so GTextField,
// GTextArea, GNumberInput and GPinInput can all reuse it.
Rectangle {
    id: background

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)
    property int size: GSize.M
    property int view: GView.Normal       // normal | clear
    property int inputState: GInputState.Normal // normal | error
    property bool controlEnabled: true
    property bool controlHovered: false
    property bool controlFocused: false

    radius: view === GView.Clear ? 0 : Metrics.radiusForSize(size)
    color: controlEnabled ? "transparent" : background.gcolors.baseGenericAccentDisabled
    border.width: 1
    border.color: {
        const t = background.gcolors;
        // .g-text-input_disabled and _view_clear both clear every border color
        if (!controlEnabled || view === GView.Clear)
            return "transparent";
        // error wins over hover and focus alike
        if (inputState === GInputState.Error)
            return t.lineDanger;
        if (controlFocused)
            return t.lineGenericActive;
        if (controlHovered)
            return t.lineGenericHover;
        return t.lineGeneric;
    }

    Behavior on color { ColorAnimation { duration: 100 } }
    Behavior on border.color { ColorAnimation { duration: 100 } }

    // Upstream also puts a 2px --g-color-line-focus outline outside the field
    // on :focus-within. That needs the shared focus ring -- phase 2.
}
