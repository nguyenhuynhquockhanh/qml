#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QTimer>

class EcuDataModel;

// Adapter UART: chi phu trach ket noi va tach cac dong JSON. Sau nay co the
// thay bang adapter SPI, EcuDataModel va cac binding QML giu nguyen.
class UartTelemetrySource : public QObject
{
    Q_OBJECT

public:
    UartTelemetrySource(EcuDataModel *model, const QString &portName,
                        qint32 baudRate, QObject *parent = nullptr);
    ~UartTelemetrySource() override;
    void start();

private:
    void connectPort();
    void readAvailable();
    void processBuffer();
    void disconnectPort();

    EcuDataModel *m_model;
    QString m_portName;
    qint32 m_baudRate;
    int m_fd = -1;
    QSocketNotifier *m_notifier = nullptr;
    QTimer m_reconnectTimer;
    QTimer m_staleTimer;
    QByteArray m_buffer;
    QString m_lastOpenError;
};
