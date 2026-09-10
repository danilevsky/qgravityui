qt_add_executable(qgravityui_visualtest
    main.cpp
)

set_source_files_properties(Cases.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

# Same reasoning as the gallery: a test module has no place in the library's
# URI namespace or in an install tree.
qt_add_qml_module(qgravityui_visualtest
    URI QGravityUIVisualTest
    VERSION 1.0
    QML_FILES
        Cases.qml
        Main.qml
    SOURCES
        gvisualdiff.h
        gvisualdiff.cpp
    IMPORTS
        TARGET qgravityui_core
        TARGET qgravityui_tokens
        TARGET qgravityui_controls
)

target_link_libraries(qgravityui_visualtest PRIVATE Qt6::Quick QGravityUI)

# Regenerate the baselines with --update after an intended change, then read
# the diff PNGs before committing them.
add_test(NAME visual
    COMMAND qgravityui_visualtest
            --baseline ${CMAKE_CURRENT_SOURCE_DIR}/baseline
            --out ${CMAKE_CURRENT_BINARY_DIR}/visual-out
)
