# Install rules, kept out of the root CMakeLists so that reading it tells you
# what gets built rather than what gets packaged. Included only when
# QGRAVITYUI_INSTALL is on, which is off by default in a parent project: a
# submodule that adds files to somebody else's `cmake --install` is a bug.
#
# The four QML modules ship as static libraries plus their generated QML
# module directories. A consumer links the libraries and points the QML
# import path at the installed qml/ tree; qmlimportscanner then finds the
# qmldir files and pulls in the static plugins.

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(QGRAVITYUI_TARGETS
    qgravityui_core qgravityui_coreplugin
    qgravityui_tokens qgravityui_tokensplugin
    qgravityui_icons qgravityui_iconsplugin
    qgravityui_controls qgravityui_controlsplugin
)

# In a static build qt_add_qml_module builds more than the library itself:
# the qrc payload becomes object libraries named <target>_resources_N and each
# plugin gets a <plugin>_init that registers it. An export set has to carry
# them too or CMake refuses the install, and their number is not documented --
# so the ones that exist are collected rather than guessed at.
set(QGRAVITYUI_EXPORT_TARGETS ${QGRAVITYUI_TARGETS} QGravityUI)
foreach(_gq_target IN LISTS QGRAVITYUI_TARGETS)
    foreach(_gq_index RANGE 1 4)
        if(TARGET ${_gq_target}_resources_${_gq_index})
            list(APPEND QGRAVITYUI_EXPORT_TARGETS ${_gq_target}_resources_${_gq_index})
        endif()
    endforeach()
    # Each static plugin also has an _init object library that registers it.
    if(TARGET ${_gq_target}_init)
        list(APPEND QGRAVITYUI_EXPORT_TARGETS ${_gq_target}_init)
    endif()
endforeach()

install(TARGETS ${QGRAVITYUI_EXPORT_TARGETS}
    EXPORT QGravityUITargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    # The object libraries above export a $<TARGET_OBJECTS:...> expression,
    # which a consumer can only evaluate if the object files ship too.
    OBJECTS DESTINATION ${CMAKE_INSTALL_LIBDIR}/objects
)

# qmldir, qmltypes and the .qmlc cache live here; they are what the import
# path has to point at. The gallery and the visual-test runner declare URIs
# outside the QGravityUI.* namespace, so their module directories are
# siblings of this one and nothing has to be excluded by name.
install(DIRECTORY ${QT_QML_OUTPUT_DIRECTORY}/QGravityUI
    DESTINATION ${CMAKE_INSTALL_DATADIR}/qgravityui/qml
)

# No NAMESPACE on purpose. Each installed qmldir names its static plugin with
# a `linkTarget` line, and qmlimportscanner looks that name up verbatim when
# it decides what a consumer has to link; a QGravityUI:: prefix would make
# every one of those lookups miss and the plugin would go unregistered.
install(EXPORT QGravityUITargets
    FILE QGravityUITargets.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QGravityUI
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/QGravityUIConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/QGravityUIConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QGravityUI
    PATH_VARS CMAKE_INSTALL_DATADIR
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/QGravityUIConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMinorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/QGravityUIConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/QGravityUIConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QGravityUI
)
