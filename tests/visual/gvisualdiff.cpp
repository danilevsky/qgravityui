#include "gvisualdiff.h"

#include <QColor>
#include <QDir>
#include <QFileInfo>
#include <QImage>

namespace {

QString localPath(const QUrl &url)
{
    return url.isLocalFile() ? url.toLocalFile() : url.toString();
}

} // namespace

GVisualDiff::GVisualDiff(QObject *parent)
    : QObject(parent)
{
}

bool GVisualDiff::exists(const QUrl &path) const
{
    return QFileInfo::exists(localPath(path));
}

bool GVisualDiff::makePath(const QUrl &directory) const
{
    return QDir().mkpath(localPath(directory));
}

void GVisualDiff::remove(const QUrl &path) const
{
    QFile::remove(localPath(path));
}

int GVisualDiff::compare(const QUrl &baseline, const QUrl &actual,
                         const QUrl &diff, int tolerance)
{
    QImage before(localPath(baseline));
    if (before.isNull())
        return -1;

    QImage after(localPath(actual));
    if (after.isNull() || before.size() != after.size())
        return -2;

    before = before.convertToFormat(QImage::Format_ARGB32);
    after = after.convertToFormat(QImage::Format_ARGB32);

    QImage marked = before;
    int differing = 0;

    for (int y = 0; y < before.height(); ++y) {
        const QRgb *a = reinterpret_cast<const QRgb *>(before.constScanLine(y));
        const QRgb *b = reinterpret_cast<const QRgb *>(after.constScanLine(y));
        QRgb *out = reinterpret_cast<QRgb *>(marked.scanLine(y));
        for (int x = 0; x < before.width(); ++x) {
            const bool same = qAbs(qRed(a[x]) - qRed(b[x])) <= tolerance
                    && qAbs(qGreen(a[x]) - qGreen(b[x])) <= tolerance
                    && qAbs(qBlue(a[x]) - qBlue(b[x])) <= tolerance
                    && qAbs(qAlpha(a[x]) - qAlpha(b[x])) <= tolerance;
            if (same) {
                // Dim what matched so the marks stand out.
                const QColor faded = QColor::fromRgba(a[x]).lighter(160);
                out[x] = faded.rgba();
            } else {
                out[x] = qRgb(255, 0, 255);
                ++differing;
            }
        }
    }

    if (differing > 0 && !diff.isEmpty())
        marked.save(localPath(diff));
    else if (differing == 0 && !diff.isEmpty())
        QFile::remove(localPath(diff));

    return differing;
}
