#pragma once

#include <QObject>
#include <QPointer>
#include <QtQmlIntegration>

QT_FORWARD_DECLARE_CLASS(QQuickItem)

// Gravity's ThemeProvider: a theme that applies to one subtree rather than
// the whole window -- a dark card on a light page, a light popup over a dark
// one.
//
//   Item {
//       GThemeScope.mode: GThemeMode.Dark
//       GCard { ... }        // and everything below it is dark
//   }
//
// A QML singleton cannot express this: it has exactly one value for the whole
// engine. An attached property can, because every item gets its own and can
// look upwards for an answer.
//
// `mode` is the override written on an item; -1 means "not set here".
// `effectiveMode` is what the item actually renders with: its own override,
// else the nearest ancestor's, else -1 again -- meaning "use the global
// Theme.mode". Resolution stops at the first ancestor that has an opinion, so
// nesting scopes works the way CSS nesting does.
//
// Theme.palette(mode) in QGravityUI.Tokens turns the result into a palette;
// keeping that mapping in QML is what lets this type stay in Core without
// knowing anything about tokens.
class GThemeScopeAttached : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int mode READ mode WRITE setMode RESET resetMode NOTIFY modeChanged)
    Q_PROPERTY(int effectiveMode READ effectiveMode NOTIFY effectiveModeChanged)

public:
    explicit GThemeScopeAttached(QObject *parent = nullptr);

    static constexpr int Inherit = -1;

    int mode() const { return m_mode; }
    void setMode(int mode);
    void resetMode() { setMode(Inherit); }

    int effectiveMode() const;

Q_SIGNALS:
    void modeChanged();
    void effectiveModeChanged();

private:
    void rebindParent();
    GThemeScopeAttached *parentScope() const;

    QQuickItem *m_item = nullptr;
    mutable QPointer<GThemeScopeAttached> m_parentScope;
    int m_mode = Inherit;
};

class GThemeScope : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(GThemeScopeAttached)
    QML_UNCREATABLE("GThemeScope is used through its attached properties")

public:
    using QObject::QObject;

    static GThemeScopeAttached *qmlAttachedProperties(QObject *object);
};
