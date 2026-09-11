cmake_minimum_required(VERSION 3.21)

project(qgravityui VERSION 0.4.0 LANGUAGES CXX)

# Everything below has to work in two situations: this repository configured
# on its own, and this repository dropped into somebody else's project as
# `add_subdirectory(third_party/qgravityui)`. The difference is what gets
# built and what gets touched outside our own directory scope -- a library
# has no business building demos, registering tests or installing files in
# somebody else's build.
option(QGRAVITYUI_BUILD_EXAMPLES "Build the demo gallery" ${PROJECT_IS_TOP_LEVEL})
option(QGRAVITYUI_BUILD_TESTS "Build the visual regression runner" ${PROJECT_IS_TOP_LEVEL})
option(QGRAVITYUI_INSTALL "Generate install rules for the library" ${PROJECT_IS_TOP_LEVEL})

find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick)

# Directory-scoped (AUTOMOC, the C++ standard, Qt's policy defaults), so a
# parent project keeps its own settings.
qt_standard_project_setup(REQUIRES 6.11)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# All four QML modules share one import root, so qmlimportscanner can resolve
# qgravityui.Tokens from inside qgravityui.Controls. Without it each module
# lands under its own subdirectory's binary dir and the cross-imports stop
# resolving.
#
# Rooted at CMAKE_CURRENT_BINARY_DIR rather than CMAKE_BINARY_DIR: as a
# submodule that is <consumer-build>/third_party/qgravityui/qml, and the
# consumer's own QML modules stay where the consumer put them.
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/qml)

# Handed to the parent project for its tooling -- qmllint, qmlls and Qt
# Creator want a real path on the import path even though the linked static
# modules register themselves at run time.
if(NOT PROJECT_IS_TOP_LEVEL)
    set(QGRAVITYUI_QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY} PARENT_SCOPE)
endif()
set(QGRAVITYUI_QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY})

# QML_IMPORT_PATH (not QGRAVITYUI_QML_IMPORT_PATH above) is the plain CMake
# cache variable Qt Creator's QML code model and qmlls read to resolve
# `import QGravityUI.*` for completion and "Follow Symbol" -- without it
# Creator has no way to find our modules since they're static plugins with
# no install-time qmldir next to a running binary. Only when this repo is
# the top-level project: as a subdirectory, a consumer project's own
# QML_IMPORT_PATH takes the value above via QGRAVITYUI_QML_IMPORT_PATH
# instead of being clobbered here.
if(PROJECT_IS_TOP_LEVEL)
    set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY} CACHE STRING "Qt Creator extra qml import paths" FORCE)
endif()

add_subdirectory(src)

if(QGRAVITYUI_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(QGRAVITYUI_BUILD_TESTS)
    # Only when this is the project being built: enable_testing() in a
    # subproject would hang our cases off the consumer's ctest.
    if(PROJECT_IS_TOP_LEVEL)
        enable_testing()
    endif()
    add_subdirectory(tests/visual)
endif()

if(QGRAVITYUI_INSTALL)
    include(cmake/Install.cmake)
endif()
