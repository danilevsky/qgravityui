#include "gclipboard.h"

#include <QClipboard>
#include <QGuiApplication>

GClipboard::GClipboard(QObject *parent)
    : QObject(parent)
{
    if (QClipboard *clipboard = QGuiApplication::clipboard())
        connect(clipboard, &QClipboard::dataChanged, this, &GClipboard::textChanged);
}

GClipboard *GClipboard::create(QQmlEngine *, QJSEngine *)
{
    return new GClipboard;
}

QString GClipboard::text() const
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    return clipboard ? clipboard->text() : QString();
}

bool GClipboard::setText(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (!clipboard)
        return false;
    clipboard->setText(text);
    return true;
}
