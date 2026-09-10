qt_add_executable(qgravityui_gallery
    main.cpp
)

# URI outside the QGravityUI.* namespace on purpose: the demo is not part of
# the library, and keeping it out means the install rules never have to know
# it exists.
qt_add_qml_module(qgravityui_gallery
    URI QGravityUIGallery
    VERSION 1.0
    QML_FILES
        Main.qml
    IMPORTS
        TARGET qgravityui_core
        TARGET qgravityui_tokens
        TARGET qgravityui_controls
)

target_link_libraries(qgravityui_gallery PRIVATE Qt6::Quick QGravityUI)
