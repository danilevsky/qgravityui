import QtQuick
import QGravityUI.Core
import QtQuick.Effects
import QGravityUI.Tokens
import QGravityUI.Icons

// Port of @gravity-ui/uikit Icon.
//
// Upstream inlines an SVG from @gravity-ui/icons into the DOM and lets
// `fill: currentColor` paint it. QML has no SVG DOM, so the icon is loaded as
// an image and recoloured wholesale -- equivalent for single-colour glyphs,
// which is all of @gravity-ui/icons.
//
//   name:   an icon from the bundled set, e.g. "circle-check-fill"
//   source: any URL Qt can load, for art that is not in the set
//   svg:    raw SVG markup; wrapped into a data: URL for you
//   size:   square side in px (16 is what every uikit control passes); set
//           width/height directly for the few glyphs that are not square
Item {
    id: icon

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property string name: ""
    property url source
    property string svg: ""
    property int size: 16
    property color color: icon.gcolors.textPrimary

    implicitWidth: size
    implicitHeight: size

    readonly property real _dpr: Screen.devicePixelRatio

    // MultiEffect renders its source into a texture measured in logical
    // pixels, so on a HiDPI screen the icon lands at half resolution however
    // large sourceSize or layer.textureSize are made. The whole pipeline is
    // therefore built at device-pixel size and scaled back down, which puts
    // one texel back on one device pixel.
    Item {
        id: hires

        width: Math.max(1, Math.round(icon.width * icon._dpr))
        height: Math.max(1, Math.round(icon.height * icon._dpr))
        transform: Scale {
            xScale: 1 / icon._dpr
            yScale: 1 / icon._dpr
        }

        Image {
            id: image

            anchors.fill: parent
            source: {
                if (icon.name !== "")
                    return Icons.url(icon.name);
                if (icon.svg !== "")
                    return "data:image/svg+xml;utf8," + encodeURIComponent(icon.svg);
                return icon.source;
            }
            // SVG is rasterised at exactly sourceSize, and the box here is
            // already in device pixels. It tracks width/height rather than
            // `size` because Checkbox's tick, for one, is 8x10, not square.
            sourceSize: Qt.size(hires.width, hires.height)
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: false
        }

        MultiEffect {
            anchors.fill: image
            source: image
            // MultiEffect's colorization preserves the source luminance, so a
            // black glyph would stay black. brightness lifts it to white
            // first; alpha is untouched, so antialiased edges survive.
            brightness: 1.0
            colorization: 1.0
            colorizationColor: icon.color
        }
    }
}
