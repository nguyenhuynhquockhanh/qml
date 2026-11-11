import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property real speedVal: 0
    property real rpmVal: 0
    property real rasterScale: 1
    property string imagePrefix: ""

    // Dong ho toc do lon ben trai.
    Dong_ho {
        id: speedGauge
        z: 2
        x: 72
        y: 128
        width: 344
        height: 344
        minValue: 0
        maxValue: 240
        majorStep: 20
        minorTicksPerStep: 4
        value: root.speedVal
        titleText: ""
        unitText: "km/h"
        accentColor: "#35bde9"
        dangerColor: "#ff3558"
        dangerStart: 220
        displayDecimals: 0
        outputScale: root.rasterScale
        showSubGauge: true
        subGaugeType: "fuel"
        subGaugeIconSource: root.imagePrefix + "fuel-pump.png"
        subValue: 0.62
        subMinText: "E"
        subMaxText: "F"
    }

    // Dong ho vong tua cung kich thuoc va doi xung voi dong ho toc do.
    Dong_ho {
        id: rpmGauge
        z: 2
        x: 608
        y: 128
        width: 344
        height: 344
        minValue: 0
        maxValue: 300
        majorStep: 50
        minorTicksPerStep: 4
        value: root.rpmVal
        titleText: ""
        unitText: "rpm"
        accentColor: "#35bde9"
        dangerColor: "#ff3558"
        dangerStart: 250
        displayDecimals: 0
        outputScale: root.rasterScale
        showSubGauge: true
        subGaugeType: "temperature"
        subGaugeIconSource: root.imagePrefix + "coolant-temperature.png"
        subValue: 0.48
        subMinText: "C"
        subMaxText: "H"
    }

}
