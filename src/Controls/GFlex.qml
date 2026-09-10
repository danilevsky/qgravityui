import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Flex, trimmed to what QML already does natively.
//
//   direction: GDirection.Horizontal (default) | Vertical
//   gap:       in --g-spacing units, like upstream -- gap: 2 is 8px
//
// Deliberately not ported: justifyContent / alignItems / grow / shrink /
// basis. QML has no flexbox, and Qt ships an actual layout engine
// (QtQuick.Layouts) whose attached properties -- Layout.alignment,
// Layout.fillWidth -- already cover those. Reimplementing them on top of a
// positioner would be a worse copy of something the platform provides.
//
// Wrapping follows Flow: a Flex with a bound width wraps, an unbounded one
// stays on a single line. Flow keeps one spacing for both axes, so there is
// no separate gapRow.
Flow {
    id: flex

    property int direction: GDirection.Horizontal
    property real gap: 0

    flow: direction === GDirection.Vertical ? Flow.TopToBottom : Flow.LeftToRight
    spacing: Metrics.spacing(gap)
}
