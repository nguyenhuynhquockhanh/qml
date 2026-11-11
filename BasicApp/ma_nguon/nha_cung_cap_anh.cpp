#include "nha_cung_cap_anh.h"

#include <QDebug>
#include <QImage>

NhaCungCapAnh::NhaCungCapAnh(const QString &assetDirectory)
    : QQuickImageProvider(QQuickImageProvider::Image),
      m_assetDirectory(assetDirectory)
{
}

QImage NhaCungCapAnh::requestImage(const QString &id, QSize *size,
                                   const QSize &requestedSize)
{
    Q_UNUSED(requestedSize)

    const QImage source(m_assetDirectory + QLatin1Char('/') + id);
    if (source.isNull()) {
        qWarning() << "Cannot load dashboard image:" << id;
        if (size)
            *size = QSize();
        return QImage();
    }

    // Format premultiplied tranh Qt Quick tao image worker de convert tren Pi.
    QImage premultiplied(source.size(), QImage::Format_ARGB32_Premultiplied);
    for (int y = 0; y < source.height(); ++y) {
        QRgb *destination = reinterpret_cast<QRgb *>(premultiplied.scanLine(y));
        for (int x = 0; x < source.width(); ++x)
            destination[x] = qPremultiply(source.pixel(x, y));
    }

    if (size)
        *size = premultiplied.size();
    return premultiplied;
}
