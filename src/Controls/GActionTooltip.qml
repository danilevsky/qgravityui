import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit ActionTooltip: the tooltip used on toolbar
// buttons, with a title, an optional hotkey and a second line of detail.
//
// ActionTooltip.css does not restyle a surface of its own -- it overrides
// Tooltip's variables, so this derives from GTooltip and does the same:
// base-float-heavy behind light text, padding --g-spacing-2 / --g-spacing-3.
GTooltip {
    id: tip

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string title: ""
    property string description: ""
    property string hotkey: ""

    topPadding: Metrics.spacing(2)
    bottomPadding: Metrics.spacing(2)
    leftPadding: Metrics.spacing(3)
    rightPadding: Metrics.spacing(3)

    background: GSurface {
        borderWidth: 0
        radius: Metrics.tooltipRadius
        color: tip.gcolors.baseFloatHeavy
        shadowBlurPx: 5
        shadowOffsetY: 1
    }

    contentItem: Column {
        spacing: 0

        // .g-action-tooltip__heading
        Row {
            spacing: Metrics.spacing(2)

            GText {
                text: tip.title
                color: tip.gcolors.textLightPrimary
            }

            GText {
                visible: tip.hotkey !== ""
                text: tip.hotkey
                color: tip.gcolors.textLightSecondary
            }
        }

        // .g-action-tooltip__description margin-block-start
        Item {
            width: 1
            height: Metrics.spacing(1)
            visible: tip.description !== ""
        }

        GText {
            visible: tip.description !== ""
            text: tip.description
            color: tip.gcolors.textLightSecondary
            width: Math.min(implicitWidth, Metrics.tooltipMaxWidth)
            wrapMode: Text.Wrap
        }
    }
}
