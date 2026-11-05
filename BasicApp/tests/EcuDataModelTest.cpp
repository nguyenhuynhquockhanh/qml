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

    if (!check(model.applyJsonLine("{\"spd\":90,\"brk\":1,\"snL\":49,\"snR\":50}"),
               "valid ECU packet rejected")
            || !check(model.speed() == 90 && model.braking()
                      && model.blindLeft() && !model.blindRight(),
                      "threshold or brake mapping failed"))
        return 1;

    if (!check(model.applyJsonLine("{\"snL\":255,\"snR\":0}"),
               "partial ECU packet rejected")
            || !check(model.speed() == 90 && !model.blindLeft()
                      && model.blindRight(), "partial update failed"))
        return 1;

    if (!check(!model.applyJsonLine("{broken"), "invalid JSON accepted")
            || !check(model.speed() == 90, "invalid JSON changed speed"))
        return 1;

    if (!check(model.applyJsonLine("{\"Speed\":300,\"Brake\":0,"
                                   "\"Sonar_L\":49.9,\"Sonar_R\":50}"),
               "CSV-style aliases rejected")
            || !check(model.speed() == 240 && !model.braking()
                      && model.blindLeft() && !model.blindRight(),
                      "aliases or speed clamp failed"))
        return 1;

    model.clear();
    if (!check(model.speed() == 0 && !model.braking()
               && !model.blindLeft() && !model.blindRight(),
               "stale data reset failed"))
        return 1;

    qInfo() << "EcuDataModel tests passed";
    return 0;
}
