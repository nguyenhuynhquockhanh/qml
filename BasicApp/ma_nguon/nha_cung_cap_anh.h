#pragma once

#include <QQuickImageProvider>
#include <QString>

class NhaCungCapAnh : public QQuickImageProvider
{
public:
    explicit NhaCungCapAnh(const QString &assetDirectory);
    QImage requestImage(const QString &id, QSize *size,
                        const QSize &requestedSize) override;

private:
    QString m_assetDirectory;
};
