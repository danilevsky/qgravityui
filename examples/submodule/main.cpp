#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     [&app]() { app.exit(2); }, Qt::QueuedConnection);
    engine.loadFromModule("SubApp", "Main");
    if (engine.rootObjects().isEmpty())
        return 3;

    const QStringList args = app.arguments();
    const int shot = args.indexOf(QStringLiteral("--shot"));
    if (shot != -1 && shot + 1 < args.size()) {
        auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        const QString path = args.at(shot + 1);
        QObject::connect(window, &QQuickWindow::frameSwapped, &app, [window, path, &app]() {
            QTimer::singleShot(800, &app, [window, path, &app]() {
                app.exit(window->grabWindow().save(path) ? 0 : 4);
            });
        }, Qt::SingleShotConnection);
    }
    return app.exec();
}
