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

    property real speedVal: 0
    readonly property real rpmVal: speedVal / 30
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

    // Animation native, tranh cap phat JavaScript moi 16 ms tren Qt 5/Pi.
    SequentialAnimation {
        running: true
        loops: Animation.Infinite

        NumberAnimation {
            target: window
            property: "speedVal"
            from: 0
            to: 240
            duration: 9000
            easing.type: Easing.InOutSine
        }

        PauseAnimation { duration: 350 }

        NumberAnimation {
            target: window
            property: "speedVal"
            from: 240
            to: 0
            duration: 8000
            easing.type: Easing.InOutSine
        }

        PauseAnimation { duration: 350 }
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
            x: 72
            y: 128
            width: 344
            height: 344
            minValue: 0
            maxValue: 240
            majorStep: 20
            minorTicksPerStep: 4
            value: window.speedVal
            titleText: ""
            unitText: "km/h"
            accentColor: "#35bde9"
            dangerColor: "#ff3558"
            dangerStart: 220
            displayDecimals: 0
            showSubGauge: true
            subGaugeType: "fuel"
            subValue: 0.62
            subMinText: "E"
            subMaxText: "F"
        }

        // Dong ho vong tua cung kich thuoc va doi xung voi dong ho toc do.
        CustomGauge {
            id: rpmGauge
            z: 2
            x: 608
            y: 128
            width: 344
            height: 344
            minValue: 0
            maxValue: 8
            majorStep: 1
            minorTicksPerStep: 4
            value: window.rpmVal
            titleText: ""
            unitText: "x1000 rpm"
            accentColor: "#35bde9"
            dangerColor: "#ff3558"
            dangerStart: 6.5
            displayDecimals: 1
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
            x: 352
            y: 120
            width: 320
            height: 61

            Column {
                x: 0
                y: 1
                width: 100
                spacing: -1

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(window.currentDateTime, "hh:mm AP")
                    color: "#e9f0f5"
                    font.pixelSize: 17
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
                y: -4
                text: "D"
                color: "#f8fbfd"
                font.pixelSize: 30
                font.weight: Font.Medium
            }

            Text {
                x: 220
                y: 1
                width: 100
                horizontalAlignment: Text.AlignHCenter
                text: window.ambientTemperature + "\u00b0C"
                color: "#e9f0f5"
                font.pixelSize: 17
                font.weight: Font.Medium
            }

            Rectangle {
                x: 80
                y: 42
                width: 160
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
            y: 176
            width: 170
            horizontalAlignment: Text.AlignHCenter
            text: window.driveMode
            color: "#dbe6ed"
            font.pixelSize: 17
            font.weight: Font.Medium
        }

        Item {
            id: rangeInformation
            z: 4
            x: 415
            y: 201
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
                y: -1
                text: window.remainingRange
                color: "#e7eef3"
                font.pixelSize: 29
                font.weight: Font.Medium
            }

            Text {
                x: 108
                y: 11
                text: "km"
                color: "#aabac5"
                font.pixelSize: 14
            }
        }

        // Lan duong phoi canh, ve mot lan o 2x de sac net tren man hinh Pi.
        Canvas {
            id: roadScene
            z: 1
            x: 352
            y: 215
            width: 640
            height: 540
            scale: 0.5
            transformOrigin: Item.TopLeft
            renderTarget: Canvas.Image
            antialiasing: true

            onAvailableChanged: if (available) requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.scale(2, 2)

                var w = 320
                var h = 270
                var horizonY = 48

                var sky = ctx.createLinearGradient(0, 0, 0, 132)
                sky.addColorStop(0.0, "rgba(7,39,63,0)")
                sky.addColorStop(0.58, "rgba(8,48,78,0.72)")
                sky.addColorStop(1.0, "rgba(3,16,27,0.08)")
                ctx.fillStyle = sky
                ctx.fillRect(0, 0, w, 132)

                var road = ctx.createLinearGradient(0, horizonY, 0, h)
                road.addColorStop(0.0, "rgba(7,23,34,0.78)")
                road.addColorStop(1.0, "rgba(0,3,5,0.96)")
                ctx.beginPath()
                ctx.moveTo(150, horizonY)
                ctx.lineTo(170, horizonY)
                ctx.lineTo(314, h)
                ctx.lineTo(6, h)
                ctx.closePath()
                ctx.fillStyle = road
                ctx.fill()

                function drawRoadEdges() {
                    ctx.beginPath()
                    ctx.moveTo(150, horizonY)
                    ctx.lineTo(6, h)
                    ctx.moveTo(170, horizonY)
                    ctx.lineTo(314, h)
                }

                // Halo xanh rong tao cam giac be mat kim loai phan chieu.
                ctx.save()
                ctx.shadowBlur = 11
                ctx.shadowColor = "#35bde9"
                ctx.lineWidth = 7
                ctx.strokeStyle = "rgba(36,157,216,0.22)"
                drawRoadEdges()
                ctx.stroke()
                ctx.restore()

                var edge = ctx.createLinearGradient(0, horizonY, 0, h)
                edge.addColorStop(0.0, "#356f91")
                edge.addColorStop(0.55, "#87d8f5")
                edge.addColorStop(1.0, "#f0fbff")
                ctx.lineWidth = 2.7
                ctx.strokeStyle = edge
                drawRoadEdges()
                ctx.stroke()

                ctx.lineWidth = 0.8
                ctx.strokeStyle = "rgba(240,252,255,0.95)"
                drawRoadEdges()
                ctx.stroke()

                ctx.lineWidth = 1.1
                ctx.strokeStyle = "rgba(32,142,201,0.78)"
                ctx.beginPath()
                ctx.moveTo(156, horizonY + 4)
                ctx.lineTo(86, h)
                ctx.moveTo(164, horizonY + 4)
                ctx.lineTo(234, h)
                ctx.stroke()

                ctx.setLineDash([12, 12])
                ctx.lineWidth = 1.4
                ctx.strokeStyle = "rgba(219,235,244,0.72)"
                ctx.beginPath()
                ctx.moveTo(160, horizonY + 14)
                ctx.lineTo(160, h)
                ctx.stroke()
                ctx.setLineDash([])
            }
        }

        Item {
            id: drivingVehicle
            z: 3
            x: 484
            y: 332
            width: 56
            height: 102

            Rectangle {
                x: 7
                y: 83
                width: 42
                height: 15
                radius: 8
                color: "#000000"
                opacity: 0.42
            }

            Image {
                anchors.fill: parent
                source: "images/vehicle-top.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        TurnIndicator {
            z: 16
            x: 297
            y: 112
            pointsLeft: true
            active: true
        }

        TurnIndicator {
            z: 16
            x: 679
            y: 112
            pointsLeft: false
            active: true
        }

        // Cac den canh bao mo phong tu bo icon vector nguoi dung cung cap.
        Item {
            id: warningIndicators
            z: 4
            anchors.fill: parent

            Repeater {
                model: [
                    { px: 65, py: 224, cx: 430, cy: 510, cw: 100, ch: 84 },
                    { px: 65, py: 258, cx: 430, cy: 610, cw: 105, ch: 90 },
                    { px: 65, py: 292, cx: 320, cy: 710, cw: 105, ch: 92 },
                    { px: 65, py: 326, cx: 660, cy: 920, cw: 105, ch: 92 },
                    { px: 937, py: 224, cx: 1080, cy: 610, cw: 105, ch: 90 },
                    { px: 937, py: 258, cx: 650, cy: 710, cw: 105, ch: 92 },
                    { px: 937, py: 292, cx: 545, cy: 920, cw: 105, ch: 92 },
                    { px: 937, py: 326, cx: 760, cy: 920, cw: 105, ch: 92 }
                ]

                delegate: Image {
                    x: modelData.px
                    y: modelData.py
                    width: 22
                    height: 22
                    source: "images/dashboard-icons.png"
                    sourceClipRect: Qt.rect(modelData.cx, modelData.cy,
                                            modelData.cw, modelData.ch)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: 0.78
                }
            }
        }

        Item {
            z: 4
            x: 423
            y: 450
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
                y: 1
                text: window.odometer
                color: "#eef3f6"
                font.pixelSize: 23
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

        // Vien 2:1 duoc phong theo chieu ngang va giu nguyen ti le anh.
        // Phan vien that nam can giua o khoang y=73..523 tren canvas 1024x600.
        Image {
            id: clusterBezel
            z: 15
            x: -34
            y: 27
            width: 1092
            height: 546
            source: "images/cluster-bezel.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }
}
