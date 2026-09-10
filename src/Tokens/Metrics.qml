pragma Singleton
import QtQuick
import QGravityUI.Core

// Spacing / radius / sizing tokens from @gravity-ui/uikit 7.49.0.
//
// The semantic face over ComponentMetrics: `heightForSize` reads better at a
// call site than `buttonHeight`, and several components share one ladder. Any
// number that the CSS --_--* protocol carries is delegated to the generated
// table rather than repeated here -- what is left are the global tokens
// (--g-spacing-base, --g-border-radius-*) and the handful of metrics upstream
// writes as ordinary rules instead of custom properties, each marked below.
QtObject {
    readonly property int spacingBase: 4

    // spacing(1) == 4px, spacing(0.5) == 2px, matching --g-spacing-N
    function spacing(n: real): real {
        return spacingBase * n;
    }

    // --g-focus-border-radius: the radius the focus ring falls back to on
    // elements that have none of their own (Link, Breadcrumbs, Disclosure).
    readonly property int focusBorderRadius: 2

    // --g-border-radius-*
    readonly property int radiusXs: 3
    readonly property int radiusS: 5
    readonly property int radiusM: 6
    readonly property int radiusL: 8
    readonly property int radiusXl: 10

    function heightForSize(size: int): int {
        return ComponentMetrics.buttonHeight(size);
    }

    // Radius scales with size: xs->xs, s->s, m->m, l->l, xl->xl
    function radiusForSize(size: int): int {
        return ComponentMetrics.buttonBorderRadius(size);
    }

    // Only xl steps up to body-2; xs..l all stay at body-1 / body-short (13px).
    function fontSizeForSize(size: int): int {
        return ComponentMetrics.buttonFontSize(size);
    }

    // Button.css --_--padding
    function buttonPadding(size: int): int {
        return ComponentMetrics.buttonPadding(size);
    }

    // Button.css --_--icon-offset (gap between icon and label)
    function buttonIconGap(size: int): int {
        return ComponentMetrics.buttonIconOffset(size);
    }

    // TextInput.css .g-text-input__control horizontal padding
    function inputPadding(size: int): int {
        return (size === GSize.L || size === GSize.Xl) ? 12 : 8;
    }

    // TextInput.css / TextArea.css .g-*__control vertical padding
    function inputVerticalPadding(size: int): int {
        switch (size) {
        case GSize.S: return 3;
        case GSize.L: return 9;
        case GSize.Xl: return 11;
        default: return 5;
        }
    }

    // Checkbox.css / Radio.css indicator box, sizes m|l|xl only
    function toggleIndicator(size: int): int {
        switch (size) {
        case GSize.L: return 17;
        case GSize.Xl: return 24;
        default: return 14;
        }
    }

    // ControlLabel.css: s/m use body-1, l/xl use body-2 -- note this differs
    // from the button/input scale, where only xl steps up.
    function controlLabelFontSize(size: int): int {
        return (size === GSize.L || size === GSize.Xl) ? 15 : 13;
    }

    // ControlLabel.css line-height per size
    function controlLabelLineHeight(size: int): int {
        switch (size) {
        case GSize.L: return 18;
        case GSize.Xl: return 25;
        default: return 15;
        }
    }

    // Spin.css: outer box per size; the ring border is always 2px.
    function spinSize(size: int): int {
        switch (size) {
        case GSize.Xs: return 16;
        case GSize.S: return 24;
        case GSize.L: return 32;
        case GSize.Xl: return 36;
        default: return 28;
        }
    }

    readonly property int spinBorder: 2

    // Loader.css: bar width per size; the centre bar is 4 bar-widths tall
    // (5->20, 7->28, 9->36) and the gap between bars equals the bar width.
    function loaderBar(size: int): int {
        switch (size) {
        case GSize.S: return 5;
        case GSize.L: return 9;
        default: return 7;
        }
    }

    function loaderHeight(size: int): int {
        return loaderBar(size) * 4;
    }

    // Label.css --_--height, sizes xxs|xs|s|m only
    function labelHeight(size: int): int {
        return ComponentMetrics.labelHeight(size);
    }

    // Label.css --_--border-radius: xxs and xs share the xs radius
    function labelRadius(size: int): int {
        return ComponentMetrics.labelBorderRadius(size);
    }

    // Label.css --_--margin-inline
    function labelMarginInline(size: int): int {
        return ComponentMetrics.labelMarginInline(size);
    }

    // Label.css --_--margin-addon-end: the inline space the text gives up to
    // a trailing addon button.
    function labelAddonMargin(size: int): int {
        return ComponentMetrics.labelMarginAddonEnd(size);
    }

    // --- Overlays -------------------------------------------------------

    // Popup.css --_--border-radius / --_--border-width
    readonly property int popupRadius: ComponentMetrics.popupBorderRadius
    readonly property int popupBorderWidth: ComponentMetrics.popupBorderWidth
    // Popup ships with offset={4} from floating-ui
    readonly property int popupDistance: 4

    // Tooltip.css: padding --g-spacing-1 --g-spacing-2, max-width 360
    readonly property int tooltipRadius: ComponentMetrics.tooltipBorderRadius
    readonly property int tooltipMaxWidth: 360

    // Menu.css line-height per size
    function menuItemHeight(size: int): int {
        switch (size) {
        case GSize.S: return 24;
        case GSize.L: return 32;
        case GSize.Xl: return 36;
        default: return 28;
        }
    }

    // Menu.css .g-menu__item padding: --g-spacing-3 for s/m, --g-spacing-4 for l/xl
    function menuItemPadding(size: int): int {
        return (size === GSize.L || size === GSize.Xl) ? spacing(4) : spacing(3);
    }

    // Menu.css .g-menu__item-icon margin
    function menuIconGap(size: int): int {
        return size === GSize.Xl ? spacing(3) : spacing(2);
    }

    // Menu.css: only xl steps up to body-2
    function menuFontSize(size: int): int {
        return size === GSize.Xl ? 15 : 13;
    }

    // Modal.css --g-modal-border-radius / --g-modal-margin
    readonly property int modalRadius: 5
    readonly property int modalMargin: 20

    // Dialog.css --_--side-padding and --_--width per size
    readonly property int dialogSidePadding: ComponentMetrics.dialogSidePadding
    function dialogWidth(size: int): int {
        return ComponentMetrics.dialogWidth(size);
    }

    // Alert.css --_--padding (s is 11px vertical, not a grid step)
    function alertVerticalPadding(size: int): int {
        return ComponentMetrics.alertPaddingBlock(size);
    }

    function alertHorizontalPadding(size: int): int {
        return ComponentMetrics.alertPaddingInline(size);
    }

    // Alert.css --_--border-radius: l breaks the token scale with a flat 12px
    function alertRadius(size: int): int {
        return ComponentMetrics.alertBorderRadius(size);
    }

    // Alert.css --_--icon-margin-inline-end
    function alertIconGap(size: int): int {
        return ComponentMetrics.alertIconMarginInlineEnd(size);
    }

    // Alert.css --_--alert-message-title-indent
    function alertTitleIndent(size: int): int {
        return ComponentMetrics.alertMessageTitleIndent(size);
    }

    // Alert.css --_--title-font-size: s has none and falls back to the body
    // size it inherits; m and l step to subheader-2 / subheader-3.
    function alertTitleVariant(size: int): int {
        switch (size) {
        case GSize.S: return GVariant.Subheader1;
        case GSize.L: return GVariant.Subheader3;
        default: return GVariant.Subheader2;
        }
    }

    // Alert.css --_--message-font-size
    function alertMessageVariant(size: int): int {
        return size === GSize.L ? GVariant.Body2 : GVariant.Body1;
    }

    // Alert.css --_--close-btn-margin
    function alertCloseMargin(size: int): int {
        return ComponentMetrics.alertCloseBtnMargin(size);
    }

    // Sheet.css: the rounded top, the grabber and the bar it sits in.
    // Only --_--top-height is a custom property; the rest are plain rules.
    readonly property int sheetRadius: 20
    readonly property int sheetTopHeight: ComponentMetrics.sheetTopHeight
    readonly property int sheetGrabberWidth: 40
    readonly property int sheetGrabberHeight: 4
    readonly property int sheetContentPadding: 10

    // Drawer.css / Sheet.css both slide over 300ms
    readonly property int drawerDuration: 300

    // Toast.css / ToastList.css
    readonly property int toastWidth: ComponentMetrics.toasterWidth
    readonly property int toastGap: ComponentMetrics.toastItemGap
    readonly property int toastPadding: ComponentMetrics.toastItemPadding
    readonly property int toastRadius: 8

    // SelectControl.css: heights match the input scale, the trailing chevron
    // gets --_--text-right-padding of room.
    function selectPadding(size: int): int {
        return ComponentMetrics.selectControlTextRightPadding(size);
    }

    // --- Data display and navigation -------------------------------------

    // Avatar.css --_--size, its own 7-step scale
    function avatarSize(size: int): int {
        return ComponentMetrics.avatarSize(size);
    }

    // Avatar.css .g-avatar_shape_square --_--border-radius
    function avatarRadius(size: int): int {
        switch (size) {
        case GSize.S: return radiusS;
        case GSize.M: return radiusM;
        case GSize.L: return radiusL;
        case GSize.Xl: return radiusXl;
        default: return radiusXs; // 3xs, 2xs, xs
        }
    }

    // Avatar.css --_--border-width / --_--inner-border-width
    function avatarBorderWidth(size: int): real {
        return ComponentMetrics.avatarBorderWidth(size);
    }

    function avatarInnerBorderWidth(size: int): real {
        return ComponentMetrics.avatarInnerBorderWidth(size);
    }

    // Avatar.css font block: caption for the small end, subheader from m up
    function avatarTextVariant(size: int): int {
        switch (size) {
        case GSize.S: return GVariant.Caption2;
        case GSize.M:
        case GSize.L: return GVariant.Subheader1;
        case GSize.Xl: return GVariant.Subheader2;
        default: return GVariant.Caption1; // 3xs, 2xs, xs
        }
    }

    // Progress.css .g-progress_size_*
    function progressHeight(size: int): int {
        switch (size) {
        case GSize.Xs: return 4;
        case GSize.S: return 10;
        default: return 20;
        }
    }

    readonly property int progressRadius: 3

    // Breadcrumbs.css .g-breadcrumbs__item / __divider
    readonly property int breadcrumbHeight: 24

    // Tabs: .g-tab-list_size_* --_--item-height / --_--item-gap /
    // --_--item-border-width
    function tabsHeight(size: int): int {
        return ComponentMetrics.tabListItemHeight(size);
    }

    function tabsGap(size: int): int {
        return ComponentMetrics.tabListItemGap(size);
    }

    function tabsBorderWidth(size: int): int {
        return ComponentMetrics.tabListItemBorderWidth(size);
    }

    function tabsVariant(size: int): int {
        switch (size) {
        case GSize.L: return GVariant.Body2;
        case GSize.Xl: return GVariant.Subheader3;
        default: return GVariant.Body1;
        }
    }

    // Disclosure.css: same three steps as Tabs, and an 8px trigger gap
    function disclosureVariant(size: int): int {
        switch (size) {
        case GSize.L: return GVariant.Body2;
        case GSize.Xl: return GVariant.Subheader3;
        default: return GVariant.Body1;
        }
    }

    readonly property int disclosureGap: 8

    // DefinitionList.css --_--term-width / --_--item-block-start
    readonly property int definitionTermWidth: ComponentMetrics.definitionListTermWidth

    // Table.css .g-table__cell: 11px top, 10px bottom, --g-spacing-2 inline
    readonly property int tableCellPaddingTop: 11
    readonly property int tableCellPaddingBottom: 10
    readonly property int tableCellLineHeight: 18

    // Pagination.css .g-pagination__pagination-item margin-inline-end
    readonly property int paginationGap: 4

    // PinInput.css --_--item-width / --_--gap: cells are 22/26/34/42 wide
    // against the input heights, so they are not square.
    function pinInputCellWidth(size: int): int {
        return ComponentMetrics.pinInputItemWidth(size);
    }

    function pinInputGap(size: int): int {
        return ComponentMetrics.pinInputGap(size);
    }

    // AvatarStack.css --_--overlap: how far each avatar slides under the one
    // before it.
    function avatarStackOverlap(size: int): int {
        switch (size) {
        case GSize.S: return spacing(1);
        case GSize.L: return spacing(3);
        default: return spacing(2);
        }
    }

    // Hotkey.css .g-hotkey padding -- a plain rule, not a custom property
    readonly property int hotkeyPaddingBlock: 1
    readonly property int hotkeyPaddingInline: 5

    // Accordion.css .g-accordion_size_* border-radius
    function accordionRadius(size: int): int {
        switch (size) {
        case GSize.L: return radiusL;
        case GSize.Xl: return radiusXl;
        default: return radiusM;
        }
    }

    // AccordionSummary.css .g-accordion-summary__trigger padding-block
    function accordionSummaryPaddingBlock(size: int): int {
        switch (size) {
        case GSize.L: return spacing(2);
        case GSize.Xl: return spacing(3);
        default: return 5;
        }
    }

    function accordionSummaryVariant(size: int): int {
        return size === GSize.M ? GVariant.Subheader1 : GVariant.Subheader2;
    }

    // AccordionItem.css .g-accordion-item__details padding-block
    function accordionDetailsPaddingBottom(size: int): int {
        switch (size) {
        case GSize.L: return spacing(3);
        case GSize.Xl: return spacing(3);
        default: return spacing(2);
        }
    }

    // TocItem.css .g-toc-item__section-link
    readonly property int tocLinkPaddingBlock: 6
    readonly property int tocLinkPaddingInline: 12
    readonly property int tocLinkMinHeight: 18
    readonly property int tocMarkerWidth: 2
    readonly property int tocDepthIndent: 12

    // Stepper.css --_--text-max-width and the 16px step icon
    readonly property int stepperTextMaxWidth: ComponentMetrics.stepperTextMaxWidth
    readonly property int stepperIconSize: 16

    // User.css --_--avatar-offset
    function userGap(size: int): int {
        return ComponentMetrics.userAvatarOffset(size);
    }

    // PlaceholderContainer.css writes plain rules, not --_--* properties, so
    // its four ladders are transcribed here. `direction` matters for two of
    // them: the promo step pads like `s` in a column and the body caps differ.
    function placeholderPadding(size: int, direction: int): int {
        if (size === GPlaceholderSize.S)
            return spacing(5);
        if (size === GPlaceholderSize.Promo && direction === GDirection.Vertical)
            return spacing(5);
        return spacing(7);
    }

    function placeholderBodyMaxWidth(size: int, direction: int): int {
        if (direction === GDirection.Vertical) {
            switch (size) {
            case GPlaceholderSize.L: return 430;
            case GPlaceholderSize.Promo: return 430;
            default: return 320;
            }
        }
        switch (size) {
        case GPlaceholderSize.S: return 320;
        case GPlaceholderSize.M: return 430;
        default: return 600;
        }
    }

    // In a row this is the image's width; in a column its maximum height.
    function placeholderImageSize(size: int): int {
        switch (size) {
        case GPlaceholderSize.S: return 100;
        case GPlaceholderSize.M: return 150;
        default: return 230;
        }
    }

    // .g-placeholder-container__content margin-inline-start
    function placeholderImageGap(size: int): int {
        switch (size) {
        case GPlaceholderSize.S: return spacing(5);
        case GPlaceholderSize.M: return spacing(7);
        default: return spacing(10);
        }
    }

    // min-height of the content column, row direction only; promo drops it
    function placeholderContentMinHeight(size: int): int {
        switch (size) {
        case GPlaceholderSize.S: return 130;
        case GPlaceholderSize.M: return 180;
        case GPlaceholderSize.L: return 320;
        default: return 0;
        }
    }

    // .g-placeholder-container__description margin-block-start
    function placeholderDescriptionIndent(size: int): int {
        switch (size) {
        case GPlaceholderSize.S: return spacing(1);
        case GPlaceholderSize.M: return spacing(2);
        default: return spacing(3);
        }
    }

    // useList/constants.ts modToHeight: a list row is taller when it carries
    // a subtitle, and the two ladders are unrelated to the control heights.
    function listItemHeight(size: int, withSubtitle: bool): int {
        if (withSubtitle) {
            switch (size) {
            case GSize.L: return 52;
            case GSize.Xl: return 62;
            default: return 44;
            }
        }
        switch (size) {
        case GSize.S: return 22;
        case GSize.L: return 34;
        case GSize.Xl: return 44;
        default: return 26;
        }
    }

    // .g-list-item-view_radius_*
    function listItemRadius(size: int): int {
        switch (size) {
        case GSize.S: return 3;
        case GSize.L: return 6;
        case GSize.Xl: return 8;
        default: return 5;
        }
    }

    // Palette.css .g-palette_size_* .g-palette__option font-size -- the cell
    // holds an emoji, so it is sized apart from the button's own label scale.
    function paletteFontSize(size: int): int {
        switch (size) {
        case GSize.Xs: return 14;
        case GSize.S: return 16;
        case GSize.L: return 20;
        case GSize.Xl: return 22;
        default: return 17;
        }
    }

    function placeholderTitleVariant(size: int): int {
        switch (size) {
        case GPlaceholderSize.S: return GVariant.Subheader1;
        case GPlaceholderSize.M: return GVariant.Subheader2;
        case GPlaceholderSize.L: return GVariant.Subheader3;
        default: return GVariant.Header1;
        }
    }
}
