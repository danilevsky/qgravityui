pragma Singleton
import QtQuick
import QGravityUI.Core

// Type scale ported from @gravity-ui/uikit 7.49.0 (--g-text-*-font-size /
// --g-text-*-line-height / --g-text-*-font-weight). Font family per
// --g-font-family-sans ("Inter" first).
//
// Inter ships with the module (fonts/, OFL) and registers itself here rather
// than from main.cpp: linking QGravityUI.Tokens is then all an application
// has to do. Only the two weights fonts.css actually loads are bundled -- 400
// and 600 -- because those are the only two the scale ever asks for.
QtObject {
    readonly property FontLoader _regular: FontLoader {
        source: Qt.resolvedUrl("fonts/Inter-Regular.ttf")
    }

    readonly property FontLoader _semiBold: FontLoader {
        source: Qt.resolvedUrl("fonts/Inter-SemiBold.ttf")
    }

    // Falls back to the name if loading failed, so text still renders in
    // whatever the system resolves "Inter" to.
    readonly property string fontFamily: _regular.status === FontLoader.Ready
                                         ? _regular.font.family
                                         : "Inter"
    readonly property string monoFontFamily: "Menlo"

    readonly property TypeStyle body1: TypeStyle { size: 13; lineHeight: 18; weight: Font.Normal }
    readonly property TypeStyle body2: TypeStyle { size: 15; lineHeight: 20; weight: Font.Normal }
    readonly property TypeStyle body3: TypeStyle { size: 17; lineHeight: 24; weight: Font.Normal }
    readonly property TypeStyle bodyShort: TypeStyle { size: 13; lineHeight: 16; weight: Font.Normal }

    readonly property TypeStyle caption1: TypeStyle { size: 9;  lineHeight: 12; weight: Font.Normal }
    readonly property TypeStyle caption2: TypeStyle { size: 11; lineHeight: 16; weight: Font.Normal }

    readonly property TypeStyle header1: TypeStyle { size: 20; lineHeight: 24; weight: Font.DemiBold }
    readonly property TypeStyle header2: TypeStyle { size: 24; lineHeight: 28; weight: Font.DemiBold }

    readonly property TypeStyle subheader1: TypeStyle { size: 13; lineHeight: 18; weight: Font.DemiBold }
    readonly property TypeStyle subheader2: TypeStyle { size: 15; lineHeight: 20; weight: Font.DemiBold }
    readonly property TypeStyle subheader3: TypeStyle { size: 17; lineHeight: 24; weight: Font.DemiBold }

    readonly property TypeStyle display1: TypeStyle { size: 28; lineHeight: 36; weight: Font.DemiBold }
    readonly property TypeStyle display2: TypeStyle { size: 32; lineHeight: 40; weight: Font.DemiBold }
    readonly property TypeStyle display3: TypeStyle { size: 40; lineHeight: 48; weight: Font.DemiBold }
    readonly property TypeStyle display4: TypeStyle { size: 48; lineHeight: 52; weight: Font.DemiBold }

    readonly property TypeStyle code1: TypeStyle { size: 12; lineHeight: 18; weight: Font.Normal }
    readonly property TypeStyle code2: TypeStyle { size: 14; lineHeight: 20; weight: Font.Normal }
    readonly property TypeStyle code3: TypeStyle { size: 16; lineHeight: 24; weight: Font.Normal }

    // Lookup by variant. Unknown values fall back to body-1 rather than
    // failing silently at a different call site.
    function token(variant: int): TypeStyle {
        switch (variant) {
        case GVariant.Body2: return body2;
        case GVariant.Body3: return body3;
        case GVariant.BodyShort: return bodyShort;
        case GVariant.Caption1: return caption1;
        case GVariant.Caption2: return caption2;
        case GVariant.Header1: return header1;
        case GVariant.Header2: return header2;
        case GVariant.Subheader1: return subheader1;
        case GVariant.Subheader2: return subheader2;
        case GVariant.Subheader3: return subheader3;
        case GVariant.Display1: return display1;
        case GVariant.Display2: return display2;
        case GVariant.Display3: return display3;
        case GVariant.Display4: return display4;
        case GVariant.Code1: return code1;
        case GVariant.Code2: return code2;
        case GVariant.Code3: return code3;
        default: return body1;
        }
    }

    function isMono(variant: int): bool {
        return variant === GVariant.Code1 || variant === GVariant.Code2
               || variant === GVariant.Code3;
    }
}
