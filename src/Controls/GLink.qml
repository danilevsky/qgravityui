import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Link.
//   view: GLinkView.Normal (default, text-link) | Primary | Secondary
//   underline, visited
//
// There is no browsing history behind a QML link, so :visited cannot be
// detected -- set `visited` yourself if the app tracks it.
GText {
    id: link

    property int view: GLinkView.Normal
    property bool underline: false
    property bool visited: false

    signal clicked()

    readonly property bool hovered: hoverHandler.hovered

    // Overrides GText's colorRole binding: Link has its own hover and visited
    // colours, which the semantic roles do not cover.
    color: {
        const t = link.gcolors;
        if (visited)
            return hovered ? t.textLinkVisitedHover : t.textLinkVisited;
        if (hovered)
            return t.textLinkHover;
        switch (view) {
        case GLinkView.Primary: return t.textPrimary;
        case GLinkView.Secondary: return t.textSecondary;
        default: return t.textLink;
        }
    }

    font.underline: underline

    // .g-link border-radius: var(--g-focus-border-radius) -- the radius
    // exists purely so the focus ring has corners to follow.
    activeFocusOnTab: true

    GFocusRing {
        boxRadius: Metrics.focusBorderRadius
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: link.clicked()
    }
}
