qt_add_library(qgravityui_navigation STATIC)

qt_add_qml_module(qgravityui_navigation
    URI QGravityUI.Navigation
    VERSION 1.0
    QML_FILES
        GNavigationItem.qml
        GNavigationAside.qml
    IMPORTS
        TARGET qgravityui_core
        TARGET qgravityui_tokens
        TARGET qgravityui_icons
        TARGET qgravityui_controls
)

target_link_libraries(qgravityui_navigation PUBLIC Qt6::Quick qgravityui_core qgravityui_tokens qgravityui_icons qgravityui_controls)
