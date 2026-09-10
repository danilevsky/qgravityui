pragma ComponentBehavior: Bound

import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Stepper: numbered steps with chevrons between.
//   items: [{ value, content, view, disabled }]
//          view: GTheme.Normal (idle) | Success | Danger -- picks the icon
//
// The selected step is a Button with a line-brand border upstream; the same
// GButton view table gives that with an outlined view.
Row {
    id: stepper

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property var items: []
    property int size: GSize.M
    property var value: undefined

    signal activated(int index, var item)

    // .g-stepper --_--step-gap
    spacing: Metrics.spacing(2)

    Repeater {
        model: stepper.items

        Row {
            id: step

            required property int index
            required property var modelData

            readonly property bool selected: stepper.value !== undefined
                                             && stepper.value === modelData.value

            spacing: Metrics.spacing(2)

            // .g-stepper__separator
            GIcon {
                anchors.verticalCenter: parent.verticalCenter
                visible: step.index > 0
                name: "chevron-right"
                size: Metrics.stepperIconSize
                color: stepper.gcolors.textSecondary
            }

            GButton {
                size: stepper.size
                view: step.selected ? GView.OutlinedAction : GView.Flat
                enabled: step.modelData.disabled !== true
                text: step.modelData.content !== undefined ? step.modelData.content : ""
                // .g-stepper__item max-width
                implicitWidth: Math.min(Metrics.stepperTextMaxWidth,
                                        implicitContentWidth + leftPadding + rightPadding)
                icon.name: {
                    switch (step.modelData.view) {
                    case GTheme.Success: return "circle-check";
                    case GTheme.Danger: return "circle-xmark";
                    default: return "";
                    }
                }
                // .g-stepper__item-icon_view_{success,error,idle}: the status
                // icon keeps its own colour, unlike an ordinary button glyph
                // which follows the label.
                iconColor: {
                    if (!enabled)
                        return stepper.gcolors.textHint;
                    switch (step.modelData.view) {
                    case GTheme.Success: return stepper.gcolors.textPositive;
                    case GTheme.Danger: return stepper.gcolors.textDanger;
                    default: return stepper.gcolors.textSecondary;
                    }
                }
                onClicked: {
                    stepper.value = step.modelData.value;
                    stepper.activated(step.index, step.modelData);
                }
            }
        }
    }
}
