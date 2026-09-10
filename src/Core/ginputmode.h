#pragma once

#include <QObject>
#include <QtQmlIntegration>

QT_FORWARD_DECLARE_CLASS(QJSEngine)
QT_FORWARD_DECLARE_CLASS(QQmlEngine)

// The `:focus-visible` half of Gravity's focus ring.
//
// CSS draws the ring only when focus arrived from the keyboard, so a mouse
// click leaves no outline behind. The browser tracks that itself; in Qt
// nobody does, so this watches the application's input and reports which
// device moved the user last.
//
// It is built when the application object is, not when QML first reads it: a
// watcher created on first access misses the very key press that would have
// armed it -- which is exactly what happened the first time around.
//
// Read it as GInputMode.keyboardNavigation; GFocusRing already does.
class GInputMode : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool keyboardNavigation READ keyboardNavigation
                   NOTIFY keyboardNavigationChanged)

public:
    static GInputMode *instance();
    static GInputMode *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    bool keyboardNavigation() const { return m_keyboardNavigation; }

Q_SIGNALS:
    void keyboardNavigationChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    explicit GInputMode(QObject *parent = nullptr);

    void setKeyboardNavigation(bool on);

    bool m_keyboardNavigation = false;
};
