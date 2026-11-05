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
#include "UartTelemetrySource.h"

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

    // Cong CH340 tren Pi thuong la /dev/ttyUSB0. Co the doi ma khong can
    // build lai: ECU_SERIAL_PORT=/dev/ttyAMA0 ECU_BAUD_RATE=115200.
    const QByteArray configuredPort = qgetenv("ECU_SERIAL_PORT");
    const QString portName = configuredPort.isEmpty()
            ? QStringLiteral("/dev/ttyUSB0")
            : QString::fromLocal8Bit(configuredPort);
    bool baudOk = false;
    const int configuredBaud = qgetenv("ECU_BAUD_RATE").toInt(&baudOk);
    const qint32 baudRate = baudOk && configuredBaud > 0
            ? configuredBaud : 115200;
    EcuDataModel ecuData;
    UartTelemetrySource uartSource(&ecuData, portName, baudRate);
    uartSource.start();

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
