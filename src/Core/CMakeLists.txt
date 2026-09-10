qt_add_library(qgravityui_core STATIC)

qt_add_qml_module(qgravityui_core
    URI QGravityUI.Core
    VERSION 1.0
    SOURCES
        qgravityuienums.h
        qgravityuienums.cpp
        ginputmode.h
        ginputmode.cpp
        gthemescope.h
        gthemescope.cpp
        gclipboard.h
        gclipboard.cpp
)

target_link_libraries(qgravityui_core PUBLIC Qt6::Quick)
# Split so the export set can be installed: a bare source path is not valid
# in an exported target.
include(GNUInstallDirs)
target_include_directories(qgravityui_core PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/qgravityui>
)

# Guarded like every other install rule: a parent project's
# `cmake --install` must not sprout our headers in its prefix.
if(QGRAVITYUI_INSTALL)
    install(FILES qgravityuienums.h ginputmode.h gthemescope.h gclipboard.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qgravityui
    )
endif()
