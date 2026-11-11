#include "nguon_du_lieu_can.h"
#include "du_lieu_cum_dong_ho.h"

#include <QDebug>
#include <cerrno>
#include <cstring>
#include <linux/can/raw.h>
#include <net/if.h>
#include <sys/socket.h>
#include <unistd.h>

namespace {
constexpr int reconnectMs = 2000;
constexpr int staleDataMs = 3000;
}

CanTelemetrySource::CanTelemetrySource(
        EcuDataModel *model, const QString &interfaceName,
        double motorRpmAt240Kmh, QObject *parent)
    : QObject(parent), m_model(model), m_interfaceName(interfaceName),
      m_decoder(model, motorRpmAt240Kmh)
{
    m_reconnectTimer.setInterval(reconnectMs);
    connect(&m_reconnectTimer, &QTimer::timeout,
            this, &CanTelemetrySource::connectSocket);

    for (QTimer *timer : { &m_motionStaleTimer, &m_brakeStaleTimer,
                           &m_blindStaleTimer }) {
        timer->setSingleShot(true);
        timer->setInterval(staleDataMs);
    }
    connect(&m_motionStaleTimer, &QTimer::timeout,
            m_model, &EcuDataModel::clearMotion);
    connect(&m_brakeStaleTimer, &QTimer::timeout,
            m_model, &EcuDataModel::clearBraking);
    connect(&m_blindStaleTimer, &QTimer::timeout,
            m_model, &EcuDataModel::clearBlindSpots);
}

CanTelemetrySource::~CanTelemetrySource()
{
    if (m_fd >= 0)
        ::close(m_fd);
}

void CanTelemetrySource::start()
{
    connectSocket();
    m_reconnectTimer.start();
}

void CanTelemetrySource::connectSocket()
{
    if (m_fd >= 0)
        return;

    const QByteArray name = m_interfaceName.toLocal8Bit();
    const unsigned int index = ::if_nametoindex(name.constData());
    if (!index) {
        const QString error = QString::fromLocal8Bit(std::strerror(errno));
        if (error != m_lastError) {
            m_lastError = error;
            qWarning() << "CAN interface unavailable:" << m_interfaceName << error;
        }
        return;
    }

    const int fd = ::socket(PF_CAN, SOCK_RAW | SOCK_NONBLOCK | SOCK_CLOEXEC,
                            CAN_RAW);
    if (fd < 0) {
        const QString error = QString::fromLocal8Bit(std::strerror(errno));
        if (error != m_lastError) {
            m_lastError = error;
            qWarning() << "Cannot open CAN socket:" << error;
        }
        return;
    }

    const can_filter filters[] = {
        { 0x020, CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG },
        { 0x030, CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG },
        { 0x080, CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG }
    };
    sockaddr_can address = {};
    address.can_family = AF_CAN;
    address.can_ifindex = int(index);
    if (::setsockopt(fd, SOL_CAN_RAW, CAN_RAW_FILTER, filters,
                     sizeof(filters)) == 0
            && ::bind(fd, reinterpret_cast<sockaddr *>(&address),
                      sizeof(address)) == 0) {
        m_fd = fd;
        m_lastError.clear();
        m_notifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);
        connect(m_notifier, &QSocketNotifier::activated,
                this, &CanTelemetrySource::readAvailable);
        qInfo() << "CAN telemetry connected:" << m_interfaceName;
        return;
    }

    const QString error = QString::fromLocal8Bit(std::strerror(errno));
    ::close(fd);
    if (error != m_lastError) {
        m_lastError = error;
        qWarning() << "Cannot bind CAN interface:" << m_interfaceName << error;
    }
}

void CanTelemetrySource::readAvailable()
{
    for (int i = 0; i < 32; ++i) {
        can_frame frame = {};
        const ssize_t count = ::read(m_fd, &frame, sizeof(frame));
        if (count == ssize_t(sizeof(frame))) {
            switch (m_decoder.applyFrame(frame)) {
            case CanTelemetryDecoder::Motion:
                m_motionStaleTimer.start();
                break;
            case CanTelemetryDecoder::Braking:
                m_brakeStaleTimer.start();
                break;
            case CanTelemetryDecoder::BlindSpots:
                m_blindStaleTimer.start();
                break;
            case CanTelemetryDecoder::Ignored:
                break;
            }
            continue;
        }
        if (count < 0 && errno == EINTR)
            continue;
        if (count < 0 && (errno == EAGAIN || errno == EWOULDBLOCK))
            return;
        if (count > 0)
            continue;
        disconnectSocket();
        return;
    }
}

void CanTelemetrySource::disconnectSocket()
{
    qWarning() << "CAN telemetry disconnected:" << m_interfaceName;
    m_notifier->setEnabled(false);
    m_notifier->deleteLater();
    m_notifier = nullptr;
    ::close(m_fd);
    m_fd = -1;
    m_motionStaleTimer.stop();
    m_brakeStaleTimer.stop();
    m_blindStaleTimer.stop();
    m_model->clear();
}
