qt_add_library(qgravityui_controls STATIC)

qt_add_qml_module(qgravityui_controls
    URI QGravityUI.Controls
    VERSION 1.0
    QML_FILES
        GText.qml
        GFocusRing.qml
        GIcon.qml
        GLink.qml
        GDivider.qml
        GFlex.qml
        GLabel.qml
        GSkeleton.qml
        GSpin.qml
        GLoader.qml
        GControlLabel.qml
        GCard.qml
        GButton.qml
        GInputBackground.qml
        GTextField.qml
        GTextArea.qml
        GNumberInput.qml
        GPinInput.qml
        GCheckbox.qml
        GSwitch.qml
        GRadio.qml
        GRadioGroup.qml
        GSegmentedRadioGroup.qml
        GSlider.qml
        GSurface.qml
        GPopup.qml
        GTooltip.qml
        GPopover.qml
        GMenuItem.qml
        GMenu.qml
        GSelect.qml
        GModal.qml
        GDialog.qml
        GAlert.qml
        GToast.qml
        GToaster.qml
        GActionTooltip.qml
        GDropdownMenu.qml
        GDrawer.qml
        GSheet.qml
        GArrowToggle.qml
        GHotkey.qml
        GHelpMark.qml
        GAvatarStack.qml
        GUserLabel.qml
        GAccordionItem.qml
        GAccordion.qml
        GToc.qml
        GStepper.qml
        GAvatar.qml
        GUser.qml
        GProgress.qml
        GBreadcrumbs.qml
        GTabs.qml
        GDisclosure.qml
        GDefinitionList.qml
        GPagination.qml
        GTable.qml
        GPlaceholderContainer.qml
        GActionsPanel.qml
        GClipboardButton.qml
        GPalette.qml
        GFilePreview.qml
        GList.qml
        GTableColumnSetup.qml
        GTreeList.qml
        GTreeSelect.qml
    IMPORTS
        TARGET qgravityui_core
        TARGET qgravityui_tokens
        TARGET qgravityui_icons
    # Writes `designersupported` into the generated qmldir; Qt Design Studio
    # refuses to instantiate types from a module that does not claim it.
    DESIGNER_SUPPORTED
)

# The Studio looks for the metainfo inside the module directory, next to the
# qmldir -- not in the source tree. Copying at configure time keeps it in the
# build tree, and the top-level install(DIRECTORY) of the qml output then
# ships it without a rule of its own.
configure_file(designer/qgravityui_controls.metainfo
    ${QT_QML_OUTPUT_DIRECTORY}/QGravityUI/Controls/designer/qgravityui_controls.metainfo
    COPYONLY
)

target_link_libraries(qgravityui_controls PUBLIC Qt6::Quick qgravityui_core qgravityui_tokens qgravityui_icons)
