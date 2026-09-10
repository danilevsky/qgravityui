#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, [&app]() { app.exit(-1); },
        Qt::QueuedConnection);

    engine.addImportPath(QStringLiteral(QGRAVITYUI_QML_DIR));
    engine.loadFromModule("Consumer", "Main");

    return app.exec();
}
