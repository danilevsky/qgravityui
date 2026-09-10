# svgs/*.svg is a generated list: see tools/gen-icons/gen_icons.py
include(icons.cmake)

qt_add_library(qgravityui_icons STATIC)

set_source_files_properties(Icons.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(qgravityui_icons
    URI QGravityUI.Icons
    VERSION 1.0
    QML_FILES
        IconCatalog.qml
        Icons.qml
    RESOURCES
        ${GRAVITY_ICON_FILES}
)

target_link_libraries(qgravityui_icons PUBLIC Qt6::Quick)
