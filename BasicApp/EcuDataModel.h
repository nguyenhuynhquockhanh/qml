#pragma once

#include <QObject>
#include <QByteArray>

// Gia tri da chuan hoa cho giao dien. Transport UART/SPI chi can dua tung
// ban tin JSON vao applyJsonLine; QML khong phu thuoc vao cong giao tiep.
class EcuDataModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(bool braking READ braking NOTIFY brakingChanged)
    Q_PROPERTY(bool blindLeft READ blindLeft NOTIFY blindLeftChanged)
    Q_PROPERTY(bool blindRight READ blindRight NOTIFY blindRightChanged)

public:
    explicit EcuDataModel(QObject *parent = nullptr);

    int speed() const { return m_speed; }
    bool braking() const { return m_braking; }
    bool blindLeft() const { return m_blindLeft; }
    bool blindRight() const { return m_blindRight; }

    // Tra ve true khi co it nhat mot truong hop le duoc nhan.
    bool applyJsonLine(const QByteArray &line);
    void clear();

signals:
    void speedChanged();
    void brakingChanged();
    void blindLeftChanged();
    void blindRightChanged();

private:
    void setSpeed(int speed);
    void setBraking(bool braking);
    void setBlindLeft(bool active);
    void setBlindRight(bool active);

    int m_speed = 0;
    bool m_braking = false;
    bool m_blindLeft = false;
    bool m_blindRight = false;
};
