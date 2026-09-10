pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Palette: a grid of square toggles, normally
// emoji or single glyphs.
//
//   options:  [{value, content, enabled}] -- `content` defaults to `value`
//   columns:  6 upstream
//   multiple: several values at once (default), or one at a time
//   value:    the selected values, as a list of strings
//
// The whole grid is one tab stop and the arrow keys walk it, the way a
// role="grid" behaves upstream: Tab moves past the palette rather than
// through 40 emoji.
FocusScope {
    id: palette

    property var options: []
    property int columns: 6
    property bool multiple: true
    property int size: GSize.M
    property var value: []

    signal updated(var value)

    // Which cell the arrow keys are on; -1 until the grid takes focus.
    property int _cursor: -1

    readonly property int _gap: 8
    readonly property int _cell: Metrics.heightForSize(size)
    readonly property int _rows: Math.ceil(options.length / Math.max(1, columns))

    implicitWidth: Math.min(options.length, Math.max(1, columns)) * (_cell + _gap) - _gap
    implicitHeight: Math.max(0, _rows * (_cell + _gap) - _gap)

    activeFocusOnTab: true
    onActiveFocusChanged: {
        if (activeFocus && _cursor === -1 && options.length > 0)
            _cursor = 0;
        else if (!activeFocus)
            _cursor = -1;
    }

    function selected(optionValue: string): bool {
        return value !== undefined && value.indexOf(optionValue) !== -1;
    }

    function toggle(index: int) {
        const option = options[index];
        if (option === undefined || option.enabled === false)
            return;
        const current = value === undefined ? [] : value.slice();
        const at = current.indexOf(option.value);
        let next;
        if (multiple)
            next = at === -1 ? current.concat([option.value])
                             : current.slice(0, at).concat(current.slice(at + 1));
        else
            next = at === -1 ? [option.value] : [];
        palette.value = next;
        palette.updated(next);
    }

    function _move(delta: int) {
        const next = _cursor + delta;
        if (next < 0 || next >= options.length)
            return;
        _cursor = next;
    }

    Keys.onLeftPressed: palette._move(-1)
    Keys.onRightPressed: palette._move(1)
    Keys.onUpPressed: palette._move(-Math.max(1, palette.columns))
    Keys.onDownPressed: palette._move(Math.max(1, palette.columns))
    Keys.onSpacePressed: palette.toggle(palette._cursor)
    Keys.onReturnPressed: palette.toggle(palette._cursor)
    Keys.onEnterPressed: palette.toggle(palette._cursor)

    Repeater {
        model: palette.options

        GButton {
            id: cell

            required property int index
            required property var modelData

            x: (cell.index % Math.max(1, palette.columns)) * (palette._cell + palette._gap)
            y: Math.floor(cell.index / Math.max(1, palette.columns)) * (palette._cell + palette._gap)
            width: palette._cell
            height: palette._cell

            size: palette.size
            // Upstream keeps every cell out of the tab order and drives them
            // from the grid's own key handler.
            focusPolicy: Qt.NoFocus
            view: palette.selected(cell.modelData.value) ? GView.Normal : GView.Flat
            selected: palette.selected(cell.modelData.value)
            enabled: cell.modelData.enabled !== undefined ? cell.modelData.enabled : true
            text: cell.modelData.content !== undefined ? cell.modelData.content : cell.modelData.value
            font.pixelSize: Metrics.paletteFontSize(palette.size)

            onClicked: palette.toggle(cell.index)

            // The ring follows the arrow-key cursor, not Qt's focus: the
            // buttons never take focus, the grid holds it for all of them.
            GFocusRing {
                boxRadius: Metrics.radiusForSize(palette.size)
                visible: palette.activeFocus && palette._cursor === cell.index
                         && GInputMode.keyboardNavigation
            }
        }
    }
}
