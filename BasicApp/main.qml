import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: window

    readonly property real designWidth: 1024
    readonly property real designHeight: 600

    width: designWidth
    height: designHeight
    visible: true
    title: "Instrument Cluster"
    color: "#e8ecef"

    property real speedVal: 90
    readonly property real rpmVal: speedVal / 30
    property bool increasing: true
    property real speedVelocity: 0
    property date currentDateTime: new Date()
    property int ambientTemperature: 20
    property string driveMode: "BMW 540i"
    property int remainingRange: 450
    property int odometer: 12580
    property bool enableGaugeBlur: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: window.currentDateTime = new Date()
    }

    // Du lieu mo phong, tach khoi qua trinh ve de animation luon on dinh.
    Timer {
        interval: 16
        running: true
        repeat: true

        onTriggered: {
            if (increasing) {
                speedVelocity = Math.min(1.35, speedVelocity + 0.014)
                speedVal = Math.min(240, speedVal + speedVelocity)
                if (speedVal >= 240) {
                    increasing = false
                    speedVelocity = 0
                }
            } else {
                speedVelocity = Math.min(1.55, speedVelocity + 0.017)
                speedVal = Math.max(0, speedVal - speedVelocity)
                if (speedVal <= 0) {
                    increasing = true
                    speedVelocity = 0
                }
            }
        }
    }

    Item {
        id: designArea
        width: window.designWidth
        height: window.designHeight
        anchors.centerIn: parent
        transformOrigin: Item.Center
        scale: Math.min(window.width / width, window.height / height)

        // Nen xanh-den phu toan man hinh, toa sang nhe tu tam cluster.
        Canvas {
            id: clusterBody
            anchors.fill: parent
            renderTarget: Canvas.Image
            antialiasing: true

            onAvailableChanged: if (available) requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var display = ctx.createRadialGradient(512, 285, 12,
                                                       512, 300, 630)
                display.addColorStop(0.0, "#0a2b46")
                display.addColorStop(0.28, "#071d30")
                display.addColorStop(0.58, "#03101b")
                display.addColorStop(0.82, "#01070c")
                display.addColorStop(1.0, "#000204")
                ctx.fillStyle = display
                ctx.fillRect(0, 0, width, height)
            }
        }

        // Dong ho toc do lon ben trai.
        CustomGauge {
            id: speedGauge
            z: 2
            x: 65
            y: 128
            width: 360
            height: 360
            minValue: 0
            maxValue: 240
            majorStep: 20
            minorTicksPerStep: 4
            value: window.speedVal
            titleText: ""
            unitText: "km/h"
            accentColor: "#2e92bf"
            dangerColor: "#d8263d"
            dangerStart: 220
            displayDecimals: 0
            enableDynamicBlur: window.enableGaugeBlur
            showSubGauge: true
            subGaugeType: "fuel"
            subValue: 0.62
            subMinText: "E"
            subMaxText: "F"
        }

        // Dong ho vong tua nho hon, dung ti le nhu anh tham chieu.
        CustomGauge {
            id: rpmGauge
            z: 2
            x: 619
            y: 148
            width: 320
            height: 320
            minValue: 0
            maxValue: 8
            majorStep: 1
            minorTicksPerStep: 4
            value: window.rpmVal
            titleText: ""
            unitText: "x1000 rpm"
            accentColor: "#2e92bf"
            dangerColor: "#d8263d"
            dangerStart: 6.5
            displayDecimals: 1
            enableDynamicBlur: window.enableGaugeBlur
            showSubGauge: true
            subGaugeType: "temperature"
            subValue: 0.48
            subMinText: "C"
            subMaxText: "H"
        }

        // Cum thong tin tren cung: gio/ngay, cap so va nhiet do moi truong.
        Item {
            id: topInformation
            z: 4
            x: 357
            y: 78
            width: 322
            height: 61

            Column {
                x: 0
                y: 1
                width: 98
                spacing: -1

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(window.currentDateTime, "hh:mm AP")
                    color: "#e9f0f5"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(window.currentDateTime, "dd/MM/yyyy")
                    color: "#728696"
                    font.pixelSize: 9
                    font.letterSpacing: 0.7
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: -5
                text: "D"
                color: "#f8fbfd"
                font.pixelSize: 31
                font.weight: Font.Medium
            }

            Text {
                x: 238
                y: 1
                width: 84
                horizontalAlignment: Text.AlignHCenter
                text: window.ambientTemperature + "\u00b0C"
                color: "#e9f0f5"
                font.pixelSize: 18
                font.weight: Font.Medium
            }

            Rectangle {
                x: 82
                y: 42
                width: 158
                height: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#001a2b" }
                    GradientStop { position: 0.5; color: "#157db6" }
                    GradientStop { position: 1.0; color: "#001a2b" }
                }
            }
        }

        Text {
            z: 4
            x: 430
            y: 145
            width: 170
            horizontalAlignment: Text.AlignHCenter
            text: window.driveMode
            color: "#dbe6ed"
            font.pixelSize: 18
            font.weight: Font.Medium
        }

        Item {
            id: rangeInformation
            z: 4
            x: 415
            y: 174
            width: 202
            height: 43

            Canvas {
                x: 0
                y: 5
                width: 39
                height: 30
                antialiasing: true

                onAvailableChanged: if (available) requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.lineWidth = 2
                    ctx.strokeStyle = "#8ea8bb"
                    ctx.beginPath()
                    ctx.moveTo(7, 26)
                    ctx.lineTo(15, 3)
                    ctx.moveTo(32, 26)
                    ctx.lineTo(24, 3)
                    ctx.stroke()
                    ctx.fillStyle = "#8ea8bb"
                    ctx.fillRect(18, 8, 3, 6)
                    ctx.fillRect(18, 18, 3, 6)
                }
            }

            Text {
                x: 42
                y: -2
                text: window.remainingRange
                color: "#e7eef3"
                font.pixelSize: 30
                font.weight: Font.Medium
            }

            Text {
                x: 108
                y: 11
                text: "km"
                color: "#aabac5"
                font.pixelSize: 15
            }
        }

        // Xe trung bay: anh that tren be sang va bong do tinh.
        Item {
            id: vehicleShowcase
            z: 1
            x: 367
            y: 235
            width: 290
            height: 190

            Rectangle {
                x: 40
                y: 30
                width: 210
                height: 128
                radius: 64
                color: "#0b3958"
                opacity: 0.16
            }

            Rectangle {
                x: 18
                y: 148
                width: 254
                height: 28
                radius: 14
                color: "#000000"
                opacity: 0.27
            }

            Rectangle {
                x: 40
                y: 154
                width: 210
                height: 16
                radius: 8
                color: "#020405"
                opacity: 0.56
            }

            Rectangle {
                x: 55
                y: 160
                width: 180
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#00121e" }
                    GradientStop { position: 0.5; color: "#2aa4df" }
                    GradientStop { position: 1.0; color: "#00121e" }
                }
                opacity: 0.72
            }

            Image {
                id: displayVehicle
                x: 0
                y: 0
                width: 290
                height: 148
                source: "images/vehicle-display.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        Item {
            z: 4
            x: 423
            y: 455
            width: 184
            height: 36

            Text {
                x: 0
                y: 7
                text: "ODO"
                color: "#008ed5"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Text {
                x: 38
                y: 0
                text: window.odometer
                color: "#eef3f6"
                font.pixelSize: 24
                font.weight: Font.Medium
            }

            Text {
                x: 118
                y: 9
                text: "km"
                color: "#9caeb9"
                font.pixelSize: 12
            }
        }

        // Asset bezel that thay hoan toan Canvas vien cu.
        Image {
            id: clusterBezel
            z: 10
            x: -24
            y: -60
            width: 1072
            height: 720
            source: "images/cluster-bezel.png"
            fillMode: Image.Stretch
            smooth: true
            mipmap: true
        }
    }
}
