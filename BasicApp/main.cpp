#include <QGuiApplication>
#include <QDebug>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QSurfaceFormat>
#include "EcuDataModel.h"
#include "CanTelemetrySource.h"
#include <cmath>

namespace {

bool usesEglfs(int argc, char *argv[])
{
    for (int i = 1; i + 1 < argc; ++i) {
        if (qstrcmp(argv[i], "-platform") == 0
                && QByteArray(argv[i + 1]).startsWith("eglfs"))
            return true;
    }

    return qgetenv("QT_QPA_PLATFORM").startsWith("eglfs");
}

class DashboardImageProvider : public QQuickImageProvider
{
public:
    explicit DashboardImageProvider(const QString &assetDirectory)
        : QQuickImageProvider(QQuickImageProvider::Image)
        , m_assetDirectory(assetDirectory)
    {
    }

    QImage requestImage(const QString &id, QSize *size,
                        const QSize &requestedSize) override
    {
        Q_UNUSED(requestedSize)

        const QImage source(m_assetDirectory + QLatin1Char('/') + id);
        if (source.isNull()) {
            qWarning() << "Cannot load dashboard image:" << id;
            if (size)
                *size = QSize();
            return QImage();
        }

        // Qt Quick tren image Pi nay doi PNG ARGB32 sang ARGB32_Premultiplied
        // bang QThreadPool va co the deadlock. Tao dung format dich truc tiep
        // de texture factory dua anh len GPU ma khong convert song song.
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

private:
    QString m_assetDirectory;
};

} // namespace

int main(int argc, char *argv[])
{
    const bool eglfs = usesEglfs(argc, argv);

    // Tren Raspberry Pi, khoa Qt Quick vao EGLFS KMS + OpenGL ES. Render loop
    // basic van ve bang GPU nhung khong tao them QSG render thread.
    if (eglfs) {
        qputenv("QT_QPA_EGLFS_INTEGRATION", "eglfs_kms");
        qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");
        qputenv("QSG_RENDER_LOOP", "basic");

        QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);

        QSurfaceFormat format;
        format.setRenderableType(QSurfaceFormat::OpenGLES);
        format.setVersion(2, 0);
        format.setSwapBehavior(QSurfaceFormat::DoubleBuffer);
        format.setSwapInterval(1);
        QSurfaceFormat::setDefaultFormat(format);
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::OpenGL);

    QGuiApplication app(argc, argv);

    // can0 do Linux/MCP2515 cung cap; encoder 280 RPM = 240 km/h mo phong.
    const QByteArray configuredInterface = qgetenv("ECU_CAN_INTERFACE");
    const QString interfaceName = configuredInterface.isEmpty()
            ? QStringLiteral("can0")
            : QString::fromLocal8Bit(configuredInterface);
    bool calibrationOk = false;
    const double configuredRpm = qgetenv("ECU_MOTOR_RPM_AT_240KMH")
            .toDouble(&calibrationOk);
    const double motorRpmAt240Kmh = calibrationOk
            && std::isfinite(configuredRpm) && configuredRpm > 0
            ? configuredRpm : 280.0;
    EcuDataModel ecuData;
    CanTelemetrySource canSource(&ecuData, interfaceName, motorRpmAt240Kmh);
    canSource.start();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("piEglfs"), eglfs);
    engine.rootContext()->setContextProperty(QStringLiteral("ecuTelemetry"),
                                             &ecuData);
    if (eglfs) {
        engine.addImageProvider(QStringLiteral("dashboard"),
                                new DashboardImageProvider(
                                    QCoreApplication::applicationDirPath()
                                    + QStringLiteral("/images")));
    }

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
