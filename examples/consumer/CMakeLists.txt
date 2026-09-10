# The smallest thing that proves the install tree works: a project outside
# this repository that finds the package, links the modules and imports them
# from QML.
#
#   cmake --install <build> --prefix /somewhere
#   cmake -B build examples/consumer -DCMAKE_PREFIX_PATH=/somewhere
#   cmake --build build

cmake_minimum_required(VERSION 3.21)

project(QGravityUIConsumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick)
find_package(QGravityUI 0.4 REQUIRED)

qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(qgravityui_consumer main.cpp)

qt_add_qml_module(qgravityui_consumer
    URI Consumer
    VERSION 1.0
    QML_FILES Main.qml
)

target_link_libraries(qgravityui_consumer PRIVATE Qt6::Quick QGravityUI)

# Where the installed qmldir files live, so qmlimportscanner can resolve the
# QGravityUI.* imports and link their static plugins.
set_property(TARGET qgravityui_consumer APPEND PROPERTY
    QT_QML_IMPORT_PATH "${QGravityUI_QML_DIR}"
)

# The engine needs the same path at run time.
target_compile_definitions(qgravityui_consumer PRIVATE
    QGRAVITYUI_QML_DIR="${QGravityUI_QML_DIR}"
)
