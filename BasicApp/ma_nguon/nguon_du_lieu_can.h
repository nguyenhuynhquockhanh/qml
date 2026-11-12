#pragma once

#include "giai_ma_can.h"

#include <QObject>
#include <QSocketNotifier>
#include <QTimer>

class EcuDataModel;

// Nhan frame CAN tu Linux SocketCAN, khong tao thread hay poll CPU.
class CanTelemetrySource : public QObject
{
    Q_OBJECT

public:
    CanTelemetrySource(EcuDataModel *model, const QString &interfaceName,
                       double motorRpmAt240Kmh,
                       QObject *parent = nullptr);
    ~CanTelemetrySource() override;
    void start();

private:
    void connectSocket();
    void readAvailable();
    void disconnectSocket(const QString &reason);

    EcuDataModel *m_model;
    QString m_interfaceName;
    CanTelemetryDecoder m_decoder;
    int m_fd = -1;
    QSocketNotifier *m_notifier = nullptr;
    QTimer m_reconnectTimer;
    QTimer m_motionStaleTimer;
    QTimer m_brakeStaleTimer;
    QTimer m_blindStaleTimer;
    QString m_lastError;
};
