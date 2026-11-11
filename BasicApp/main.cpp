#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "ma_nguon/cau_hinh_do_hoa.h"
#include "ma_nguon/du_lieu_cum_dong_ho.h"
#include "ma_nguon/nha_cung_cap_anh.h"
#include "ma_nguon/nguon_du_lieu_can.h"

#include <cmath>

int main(int argc, char *argv[])
{
    const bool eglfs = cauHinhDoHoa(argc, argv);
    QGuiApplication app(argc, argv);

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
                                new NhaCungCapAnh(
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
