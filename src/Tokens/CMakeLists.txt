qt_add_library(qgravityui_tokens STATIC)

set_source_files_properties(Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)
set_source_files_properties(Typography.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)
set_source_files_properties(Metrics.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)
set_source_files_properties(ComponentMetrics.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(qgravityui_tokens
    URI QGravityUI.Tokens
    VERSION 1.0
    IMPORTS
        TARGET qgravityui_core
    QML_FILES
        ColorTokens.qml
        ThemeLight.qml
        ThemeLightHc.qml
        ThemeDark.qml
        ThemeDarkHc.qml
        TypeStyle.qml
        Theme.qml
        Typography.qml
        Metrics.qml
        ComponentMetrics.qml
    RESOURCES
        fonts/Inter-Regular.ttf
        fonts/Inter-SemiBold.ttf
)

target_link_libraries(qgravityui_tokens PUBLIC Qt6::Quick qgravityui_core)
