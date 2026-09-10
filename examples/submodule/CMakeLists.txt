# The smallest thing that proves the submodule route works: a project that
# adds this repository with add_subdirectory() and links one target.
#
#   cmake -B build examples/submodule
#   cmake --build build
#   build/subapp --shot out.png
#
# In a real project the source would sit in third_party/QGravityUI as a git
# submodule and the path below would be `third_party/QGravityUI`; here it is
# the repository this file lives in, which is what makes it a regression test
# of the contract rather than documentation of it.
cmake_minimum_required(VERSION 3.21)

project(QGravityUISubmoduleExample LANGUAGES CXX)

find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick)

qt_standard_project_setup(REQUIRES 6.11)

# Second argument only because the source is outside this project's tree; a
# real `add_subdirectory(third_party/QGravityUI)` needs no binary dir.
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../.. qgravityui)

qt_add_executable(subapp main.cpp)

qt_add_qml_module(subapp
    URI SubApp
    VERSION 1.0
    QML_FILES Main.qml
)

# One target. It carries the four module libraries, their static QML plugins
# and the plugin init objects, so there is no import path to set and no
# IMPORTS list to repeat.
target_link_libraries(subapp PRIVATE Qt6::Quick QGravityUI)
