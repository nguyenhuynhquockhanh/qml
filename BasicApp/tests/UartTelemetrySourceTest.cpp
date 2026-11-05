#include "../EcuDataModel.h"
#include "../UartTelemetrySource.h"

#include <QCoreApplication>
#include <QDebug>
#include <QTimer>
#include <fcntl.h>
#include <unistd.h>
#include <cstdlib>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    const int master = ::posix_openpt(O_RDWR | O_NOCTTY);
    if (master < 0 || ::grantpt(master) != 0 || ::unlockpt(master) != 0)
        return 1;

    const char *slavePath = ::ptsname(master);
    if (!slavePath)
        return 1;

    EcuDataModel model;
    UartTelemetrySource uart(&model, QString::fromLocal8Bit(slavePath), 115200);
    uart.start();

    int result = 0;
    QTimer::singleShot(50, [&]() {
        const char first[] = "{\"spd\":87,\"brk\":1,\"snL\":49,";
        ::write(master, first, sizeof(first) - 1);
    });
    QTimer::singleShot(100, [&]() {
        const char second[] = "\"snR\":255}\n";
        ::write(master, second, sizeof(second) - 1);
    });
    QTimer::singleShot(200, [&]() {
        if (model.speed() != 87 || !model.braking()
                || !model.blindLeft() || model.blindRight())
            result = 2;
    });
    QTimer::singleShot(3300, [&]() {
        if (model.speed() != 0 || model.braking() || model.blindLeft())
            result = 3;
        const char packet[] = "{\"spd\":20,\"snR\":20}\n";
        ::write(master, packet, sizeof(packet) - 1);
    });
    QTimer::singleShot(3800, [&]() {
        if (model.speed() != 20 || !model.blindRight()) {
            qCritical() << "UART resume failed:" << model.speed() << model.blindRight();
            result = 4;
        }
        ::close(master);
    });
    QTimer::singleShot(4100, [&]() {
        if (model.speed() != 0 || model.blindRight())
            result = 5;
        app.quit();
    });
    app.exec();
    return result;
}
