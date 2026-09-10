import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit Toast (one item of the Toaster stack).
//   theme: GTheme.Normal (default) | Info | Success | Warning | Danger | Utility
//
// Toast.css layers a tinted ::before over a base-background card. Both layers
// are kept: the theme tints are translucent, so collapsing them into a single
// fill makes the toast see-through against whatever it floats over.
Item {
    id: toast

    readonly property ColorTokens gcolors: Theme.palette(GThemeScope.effectiveMode)

    property int theme: GTheme.Normal
    property string title: ""
    property string content: ""
    property bool closable: true
    // 0..1, driven by the Toaster's enter animation: the row opens up to its
    // full height before the content fades in (g-toast-enter-desktop).
    property real openProgress: 1

    signal closeRequested()

    // .g-toast --_--background-color
    readonly property color _background: theme === GTheme.Normal ? toast.gcolors.baseFloat
                                                            : toast.gcolors.baseBackground

    // TITLE_ICONS -- warning and danger deliberately share one glyph upstream
    readonly property string _iconName: {
        switch (theme) {
        case GTheme.Info: return "circle-info-fill";
        case GTheme.Success: return "circle-check-fill";
        case GTheme.Warning:
        case GTheme.Danger: return "triangle-exclamation-fill";
        case GTheme.Utility: return "thunderbolt-fill";
        default: return "";
        }
    }

    // .g-toast_theme_* --_--icon-color
    readonly property color _iconColor: {
        const t = toast.gcolors;
        switch (theme) {
        case GTheme.Info: return t.textInfoHeavy;
        case GTheme.Success: return t.textPositiveHeavy;
        case GTheme.Warning: return t.textWarningHeavy;
        case GTheme.Danger: return t.textDangerHeavy;
        case GTheme.Utility: return t.textUtilityHeavy;
        default: return t.textPrimary;
        }
    }

    // .g-toast__container:before --_--container-background-color
    readonly property color _tint: {
        const t = toast.gcolors;
        switch (theme) {
        case GTheme.Info: return t.baseInfoLight;
        case GTheme.Success: return t.basePositiveLight;
        case GTheme.Warning: return t.baseWarningLight;
        case GTheme.Danger: return t.baseDangerLight;
        case GTheme.Utility: return t.baseUtilityLight;
        default: return "transparent";
        }
    }

    implicitWidth: Metrics.toastWidth
    implicitHeight: (column.implicitHeight + 2 * Metrics.toastPadding) * openProgress
    clip: true

    GSurface {
        anchors.fill: parent
        color: toast._background
        radius: Metrics.toastRadius
        shadowBlurPx: 15
        shadowOffsetY: 0
    }

    Rectangle {
        anchors.fill: parent
        radius: Metrics.toastRadius
        color: toast._tint
        visible: toast.theme !== GTheme.Normal
    }

    GIcon {
        id: themeIcon

        visible: toast._iconName !== ""
        name: toast._iconName
        // renderIconByType() draws it at a flat 20px
        size: 20
        color: toast._iconColor
        x: Metrics.toastPadding
        // .g-toast__icon-container padding-block-start
        y: Metrics.toastPadding + 2
    }

    Column {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Metrics.toastPadding
        // .g-toast__icon-container padding-inline-end
        anchors.leftMargin: Metrics.toastPadding
                            + (themeIcon.visible ? themeIcon.width + 8 : 0)
        spacing: 0

        GText {
            // .g-toast__title, with 32px kept clear for the close button
            width: parent.width - (toast.closable ? 32 : 0)
            visible: toast.title !== ""
            variant: GVariant.Subheader3
            text: toast.title
            wrapMode: Text.Wrap
        }

        Item {
            // .g-toast__content margin-block-start
            width: 1
            height: Metrics.spacing(2)
            visible: toast.title !== "" && toast.content !== ""
        }

        GText {
            width: parent.width - (toast.title === "" && toast.closable ? 32 : 0)
            visible: toast.content !== ""
            variant: GVariant.Body2
            text: toast.content
            wrapMode: Text.Wrap
        }
    }

    GButton {
        // .g-toast__btn-close: inset 16/16, same as the padding
        visible: toast.closable
        view: GView.Flat
        size: GSize.S
        icon.name: "xmark"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Metrics.toastPadding
        anchors.topMargin: Metrics.toastPadding
        onClicked: toast.closeRequested()
    }
}
