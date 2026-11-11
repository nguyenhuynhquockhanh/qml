#include "EcuDataModel.h"

#include <QtGlobal>

namespace {
constexpr double blindSpotThresholdCm = 50.0;
}

EcuDataModel::EcuDataModel(QObject *parent) : QObject(parent) {}

void EcuDataModel::setMotion(double speedKmh, double rpm)
{
    setSpeed(qRound(qBound(0.0, speedKmh, 240.0)));
    setRpm(qRound(qBound(0.0, rpm, 8000.0)));
}

void EcuDataModel::setBraking(bool braking)
{
    if (m_braking == braking)
        return;
    m_braking = braking;
    emit brakingChanged();
}

void EcuDataModel::setBlindDistances(double leftCm, double rightCm)
{
    setBlindLeft(leftCm < blindSpotThresholdCm);
    setBlindRight(rightCm < blindSpotThresholdCm);
}

void EcuDataModel::clearMotion()
{
    setSpeed(0);
    setRpm(0);
}

void EcuDataModel::clearBraking()
{
    setBraking(false);
}

void EcuDataModel::clearBlindSpots()
{
    setBlindLeft(false);
    setBlindRight(false);
}

void EcuDataModel::clear()
{
    clearMotion();
    clearBraking();
    clearBlindSpots();
}

void EcuDataModel::setSpeed(int speed)
{
    if (m_speed == speed)
        return;
    m_speed = speed;
    emit speedChanged();
}

void EcuDataModel::setRpm(int rpm)
{
    if (m_rpm == rpm)
        return;
    m_rpm = rpm;
    emit rpmChanged();
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
