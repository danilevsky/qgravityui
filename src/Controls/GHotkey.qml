pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Hotkey: a key combination, "mod+s" style.
//   value: "mod+s" or "ctrl+shift+p" -- parts split on "+", joined by a
//          dimmed plus, exactly as .g-hotkey__plus is styled
//   view:  GView.Normal (light) | GView.Clear (dark, for use on a tooltip)
Rectangle {
    id: hotkey

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string value: ""
    property int view: GView.Normal

    readonly property bool _dark: view === GView.Clear
    readonly property var _parts: value === "" ? [] : value.split("+")

    implicitWidth: row.implicitWidth + 2 * Metrics.hotkeyPaddingInline
    implicitHeight: row.implicitHeight + 2 * Metrics.hotkeyPaddingBlock

    radius: Metrics.radiusXs
    color: _dark ? hotkey.gcolors.baseLightSimpleHover : hotkey.gcolors.baseGeneric

    Row {
        id: row

        x: Metrics.hotkeyPaddingInline
        y: Metrics.hotkeyPaddingBlock
        spacing: 0

        Repeater {
            model: hotkey._parts

            Row {
                id: part

                required property int index
                required property string modelData

                spacing: 0

                GText {
                    visible: part.index > 0
                    text: "+"
                    // .g-hotkey__plus
                    color: hotkey._dark ? hotkey.gcolors.textLightHint : hotkey.gcolors.textHint
                    leftPadding: 2
                    rightPadding: 2
                }

                GText {
                    text: part.modelData
                    color: hotkey._dark ? hotkey.gcolors.textLightComplementary
                                        : hotkey.gcolors.textPrimary
                }
            }
        }
    }
}
