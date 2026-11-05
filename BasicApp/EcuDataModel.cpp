#include "EcuDataModel.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QtGlobal>
#include <cmath>

namespace {

constexpr double blindSpotThresholdCm = 50.0;

bool numberField(const QJsonObject &object, const char *primary,
                 const char *alias, double *result)
{
    QJsonValue value = object.value(QLatin1String(primary));
    if (value.isUndefined() && alias)
        value = object.value(QLatin1String(alias));
    if (!value.isDouble())
        return false;
    const double number = value.toDouble();
    if (!std::isfinite(number))
        return false;
    *result = number;
    return true;
}

} // namespace

EcuDataModel::EcuDataModel(QObject *parent) : QObject(parent) {}

bool EcuDataModel::applyJsonLine(const QByteArray &line)
{
    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(line, &error);
    if (error.error != QJsonParseError::NoError || !document.isObject())
        return false;

    const QJsonObject data = document.object();
    double value = 0;
    bool accepted = false;

    if (numberField(data, "spd", "Speed", &value)) {
        setSpeed(qRound(qBound(0.0, value, 240.0)));
        accepted = true;
    }
    if (numberField(data, "brk", "Brake", &value)) {
        setBraking(value != 0);
        accepted = true;
    }
    // snL/snR la khoang cach sonar (cm): Web dashboard canh bao khi < 50.
    // 255 la gia tri mac dinh khi khong phat hien vat can.
    if (numberField(data, "snL", "Sonar_L", &value)) {
        setBlindLeft(value < blindSpotThresholdCm);
        accepted = true;
    }
    if (numberField(data, "snR", "Sonar_R", &value)) {
        setBlindRight(value < blindSpotThresholdCm);
        accepted = true;
    }
    return accepted;
}

void EcuDataModel::clear()
{
    setSpeed(0);
    setBraking(false);
    setBlindLeft(false);
    setBlindRight(false);
}

void EcuDataModel::setSpeed(int speed)
{
    if (m_speed == speed)
        return;
    m_speed = speed;
    emit speedChanged();
}

void EcuDataModel::setBraking(bool braking)
{
    if (m_braking == braking)
        return;
    m_braking = braking;
    emit brakingChanged();
}

void EcuDataModel::setBlindLeft(bool active)
{
    if (m_blindLeft == active)
        return;
    m_blindLeft = active;
    emit blindLeftChanged();
}

void EcuDataModel::setBlindRight(bool active)
{
    if (m_blindRight == active)
        return;
    m_blindRight = active;
    emit blindRightChanged();
}
