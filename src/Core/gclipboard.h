#pragma once

#include <QObject>
#include <QtQmlIntegration>

QT_FORWARD_DECLARE_CLASS(QJSEngine)
QT_FORWARD_DECLARE_CLASS(QQmlEngine)

// The system clipboard, for ClipboardButton and anything else that copies.
//
// QML has no clipboard of its own -- TextEdit and TextInput each own one
// privately and expose nothing -- so this is the smallest possible wrapper
// over QGuiApplication::clipboard().
//
//   GClipboard.setText("...")   // returns false if there is no clipboard,
//                               // which happens on a headless platform
//   GClipboard.text
//
// `text` notifies on dataChanged, so a control can tell whether what it put
// there is still there.
class GClipboard : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString text READ text NOTIFY textChanged)

public:
    explicit GClipboard(QObject *parent = nullptr);

    static GClipboard *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    QString text() const;
    Q_INVOKABLE bool setText(const QString &text);

Q_SIGNALS:
    void textChanged();
};
