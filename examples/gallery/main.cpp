#include <QDebug>
#include <QGuiApplication>
#include <QKeyEvent>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>
#include <QWindow>

namespace {

// Dev affordance: `qgravityui_gallery --tab N` posts N real Tab presses once the
// window is up. The focus ring is deliberately invisible until the keyboard
// moves focus, so a screenshot of it needs an actual key event -- there is no
// way to fake the state from QML, and faking it would not test the path.
void postTabs(QQmlApplicationEngine *engine, int count)
{
    const QList<QObject *> roots = engine->rootObjects();
    if (roots.isEmpty()) {
        qWarning("--tab: no root object");
        return;
    }
    auto *window = qobject_cast<QWindow *>(roots.first());
    if (!window) {
        qWarning("--tab: root is not a window");
        return;
    }
    qInfo("--tab: sending %d Tab presses", count);
    for (int i = 0; i < count; ++i) {
        QKeyEvent press(QEvent::KeyPress, Qt::Key_Tab, Qt::NoModifier);
        QKeyEvent release(QEvent::KeyRelease, Qt::Key_Tab, Qt::NoModifier);
        QCoreApplication::sendEvent(window, &press);
        QCoreApplication::sendEvent(window, &release);
    }
}

// Popups live in the window overlay, which grabToImage() cannot reach: it is
// a C++ QQuickRootItem with no QML engine behind it. QQuickWindow can grab
// itself, though, so this is how an open dialog or drawer gets screenshotted.
void grabWindow(QQmlApplicationEngine *engine, const QString &path)
{
    const QList<QObject *> roots = engine->rootObjects();
    if (roots.isEmpty()) {
        qWarning("--shot-window: no root object");
        return;
    }
    auto *window = qobject_cast<QQuickWindow *>(roots.first());
    if (!window) {
        qWarning("--shot-window: root is not a QQuickWindow");
        return;
    }
    if (!window->grabWindow().save(path))
        qWarning("--shot-window: could not write %s", qPrintable(path));
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

    engine.loadFromModule("QGravityUIGallery", "Main");

    const QStringList args = app.arguments();
    const int tabIndex = args.indexOf(QStringLiteral("--tab"));
    if (tabIndex != -1 && tabIndex + 1 < args.size()) {
        const int count = args.at(tabIndex + 1).toInt();
        QTimer::singleShot(400, &app, [&engine, count]() { postTabs(&engine, count); });
    }

    const int shotIndex = args.indexOf(QStringLiteral("--shot-window"));
    if (shotIndex != -1 && shotIndex + 1 < args.size()) {
        const QString path = args.at(shotIndex + 1);
        // Counted from the first frame, not from startup. QML Timers run off
        // the animation driver, so `--open` and the slide it starts only
        // begin once the scene is rendering; a wall-clock delay from main()
        // races that and catches overlays mid-animation.
        const QList<QObject *> roots = engine.rootObjects();
        auto *window = roots.isEmpty()
                ? nullptr
                : qobject_cast<QQuickWindow *>(roots.first());
        if (window) {
            QObject::connect(
                window, &QQuickWindow::frameSwapped, &app,
                [&engine, path]() {
                    QTimer::singleShot(1200, &engine,
                                       [&engine, path]() { grabWindow(&engine, path); });
                },
                Qt::SingleShotConnection);
        } else {
            qWarning("--shot-window: root is not a QQuickWindow");
        }
    }

    return app.exec();
}
