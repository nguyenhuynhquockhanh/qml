#include "../CanTelemetryDecoder.h"
#include "../EcuDataModel.h"

#include <QCoreApplication>
#include <QDebug>

static bool check(bool condition, const char *message)
{
    if (!condition)
        qCritical() << message;
    return condition;
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    EcuDataModel model;
    CanTelemetryDecoder decoder(&model, 280.0);
    can_frame frame = {};

    frame.can_id = 0x020;
    frame.can_dlc = 1;
    frame.data[0] = 1;
    if (!check(decoder.applyFrame(frame) == CanTelemetryDecoder::Braking
               && model.braking(), "brake-on frame failed"))
        return 1;
    frame.data[0] = 0;
    decoder.applyFrame(frame);
    if (!check(!model.braking(), "brake-off frame failed"))
        return 1;

    frame = {};
    frame.can_id = 0x030;
    frame.can_dlc = 3;
    frame.data[0] = 49;
    frame.data[1] = 50;
    frame.data[2] = 1; // Front sonar must not affect blind spots.
    if (!check(decoder.applyFrame(frame) == CanTelemetryDecoder::BlindSpots
               && model.blindLeft() && !model.blindRight(),
               "left/right sonar threshold failed"))
        return 1;
    frame.data[0] = 255;
    frame.data[1] = 0;
    decoder.applyFrame(frame);
    if (!check(!model.blindLeft() && !model.blindRight(),
               "sonar sentinel or zero distance failed"))
        return 1;
    frame.data[0] = 1;
    frame.data[1] = 49;
    decoder.applyFrame(frame);
    if (!check(model.blindLeft() && model.blindRight(),
               "valid near-object distances failed"))
        return 1;

    frame = {};
    frame.can_id = 0x080;
    frame.can_dlc = 8;
    frame.data[0] = 0x8c; // 140 RPM little-endian -> 120 km/h.
    frame.data[1] = 0x00;
    if (!check(decoder.applyFrame(frame) == CanTelemetryDecoder::Motion
               && model.rpm() == 140 && model.speed() == 120,
               "motor RPM to simulated km/h failed"))
        return 1;
    frame.data[0] = 0x18; // 280 RPM -> 240 km/h.
    frame.data[1] = 0x01;
    decoder.applyFrame(frame);
    if (!check(model.rpm() == 280 && model.speed() == 240,
               "full-scale encoder mapping failed"))
        return 1;

    frame.data[0] = 0x9c; // -100 RPM: reversed encoder direction.
    frame.data[1] = 0xff;
    decoder.applyFrame(frame);
    if (!check(model.rpm() == 100 && model.speed() == 86,
               "negative encoder direction failed"))
        return 1;

    frame.data[0] = 0x18;
    frame.data[1] = 0x01;
    decoder.applyFrame(frame);

    frame.can_id = 0x080 | CAN_RTR_FLAG;
    frame.data[0] = 0;
    frame.data[1] = 0;
    if (!check(decoder.applyFrame(frame) == CanTelemetryDecoder::Ignored
               && model.rpm() == 280, "remote request changed RPM"))
        return 1;
    frame.can_id = 0x080;
    frame.can_dlc = 1;
    if (!check(decoder.applyFrame(frame) == CanTelemetryDecoder::Ignored
               && model.rpm() == 280, "short encoder frame changed RPM"))
        return 1;

    model.clear();
    if (!check(model.speed() == 0 && model.rpm() == 0 && !model.braking()
               && !model.blindLeft() && !model.blindRight(),
               "stale-state reset failed"))
        return 1;

    qInfo() << "CAN decoder tests passed";
    return 0;
}
