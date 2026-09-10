pragma ComponentBehavior: Bound
import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit SegmentedRadioGroup.
//   size: GSize.S | M (default) | L | Xl
//   options: [{ value, content, disabled }]
//
// Segments share a 1px border: upstream drops the inner edge of unselected
// neighbours, which here is a -1px row spacing so adjacent borders overlap,
// plus a z bump so the selected segment's brand border stays whole.
Row {
    id: group

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property var options: []
    property var value

    signal activated(var value)

    readonly property int _height: Metrics.heightForSize(size === GSize.Xs ? GSize.S : size)
    readonly property int _radius: Metrics.radiusForSize(size)
    // SegmentedRadioGroup.css .g-segmented-radio-group__option-text margin
    readonly property int _textMargin: {
        switch (size) {
        case GSize.S: return 10;
        case GSize.L: return 18;
        case GSize.Xl: return 25;
        default: return 13;
        }
    }

    spacing: -1

    Repeater {
        model: group.options

        T.AbstractButton {
            id: segment
            required property int index
            required property var modelData

            readonly property bool _checked: group.value === modelData.value
            readonly property bool _first: index === 0
            readonly property bool _last: index === group.options.length - 1

            enabled: group.enabled && modelData.disabled !== true
            hoverEnabled: true
            height: group._height
            implicitWidth: contentItem.implicitWidth + 2 * group._textMargin
            z: _checked ? 1 : 0

            focusPolicy: Qt.StrongFocus

            onClicked: {
                group.value = modelData.value;
                group.activated(modelData.value);
            }

            GFocusRing {
                // .g-segmented-radio-group__option:has(:focus-visible)
                ringColor: group.gcolors.lineMisc
                offset: -1
                boxRadius: group._radius
            }

            contentItem: Text {
                text: segment.modelData.content !== undefined ? segment.modelData.content
                                                              : segment.modelData.value
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: Metrics.fontSizeForSize(group.size)
                font.weight: Typography.body1.weight
                color: {
                    const t = group.gcolors;
                    if (!segment.enabled)
                        return segment._checked ? t.textSecondary : t.textHint;
                    if (segment._checked) return t.textBrandHeavy;
                    return segment.hovered ? t.textPrimary : t.textComplementary;
                }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            background: Rectangle {
                border.width: 1
                border.color: {
                    const t = group.gcolors;
                    if (!segment.enabled)
                        return segment._checked ? t.lineGenericAccent : t.lineGeneric;
                    return segment._checked ? t.lineBrand : t.lineGeneric;
                }
                color: {
                    const t = group.gcolors;
                    if (!segment.enabled)
                        return segment._checked ? t.baseGenericAccent : t.baseGeneric;
                    if (segment._checked) return t.baseSelection;
                    return segment.hovered ? t.baseSimpleHover : "transparent";
                }
                topLeftRadius: segment._first ? group._radius : 0
                bottomLeftRadius: segment._first ? group._radius : 0
                topRightRadius: segment._last ? group._radius : 0
                bottomRightRadius: segment._last ? group._radius : 0
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
