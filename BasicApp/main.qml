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
    property string driveMode: "Driving"
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

        // Nen vo cluster va long hien thi duoc ve theo silhouette cua anh mau.
        Canvas {
            id: clusterBody
            anchors.fill: parent
            renderTarget: Canvas.Image
            antialiasing: true

            onAvailableChanged: if (available) requestPaint()

            function outerPath(ctx) {
                ctx.beginPath()
                ctx.moveTo(82, 31)
                ctx.bezierCurveTo(270, 0, 744, 2, 913, 51)
                ctx.bezierCurveTo(980, 70, 1007, 132, 1010, 226)
                ctx.lineTo(1010, 380)
                ctx.bezierCurveTo(1007, 463, 971, 516, 901, 538)
                ctx.bezierCurveTo(798, 570, 655, 565, 516, 559)
                ctx.bezierCurveTo(365, 566, 211, 572, 108, 541)
                ctx.bezierCurveTo(43, 521, 15, 466, 14, 391)
                ctx.lineTo(14, 190)
                ctx.bezierCurveTo(16, 108, 35, 50, 82, 31)
                ctx.closePath()
            }

            function innerPath(ctx) {
                ctx.beginPath()
                ctx.moveTo(105, 72)
                ctx.bezierCurveTo(282, 43, 724, 44, 891, 86)
                ctx.bezierCurveTo(946, 100, 972, 151, 974, 231)
                ctx.lineTo(974, 373)
                ctx.bezierCurveTo(972, 434, 946, 474, 885, 493)
                ctx.bezierCurveTo(780, 524, 646, 521, 516, 516)
                ctx.bezierCurveTo(375, 522, 230, 527, 126, 499)
                ctx.bezierCurveTo(75, 485, 50, 441, 49, 381)
                ctx.lineTo(49, 204)
                ctx.bezierCurveTo(50, 133, 67, 87, 105, 72)
                ctx.closePath()
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var outside = ctx.createLinearGradient(0, 0, 0, height)
                outside.addColorStop(0.0, "#f4f6f8")
                outside.addColorStop(0.62, "#e4e8ec")
                outside.addColorStop(1.0, "#cbd2d8")
                ctx.fillStyle = outside
                ctx.fillRect(0, 0, width, height)

                outerPath(ctx)
                var shell = ctx.createLinearGradient(0, 10, 0, 570)
                shell.addColorStop(0.0, "#111a22")
                shell.addColorStop(0.18, "#030609")
                shell.addColorStop(0.75, "#060a0d")
                shell.addColorStop(1.0, "#151c21")
                ctx.fillStyle = shell
                ctx.fill()

                ctx.save()
                ctx.shadowBlur = 16
                ctx.shadowColor = "rgba(0,0,0,0.72)"
                ctx.lineWidth = 18
                ctx.strokeStyle = "#020405"
                ctx.stroke()
                ctx.restore()

                innerPath(ctx)
                var display = ctx.createRadialGradient(515, 285, 25,
                                                       515, 300, 535)
                display.addColorStop(0.0, "#071a29")
                display.addColorStop(0.38, "#03101a")
                display.addColorStop(0.75, "#010509")
                display.addColorStop(1.0, "#000204")
                ctx.fillStyle = display
                ctx.fill()
                ctx.lineWidth = 3
                ctx.strokeStyle = "#1f2e38"
                ctx.stroke()
            }
        }

        // Dong ho toc do lon ben trai.
        CustomGauge {
            id: speedGauge
            z: 2
            x: 41
            y: 102
            width: 432
            height: 432
            minValue: 0
            maxValue: 240
            majorStep: 20
            minorTicksPerStep: 4
            value: window.speedVal
            titleText: ""
            unitText: "km/h"
            accentColor: "#19aef5"
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
            x: 644
            y: 147
            width: 334
            height: 334
            minValue: 0
            maxValue: 8
            majorStep: 1
            minorTicksPerStep: 4
            value: window.rpmVal
            titleText: ""
            unitText: "x1000 rpm"
            accentColor: "#159ee9"
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
            y: 102
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
            y: 181
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
            y: 214
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

        // Canh duong trung tam la placeholder vector; co the thay bang anh sau.
        Canvas {
            id: roadScene
            z: 1
            x: 352
            y: 264
            width: 324
            height: 251
            renderTarget: Canvas.Image
            antialiasing: true

            onAvailableChanged: if (available) requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var sky = ctx.createLinearGradient(0, 0, 0, 128)
                sky.addColorStop(0.0, "rgba(4,20,33,0)")
                sky.addColorStop(0.48, "rgba(8,44,70,0.78)")
                sky.addColorStop(1.0, "rgba(8,31,48,0.12)")
                ctx.fillStyle = sky
                ctx.fillRect(0, 0, width, 130)

                // Chan troi thanh pho mo de giu dung bo cuc anh mau.
                var skyline = [18, 30, 23, 38, 27, 47, 34, 31, 43, 25,
                               28, 46, 32, 52, 30, 37, 24, 43, 29, 35,
                               20, 42, 27, 49, 29, 37, 25, 44, 31, 22]
                ctx.beginPath()
                ctx.moveTo(0, 112)
                for (var i = 0; i < skyline.length; ++i) {
                    var sx = i * width / (skyline.length - 1)
                    ctx.lineTo(sx, 112 - skyline[i] * 0.56)
                }
                ctx.lineTo(width, 126)
                ctx.lineTo(0, 126)
                ctx.closePath()
                ctx.fillStyle = "#06131d"
                ctx.fill()

                var road = ctx.createLinearGradient(0, 84, 0, height)
                road.addColorStop(0.0, "#07141d")
                road.addColorStop(1.0, "#010406")
                ctx.beginPath()
                ctx.moveTo(147, 87)
                ctx.lineTo(177, 87)
                ctx.lineTo(311, 251)
                ctx.lineTo(13, 251)
                ctx.closePath()
                ctx.fillStyle = road
                ctx.fill()

                var edge = ctx.createLinearGradient(0, 85, 0, 251)
                edge.addColorStop(0.0, "#7fa5bd")
                edge.addColorStop(1.0, "#e8f4fb")
                ctx.lineWidth = 2.4
                ctx.strokeStyle = edge
                ctx.beginPath()
                ctx.moveTo(150, 87)
                ctx.lineTo(13, 251)
                ctx.moveTo(174, 87)
                ctx.lineTo(311, 251)
                ctx.stroke()

                ctx.lineWidth = 1
                ctx.strokeStyle = "rgba(65,115,148,0.75)"
                ctx.beginPath()
                ctx.moveTo(155, 90)
                ctx.lineTo(81, 251)
                ctx.moveTo(169, 90)
                ctx.lineTo(243, 251)
                ctx.stroke()
            }
        }

        // Placeholder xe dat dung toa do; se thay truc tiep bang asset khi duoc cung cap.
        Item {
            id: carPlaceholder
            z: 3
            x: 475
            y: 349
            width: 78
            height: 58

            Rectangle {
                x: 11
                y: 15
                width: 56
                height: 34
                radius: 9
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#d5dce1" }
                    GradientStop { position: 0.48; color: "#6b7780" }
                    GradientStop { position: 1.0; color: "#30383e" }
                }
                border.width: 1
                border.color: "#e4e9ec"
            }

            Rectangle {
                x: 20
                y: 6
                width: 38
                height: 22
                radius: 7
                color: "#192c39"
                border.width: 2
                border.color: "#89969f"
            }

            Rectangle { x: 14; y: 34; width: 13; height: 6; radius: 3; color: "#f0202f" }
            Rectangle { x: 51; y: 34; width: 13; height: 6; radius: 3; color: "#f0202f" }
            Rectangle { x: 28; y: 44; width: 22; height: 3; radius: 1; color: "#b9d3e3" }
            Rectangle { x: 10; y: 47; width: 7; height: 7; radius: 2; color: "#050607" }
            Rectangle { x: 61; y: 47; width: 7; height: 7; radius: 2; color: "#050607" }
        }

        Item {
            z: 4
            x: 423
            y: 485
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

        // Vien chrome nam tren cung de chep dung canh ngoai cua cluster.
        Canvas {
            id: chromeBorder
            z: 10
            anchors.fill: parent
            renderTarget: Canvas.Image
            antialiasing: true

            onAvailableChanged: if (available) requestPaint()

            function outerPath(ctx) {
                ctx.beginPath()
                ctx.moveTo(82, 31)
                ctx.bezierCurveTo(270, 0, 744, 2, 913, 51)
                ctx.bezierCurveTo(980, 70, 1007, 132, 1010, 226)
                ctx.lineTo(1010, 380)
                ctx.bezierCurveTo(1007, 463, 971, 516, 901, 538)
                ctx.bezierCurveTo(798, 570, 655, 565, 516, 559)
                ctx.bezierCurveTo(365, 566, 211, 572, 108, 541)
                ctx.bezierCurveTo(43, 521, 15, 466, 14, 391)
                ctx.lineTo(14, 190)
                ctx.bezierCurveTo(16, 108, 35, 50, 82, 31)
                ctx.closePath()
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                outerPath(ctx)

                var chrome = ctx.createLinearGradient(0, 20, 0, 565)
                chrome.addColorStop(0.0, "#66727a")
                chrome.addColorStop(0.16, "#e7ecef")
                chrome.addColorStop(0.42, "#3a464e")
                chrome.addColorStop(0.72, "#9ba6ad")
                chrome.addColorStop(0.90, "#f0f3f5")
                chrome.addColorStop(1.0, "#5d6970")
                ctx.lineWidth = 10
                ctx.strokeStyle = chrome
                ctx.stroke()

                outerPath(ctx)
                ctx.lineWidth = 2
                ctx.strokeStyle = "rgba(255,255,255,0.88)"
                ctx.stroke()
            }
        }
    }
}
