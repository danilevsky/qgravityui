#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    // Native text rendering uses the platform's subpixel antialiasing, and a
    // glyph edge lands on a different LCD subpixel from one run to the next
    // -- a single flipped pixel is enough to fail a comparison. Distance
    // fields are greyscale and deterministic, which is what a baseline needs.
    QQuickWindow::setTextRenderType(QQuickWindow::QtTextRendering);

    // Pin the device pixel ratio to 1. grabToImage() honours it even when a
    // target size is given, so the same case came out 400x180 on one monitor
    // and 700x315 on another and every baseline read as "changed size".
    // Baselines have to be portable between machines and CI, and a 1:1 grab
    // is the only ratio every machine can produce.
    qputenv("QT_SCALE_FACTOR", "1");
    qputenv("QT_ENABLE_HIGHDPI_SCALING", "0");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, [&app]() { app.exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("QGravityUIVisualTest", "Main");

    return app.exec();
}
