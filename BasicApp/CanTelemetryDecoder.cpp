#include "CanTelemetryDecoder.h"
#include "EcuDataModel.h"

CanTelemetryDecoder::CanTelemetryDecoder(EcuDataModel *model,
                                         double motorRpmAt240Kmh)
    : m_model(model), m_motorRpmAt240Kmh(motorRpmAt240Kmh)
{
}

CanTelemetryDecoder::FrameKind CanTelemetryDecoder::applyFrame(
        const can_frame &frame)
{
    if (frame.can_id & (CAN_EFF_FLAG | CAN_RTR_FLAG | CAN_ERR_FLAG))
        return Ignored;

    switch (frame.can_id & CAN_SFF_MASK) {
    case 0x020: // AEB/brake: byte 0, 0=off, nonzero=on.
        if (frame.can_dlc < 1)
            return Ignored;
        m_model->setBraking(frame.data[0] != 0);
        return Braking;

    case 0x030: // Sieu am: byte 0 trai, byte 1 phai, byte 2 phia truoc.
        if (frame.can_dlc < 3)
            return Ignored;
        m_model->setBlindDistances(frame.data[0], frame.data[1]);
        return BlindSpots;

    case 0x080: { // STM32: int16 little-endian actualRpm o byte 0..1.
        if (frame.can_dlc < 2)
            return Ignored;
        const quint16 raw = quint16(frame.data[0])
                | (quint16(frame.data[1]) << 8);
        const qint16 signedMotorRpm = qint16(raw);
        // Chieu lap encoder cua xe hien tai cho RPM am khi xe chay toi.
        // Cluster chi hien do lon toc do; van giu payload signed de tuong thich.
        const double motorRpm = qAbs(qint32(signedMotorRpm));
        // Ban mo phong: 280 RPM motor tuong ung 240 km/h tren dong ho.
        const double speedKmh = motorRpm * 240.0 / m_motorRpmAt240Kmh;
        m_model->setMotion(speedKmh, motorRpm);
        return Motion;
    }

    default:
        return Ignored;
    }
}
