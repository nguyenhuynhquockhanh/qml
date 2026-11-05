#include "UartTelemetrySource.h"
#include "EcuDataModel.h"

#include <QDebug>
#include <QDir>
#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

namespace {
constexpr int maxLineBytes = 4096;
constexpr int staleDataMs = 3000;
constexpr int reconnectMs = 2000;

speed_t serialSpeed(qint32 baudRate)
{
    switch (baudRate) {
    case 9600: return B9600;
    case 19200: return B19200;
    case 38400: return B38400;
    case 57600: return B57600;
    case 115200: return B115200;
    case 230400: return B230400;
    default: return 0;
    }
}

QString discoverSerialPort()
{
    const QDir byId(QStringLiteral("/dev/serial/by-id"));
    const QStringList names = byId.entryList(
                QDir::AllEntries | QDir::System | QDir::NoDotAndDotDot,
                QDir::Name);
    // STM32 tren Pi hien tai xuat hien qua USB CDC ACM, khong phai CH340.
    for (const QString &name : names) {
        if (name.contains(QStringLiteral("FIREPHX"), Qt::CaseInsensitive))
            return byId.absoluteFilePath(name);
    }
    if (names.size() == 1)
        return byId.absoluteFilePath(names.first());

    const QDir devices(QStringLiteral("/dev"));
    for (const QString &pattern : { QStringLiteral("ttyACM*"),
                                    QStringLiteral("ttyUSB*") }) {
        const QStringList ports = devices.entryList(
                    QStringList(pattern), QDir::System | QDir::NoDotAndDotDot,
                    QDir::Name);
        if (ports.size() == 1)
            return devices.absoluteFilePath(ports.first());
    }
    return QString();
}
}

UartTelemetrySource::UartTelemetrySource(EcuDataModel *model,
                                         const QString &portName,
                                         qint32 baudRate, QObject *parent)
    : QObject(parent), m_model(model), m_portName(portName),
      m_baudRate(baudRate)
{
    m_reconnectTimer.setInterval(reconnectMs);
    connect(&m_reconnectTimer, &QTimer::timeout,
            this, &UartTelemetrySource::connectPort);
    m_staleTimer.setSingleShot(true);
    m_staleTimer.setInterval(staleDataMs);
    connect(&m_staleTimer, &QTimer::timeout, m_model, &EcuDataModel::clear);
}

UartTelemetrySource::~UartTelemetrySource()
{
    if (m_fd >= 0)
        ::close(m_fd);
}

void UartTelemetrySource::start()
{
    connectPort();
    m_reconnectTimer.start();
}

void UartTelemetrySource::connectPort()
{
    if (m_fd >= 0)
        return;

    const speed_t speed = serialSpeed(m_baudRate);
    if (!speed) {
        qWarning() << "Unsupported ECU UART baud rate:" << m_baudRate;
        m_reconnectTimer.stop();
        return;
    }

    const QString portName = m_portName.isEmpty()
            ? discoverSerialPort() : m_portName;
    if (portName.isEmpty()) {
        const QString waiting = QStringLiteral("waiting for USB serial device");
        if (m_lastOpenError != waiting) {
            m_lastOpenError = waiting;
            qWarning() << "ECU UART" << waiting;
        }
        return;
    }

    const QByteArray path = portName.toLocal8Bit();
    const int fd = ::open(path.constData(), O_RDONLY | O_NOCTTY | O_NONBLOCK | O_CLOEXEC);
    if (fd >= 0) {
        termios options;
        if (::tcgetattr(fd, &options) == 0) {
            ::cfmakeraw(&options);
            options.c_cflag |= CLOCAL | CREAD;
            options.c_cflag &= ~CRTSCTS;
            options.c_cc[VMIN] = 1;
            options.c_cc[VTIME] = 0;
            if (::cfsetispeed(&options, speed) == 0
                    && ::cfsetospeed(&options, speed) == 0
                    && ::tcsetattr(fd, TCSANOW, &options) == 0) {
                ::tcflush(fd, TCIFLUSH);
                m_fd = fd;
                m_activePortName = portName;
                m_lastOpenError.clear();
                m_notifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);
                connect(m_notifier, &QSocketNotifier::activated,
                        this, &UartTelemetrySource::readAvailable);
                qInfo() << "ECU UART connected:" << m_activePortName
                        << m_baudRate << "baud";
                return;
            }
        }
        const int savedErrno = errno;
        ::close(fd);
        errno = savedErrno;
    }
    const QString error = QString::fromLocal8Bit(std::strerror(errno));
    if (m_lastOpenError != error) {
        m_lastOpenError = error;
        qWarning() << "ECU UART unavailable:" << portName << error;
    }
}

void UartTelemetrySource::readAvailable()
{
    char chunk[1024];
    for (int i = 0; i < 32; ++i) {
        const ssize_t count = ::read(m_fd, chunk, sizeof(chunk));
        if (count > 0) {
            m_buffer.append(chunk, static_cast<int>(count));
            processBuffer();
            continue;
        }
        if (count == 0 || (errno != EAGAIN && errno != EWOULDBLOCK
                           && errno != EINTR)) {
            disconnectPort();
            return;
        }
        if (errno != EINTR)
            break;
    }
}

void UartTelemetrySource::processBuffer()
{
    int newline = -1;
    while ((newline = m_buffer.indexOf('\n')) >= 0) {
        const QByteArray line = m_buffer.left(newline).trimmed();
        m_buffer.remove(0, newline + 1);
        if (line.size() <= maxLineBytes && m_model->applyJsonLine(line))
            m_staleTimer.start();
    }
    // Bo dong bi cat/dinh dang sai, tranh tich luy vo han khi UART nhieu.
    if (m_buffer.size() > maxLineBytes)
        m_buffer.clear();
}

void UartTelemetrySource::disconnectPort()
{
    qWarning() << "ECU UART disconnected:" << m_activePortName;
    m_notifier->setEnabled(false);
    m_notifier->deleteLater();
    m_notifier = nullptr;
    ::close(m_fd);
    m_fd = -1;
    m_activePortName.clear();
    m_buffer.clear();
    m_staleTimer.stop();
    m_model->clear();
}
