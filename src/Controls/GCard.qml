import QtQuick
import QGravityUI.Core
import QtQuick.Templates as T
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Card (type="container").
//   view: GView.Outlined (default) | Filled | Raised | Clear
//   size: GSize.M (default) | L   -- radius 8 / 16, Card has its own radius scale
//
// Built on T.Pane so the card is sized by its content through
// contentWidth/contentHeight instead of reading childrenRect off an item that
// is itself anchored to the card -- that combination is a binding loop.
T.Pane {
    id: card

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int view: GView.Outlined
    property int size: GSize.M

    padding: Metrics.spacing(4)

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding

    background: GSurface {
        radius: card.size === GSize.L ? 16 : 8
        color: {
            const t = card.gcolors;
            switch (card.view) {
            case GView.Filled: return t.baseGeneric;
            case GView.Raised: return t.baseFloat;
            case GView.Clear: return "transparent";
            default: return "transparent"; // outlined
            }
        }
        borderWidth: card.view === GView.Outlined ? 1 : 0
        borderColor: card.gcolors.lineGeneric

        // .g-card_type_container.g-card_view_raised: 0 1px 5px sfx-shadow at
        // size m; size l stacks two sfx-shadow-light layers, approximated here
        // by the wider of the two.
        shadowEnabled: card.view === GView.Raised
        shadowBlurPx: card.size === GSize.L ? 13 : 5
        shadowOffsetY: 1
    }
}
