#include "ginputmode.h"

#include <QCoreApplication>
#include <QEvent>
#include <QKeyEvent>
#include <QQmlEngine>

namespace {

GInputMode *g_instance = nullptr;

} // namespace

GInputMode::GInputMode(QObject *parent)
    : QObject(parent)
{
    if (QCoreApplication *app = QCoreApplication::instance())
        app->installEventFilter(this);
}

GInputMode *GInputMode::instance()
{
    if (!g_instance)
        g_instance = new GInputMode(QCoreApplication::instance());
    return g_instance;
}

GInputMode *GInputMode::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    GInputMode *mode = instance();
    // Owned by the application, not by the engine that asked for it.
    QJSEngine::setObjectOwnership(mode, QJSEngine::CppOwnership);
    return mode;
}

void GInputMode::setKeyboardNavigation(bool on)
{
    if (m_keyboardNavigation == on)
        return;
    m_keyboardNavigation = on;
    Q_EMIT keyboardNavigationChanged();
}

bool GInputMode::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched)

    switch (event->type()) {
    case QEvent::KeyPress:
        // Navigation keys only. :focus-visible is about focus *moving* by
        // keyboard, so typing into a field that already has focus must not
        // light up rings all over the window.
        switch (static_cast<QKeyEvent *>(event)->key()) {
        case Qt::Key_Tab:
        case Qt::Key_Backtab:
        case Qt::Key_Up:
        case Qt::Key_Down:
        case Qt::Key_Left:
        case Qt::Key_Right:
        case Qt::Key_Home:
        case Qt::Key_End:
        case Qt::Key_PageUp:
        case Qt::Key_PageDown:
            setKeyboardNavigation(true);
            break;
        default:
            break;
        }
        break;

    case QEvent::MouseButtonPress:
    case QEvent::TouchBegin:
    case QEvent::Wheel:
        setKeyboardNavigation(false);
        break;

    default:
        break;
    }

    // Never swallow anything: this only observes.
    return false;
}

// Runs right after the QCoreApplication object exists, so the filter is in
// place before the first event reaches anyone.
static void gravityInstallInputMode()
{
    GInputMode::instance();
}
Q_COREAPP_STARTUP_FUNCTION(gravityInstallInputMode)
