import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Avatar.
//   size:  GSize.Xxxs|Xxs|Xs|S|M|L|Xl -> 16/20/24/28/32/42/50
//   shape: GShape.Circle (default) | Square
//   view:  GView.Filled (default) | Outlined
//   theme: GTheme.Normal (default) | Brand
//
// Content is the first of imageSource / iconName / text that is set, which is
// the order Avatar resolves them in.
Rectangle {
    id: avatar

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int size: GSize.M
    property int shape: GShape.Circle
    property int view: GView.Filled
    property int theme: GTheme.Normal

    property string text: ""
    property string iconName: ""
    property url imageSource

    readonly property int _side: Metrics.avatarSize(size)

    readonly property bool _outlined: view === GView.Outlined
    readonly property bool _brand: theme === GTheme.Brand

    // Three typed colours rather than one `var` spec: the children read these
    // while the root is still being built, and an object-literal binding is
    // not guaranteed to have run by then -- it hands out undefined instead.
    readonly property color _bg: _outlined
                                 ? avatar.gcolors.baseBackground
                                 : (_brand ? avatar.gcolors.baseBrand : avatar.gcolors.baseMiscLight)
    readonly property color _line: _brand ? avatar.gcolors.textBrand : avatar.gcolors.textMisc
    readonly property color _fg: _brand
                                 ? (_outlined ? avatar.gcolors.textBrand : avatar.gcolors.textBrandContrast)
                                 : avatar.gcolors.textMisc

    implicitWidth: _side
    implicitHeight: _side

    radius: shape === GShape.Circle ? _side / 2 : Metrics.avatarRadius(size)
    color: _bg
    clip: true

    Image {
        anchors.fill: parent
        visible: avatar.imageSource.toString() !== ""
        source: avatar.imageSource
        // .g-avatar__image object-fit: cover
        fillMode: Image.PreserveAspectCrop
        // Same device-pixel-ratio caveat as GIcon: an explicit sourceSize is
        // taken literally, in device pixels.
        sourceSize: Qt.size(Math.round(avatar._side * Screen.devicePixelRatio),
                            Math.round(avatar._side * Screen.devicePixelRatio))
        smooth: true
    }

    GIcon {
        anchors.centerIn: parent
        visible: avatar.iconName !== "" && avatar.imageSource.toString() === ""
        name: avatar.iconName
        size: Math.round(avatar._side * 0.5)
        color: avatar._fg
    }

    GText {
        anchors.centerIn: parent
        visible: avatar.text !== "" && avatar.iconName === ""
                 && avatar.imageSource.toString() === ""
        variant: Metrics.avatarTextVariant(avatar.size)
        text: avatar.text
        color: avatar._fg
    }

    // .g-avatar_view_outlined draws two rings: a base-background inset first,
    // then the themed line on top of it.
    Rectangle {
        anchors.fill: parent
        visible: avatar._outlined
        radius: avatar.radius
        color: "transparent"
        border.width: Metrics.avatarInnerBorderWidth(avatar.size)
        border.color: avatar.gcolors.baseBackground
    }

    Rectangle {
        anchors.fill: parent
        visible: avatar._outlined
        radius: avatar.radius
        color: "transparent"
        border.width: Metrics.avatarBorderWidth(avatar.size)
        border.color: avatar._line
    }
}
