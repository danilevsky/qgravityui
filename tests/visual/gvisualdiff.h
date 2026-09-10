#pragma once

#include <QObject>
#include <QUrl>
#include <QtQmlIntegration>

// Pixel comparison for the visual regression runner.
//
// QML can render and save a case but cannot look at two PNGs and say whether
// they differ, so that part lives here. A mismatch also writes a diff image:
// the baseline dimmed, with every differing pixel painted magenta, which is
// far quicker to read than two files side by side.
class GVisualDiff : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit GVisualDiff(QObject *parent = nullptr);

    // -1: no baseline. -2: sizes differ. Otherwise the number of pixels that
    // differ by more than `tolerance` on any channel.
    Q_INVOKABLE int compare(const QUrl &baseline, const QUrl &actual,
                            const QUrl &diff, int tolerance = 0);

    Q_INVOKABLE bool exists(const QUrl &path) const;
    Q_INVOKABLE bool makePath(const QUrl &directory) const;
    Q_INVOKABLE void remove(const QUrl &path) const;
};
