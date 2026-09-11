#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

// Dev-only screenshot flag, same trick the gallery's main.cpp uses: popups
// live in the window overlay, which grabToImage() cannot reach, so grabbing
// the whole QQuickWindow is how this gets verified without eyeballing it on
// an actual screen.
namespace {
void grabWindow(QQmlApplicationEngine *engine, const QString &path)
{
    const QList<QObject *> roots = engine->rootObjects();
    if (roots.isEmpty())
        return;
    auto *window = qobject_cast<QQuickWindow *>(roots.first());
    if (!window)
        return;
    window->grabWindow().save(path);
    QCoreApplication::exit(0);
}
} // namespace

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, [&app]() { app.exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("QGravityUINavigationDemo", "Main");

    const QStringList args = app.arguments();
    const int shotIndex = args.indexOf(QStringLiteral("--shot-window"));
    if (shotIndex != -1 && shotIndex + 1 < args.size()) {
        const QString path = args.at(shotIndex + 1);
        QTimer::singleShot(600, &engine, [&engine, path]() { grabWindow(&engine, path); });
    }

    return app.exec();
}
