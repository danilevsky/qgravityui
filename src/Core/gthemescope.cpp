#include "gthemescope.h"

#include <QQmlEngine>
#include <QQuickItem>

GThemeScopeAttached::GThemeScopeAttached(QObject *parent)
    : QObject(parent)
    , m_item(qobject_cast<QQuickItem *>(parent))
{
    if (m_item) {
        // Reparenting moves an item under a different scope, so the answer
        // has to be recomputed rather than cached once.
        connect(m_item, &QQuickItem::parentChanged, this, [this]() {
            rebindParent();
            Q_EMIT effectiveModeChanged();
        });
    }
    rebindParent();
}

void GThemeScopeAttached::setMode(int mode)
{
    if (m_mode == mode)
        return;
    m_mode = mode;
    Q_EMIT modeChanged();
    Q_EMIT effectiveModeChanged();
}

int GThemeScopeAttached::effectiveMode() const
{
    if (m_mode != Inherit)
        return m_mode;
    if (GThemeScopeAttached *scope = parentScope())
        return scope->effectiveMode();
    return Inherit;
}

// The nearest ancestor that already has a scope attached, or the nearest one
// that gains one later. Attached objects are created on demand, so an
// ancestor that nobody has asked about has none yet -- which is why this
// creates them along the way: without that, an override written on a plain
// wrapper Item would be invisible to everything beneath it.
GThemeScopeAttached *GThemeScopeAttached::parentScope() const
{
    if (m_parentScope)
        return m_parentScope;
    if (!m_item)
        return nullptr;

    QQuickItem *parent = m_item->parentItem();
    if (!parent)
        return nullptr;

    auto *scope = qobject_cast<GThemeScopeAttached *>(
            qmlAttachedPropertiesObject<GThemeScope>(parent, true));
    if (!scope)
        return nullptr;

    m_parentScope = scope;
    connect(scope, &GThemeScopeAttached::effectiveModeChanged,
            this, &GThemeScopeAttached::effectiveModeChanged);
    return scope;
}

void GThemeScopeAttached::rebindParent()
{
    if (m_parentScope) {
        disconnect(m_parentScope, &GThemeScopeAttached::effectiveModeChanged,
                   this, &GThemeScopeAttached::effectiveModeChanged);
        m_parentScope = nullptr;
    }
    // Resolved lazily on the next read; doing it here would create attached
    // objects all the way up before anyone has asked a question.
}

GThemeScopeAttached *GThemeScope::qmlAttachedProperties(QObject *object)
{
    return new GThemeScopeAttached(object);
}
