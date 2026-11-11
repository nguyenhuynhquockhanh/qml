#pragma once

#include <linux/can.h>

class EcuDataModel;

// Giai ma payload CAN doc lap voi socket, de kiem thu bang frame mau.
class CanTelemetryDecoder
{
public:
    enum FrameKind { Ignored, Braking, BlindSpots, Motion };

    CanTelemetryDecoder(EcuDataModel *model, double motorRpmAt240Kmh);
    FrameKind applyFrame(const can_frame &frame);

private:
    EcuDataModel *m_model;
    double m_motorRpmAt240Kmh;
};
