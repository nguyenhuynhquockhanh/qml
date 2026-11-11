import QtQuick 2.15
import QtQuick.Window 2.15
import "qml"

Window {
    id: window
    readonly property real designWidth: 1024
    readonly property real designHeight: 600
    readonly property real layoutScale: Math.min(width / designWidth,
                                                  height / designHeight)
    readonly property real rasterScale: Math.max(1,
                                                 Math.min(4,
                                                          layoutScale
                                                          * Screen.devicePixelRatio))
    readonly property real detailRenderScale: Math.max(2, rasterScale)
    readonly property bool runningOnEglfs:
        typeof piEglfs !== "undefined" && piEglfs

    width: designWidth
    height: designHeight
    visible: true
    title: "Instrument Cluster"
    color: "#e8ecef"

    // qmlscene khong co backend C++; gia tri mac dinh la 0.
    readonly property real speedVal: typeof ecuTelemetry !== "undefined"
                                     ? ecuTelemetry.speed : 0
    readonly property real rpmVal: typeof ecuTelemetry !== "undefined"
                                   ? ecuTelemetry.rpm : 0
    readonly property bool braking: typeof ecuTelemetry !== "undefined"
                                    && ecuTelemetry.braking
    readonly property bool blindLeftActive:
        typeof ecuTelemetry !== "undefined" && ecuTelemetry.blindLeft
    readonly property bool blindRightActive:
        typeof ecuTelemetry !== "undefined" && ecuTelemetry.blindRight
    property date currentDateTime: new Date()
    property int ambientTemperature: 20
    property string driveMode: "Driving"
    property int remainingRange: 450
    property int odometer: 12580

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: window.currentDateTime = new Date()
    }

    Giao_dien_cum_dong_ho {
        anchors.centerIn: parent
        transformOrigin: Item.Center
        scale: window.layoutScale
        rasterScale: window.rasterScale
        detailRenderScale: window.detailRenderScale
        runningOnEglfs: window.runningOnEglfs
        speedVal: window.speedVal
        rpmVal: window.rpmVal
        braking: window.braking
        blindLeftActive: window.blindLeftActive
        blindRightActive: window.blindRightActive
        currentDateTime: window.currentDateTime
        ambientTemperature: window.ambientTemperature
        driveMode: window.driveMode
        remainingRange: window.remainingRange
        odometer: window.odometer
    }
}
