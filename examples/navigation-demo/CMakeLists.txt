qt_add_executable(qgravityui_navigation_demo
    main.cpp
)

# URI outside the QGravityUI.* namespace on purpose, same reasoning as the
# gallery: this demo is not part of the library.
qt_add_qml_module(qgravityui_navigation_demo
    URI QGravityUINavigationDemo
    VERSION 1.0
    QML_FILES
        Main.qml
        pages/HomePage.qml
        pages/DashboardPage.qml
        pages/OrdersPage.qml
        pages/SettingsPage.qml
        pages/IconsPage.qml
        pages/dataloader.js
    IMPORTS
        TARGET qgravityui_core
        TARGET qgravityui_tokens
        TARGET qgravityui_controls
        TARGET qgravityui_navigation

)

target_link_libraries(qgravityui_navigation_demo PRIVATE Qt6::Quick QGravityUI)
