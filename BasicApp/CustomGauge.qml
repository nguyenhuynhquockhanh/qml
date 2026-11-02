import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    property real value: 0
    property real minValue: 0
    property real maxValue: 240
    property real majorStep: 20
    property int minorTicksPerStep: 4
    property string titleText: "SPEED"
    property string unitText: "km/h"
    property color accentColor: "#35bde9"
    property color dangerColor: "#ff3558"
    property real dangerStart: 220
    property int displayDecimals: 0
    property real outputScale: 1
    property bool showSubGauge: false
    property string subGaugeType: "fuel"
    property real subValue: 0.5
    property string subMinText: "E"
    property string subMaxText: "F"

    readonly property real startAngle: -130
    readonly property real sweepAngle: 260
    readonly property real progress: maxValue > minValue
                                     ? Math.max(0, Math.min(1,
                                         (value - minValue) / (maxValue - minValue)))
                                     : 0
    // Canvas tinh giu toi thieu 3x va tu tang theo mat do pixel dau ra.
    readonly property real renderScale: Math.max(3, outputScale)
    readonly property real dialSize: Math.min(width, height)
    readonly property real dialRadius: dialSize / 2
    readonly property real faceRadius: dialRadius - dialSize * 0.035
    // Luong sang dung chung ban kinh voi dau ngoai cua cac vach chia.
    readonly property real arcRadius: faceRadius - dialSize * 0.075
    readonly property real dangerProgress: maxValue > minValue
                                           ? Math.max(0, Math.min(1,
                                               (dangerStart - minValue)
                                               / (maxValue - minValue)))
                                           : 1
    readonly property real normalArcProgress: Math.min(progress, dangerProgress)
    readonly property real dangerArcProgress: Math.max(0,
                                                        progress - dangerProgress)
    readonly property real arcHeadStart: Math.max(0, progress - 0.055)
    readonly property real dynamicArcOpacity: 0.28 + progress * 0.54
    readonly property real pathStartAngle: startAngle - 90
    readonly property real arcRenderScale: Math.max(2, outputScale)

    function requestBackgroundPaint() {
        backgroundCanvas.requestPaint()
    }

    onWidthChanged: {
        requestBackgroundPaint()
    }
    onHeightChanged: {
        requestBackgroundPaint()
    }
    onMinValueChanged: requestBackgroundPaint()
    onMaxValueChanged: requestBackgroundPaint()
    onMajorStepChanged: requestBackgroundPaint()
    onMinorTicksPerStepChanged: requestBackgroundPaint()
    onAccentColorChanged: {
        requestBackgroundPaint()
    }
    onDangerColorChanged: {
        requestBackgroundPaint()
    }
    onDangerStartChanged: {
        requestBackgroundPaint()
    }
    onShowSubGaugeChanged: requestBackgroundPaint()
    onSubGaugeTypeChanged: requestBackgroundPaint()
    onSubValueChanged: requestBackgroundPaint()
    onSubMinTextChanged: requestBackgroundPaint()
    onSubMaxTextChanged: requestBackgroundPaint()

    Canvas {
        id: backgroundCanvas
        x: (root.width - root.dialSize) / 2
        y: (root.height - root.dialSize) / 2
        width: Math.ceil(root.dialSize * root.renderScale)
        height: width
        scale: 1 / root.renderScale
        transformOrigin: Item.TopLeft
        renderTarget: Canvas.Image
        antialiasing: true

        onAvailableChanged: if (available) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.scale(root.renderScale, root.renderScale)

            var cx = root.dialRadius
            var cy = root.dialRadius
            var radius = root.faceRadius
            if (radius <= 60)
                return

            function radians(angle) {
                return (angle - 90) * Math.PI / 180
            }

            var arcRadius = root.arcRadius
            var startRad = radians(root.startAngle)
            var endRad = radians(root.startAngle + root.sweepAngle)
            ctx.beginPath()
            ctx.arc(cx, cy, arcRadius, startRad, endRad)
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "#1a3341"
            ctx.stroke()

            var range = root.maxValue - root.minValue
            var majorCount = Math.max(1, Math.round(range / root.majorStep))
            var totalTicks = majorCount * root.minorTicksPerStep

            ctx.textAlign = "center"
            ctx.textBaseline = "middle"

            for (var i = 0; i <= totalTicks; ++i) {
                var fraction = i / totalTicks
                var angle = root.startAngle + fraction * root.sweepAngle
                var rad = radians(angle)
                var cosA = Math.cos(rad)
                var sinA = Math.sin(rad)
                var isMajor = i % root.minorTicksPerStep === 0
                var tickOuter = root.arcRadius
                var tickInner = tickOuter
                                - root.dialSize * (isMajor ? 0.045 : 0.025)

                ctx.beginPath()
                ctx.moveTo(cx + tickOuter * cosA, cy + tickOuter * sinA)
                ctx.lineTo(cx + tickInner * cosA, cy + tickInner * sinA)
                ctx.lineWidth = isMajor ? 1.7 : 0.75
                ctx.strokeStyle = isMajor ? "#e9f2f7" : "#6e8290"
                ctx.stroke()

                if (isMajor) {
                    var labelRadius = root.arcRadius - root.dialSize * 0.12
                    var labelValue = root.minValue + (i / totalTicks) * range
                    ctx.fillStyle = "#eef5fa"
                    ctx.font = Math.round(root.dialSize * 0.04)
                               + "px sans-serif"
                    ctx.fillText(Math.round(labelValue).toString(),
                                 cx + labelRadius * cosA,
                                 cy + labelRadius * sinA)
                }
            }

            if (root.showSubGauge) {
                var subRadius = root.arcRadius
                var subStartAngle = -150
                var subSweep = 60
                var subSplitAngle = subStartAngle - subSweep * 0.88
                var subEndAngle = subStartAngle - subSweep
                var subStartRad = radians(subStartAngle)
                var subSplitRad = radians(subSplitAngle)
                var subEndRad = radians(subEndAngle)

                // Cung dong ho phu: xanh o muc binh thuong, do o vung cao.
                ctx.save()
                ctx.shadowBlur = 3
                ctx.shadowColor = root.accentColor
                ctx.beginPath()
                ctx.arc(cx, cy, subRadius, subStartRad, subSplitRad, true)
                ctx.lineWidth = 3.2
                ctx.strokeStyle = root.accentColor
                ctx.stroke()
                ctx.restore()

                ctx.save()
                ctx.shadowBlur = 3
                ctx.shadowColor = root.dangerColor
                ctx.beginPath()
                ctx.arc(cx, cy, subRadius, subSplitRad, subEndRad, true)
                ctx.lineWidth = 3.2
                ctx.strokeStyle = root.dangerColor
                ctx.stroke()
                ctx.restore()

                // Vach chia cua dong ho phu.
                for (var j = 0; j <= 6; ++j) {
                    var subFraction = j / 6
                    var subAngle = subStartAngle - subFraction * subSweep
                    var subRad = radians(subAngle)
                    var subCos = Math.cos(subRad)
                    var subSin = Math.sin(subRad)

                    ctx.beginPath()
                    ctx.moveTo(cx + (subRadius + 6) * subCos,
                               cy + (subRadius + 6) * subSin)
                    ctx.lineTo(cx + (subRadius - 5) * subCos,
                               cy + (subRadius - 5) * subSin)
                    ctx.lineWidth = 1.0
                    ctx.strokeStyle = j >= 5 ? root.dangerColor : "#dce8f1"
                    ctx.stroke()
                }

                // E/F hoac C/H o hai dau cung.
                var labelRadius = subRadius - root.dialSize * 0.073
                var minRad = radians(subStartAngle)
                var maxRad = radians(subEndAngle)
                ctx.font = "normal " + Math.round(root.dialSize * 0.04)
                           + "px sans-serif"
                ctx.fillStyle = "#dce8f1"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.fillText(root.subMinText,
                             cx + labelRadius * Math.cos(minRad),
                             cy + labelRadius * Math.sin(minRad))
                ctx.fillText(root.subMaxText,
                             cx + labelRadius * Math.cos(maxRad),
                             cy + labelRadius * Math.sin(maxRad))

                // Cham chi thi muc hien tai.
                var clampedSubValue = Math.max(0, Math.min(1, root.subValue))
                var indicatorAngle = subStartAngle - clampedSubValue * subSweep
                var indicatorRad = radians(indicatorAngle)
                var indicatorX = cx + subRadius * Math.cos(indicatorRad)
                var indicatorY = cy + subRadius * Math.sin(indicatorRad)
                ctx.beginPath()
                ctx.arc(indicatorX, indicatorY,
                        root.dialSize * 0.015, 0, Math.PI * 2)
                ctx.fillStyle = "#ffffff"
                ctx.fill()
                ctx.lineWidth = 2
                ctx.strokeStyle = "#20384a"
                ctx.stroke()

                // Bieu tuong nhien lieu hoac nhiet do dong co.
                var iconX = cx
                var iconY = cy + radius - root.dialSize * 0.23
                ctx.lineWidth = 2
                ctx.strokeStyle = "#dce8f1"
                ctx.fillStyle = "#dce8f1"

                if (root.subGaugeType === "temperature") {
                    ctx.beginPath()
                    ctx.arc(iconX, iconY + 8, 5, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.beginPath()
                    ctx.moveTo(iconX, iconY + 7)
                    ctx.lineTo(iconX, iconY - 10)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(iconX, iconY - 10, 3, Math.PI, 0)
                    ctx.stroke()

                    for (var wave = 0; wave < 2; ++wave) {
                        var waveY = iconY + 16 + wave * 5
                        ctx.beginPath()
                        ctx.moveTo(iconX - 12, waveY)
                        ctx.quadraticCurveTo(iconX - 7, waveY - 4,
                                             iconX - 2, waveY)
                        ctx.quadraticCurveTo(iconX + 3, waveY + 4,
                                             iconX + 8, waveY)
                        ctx.stroke()
                    }
                } else {
                    ctx.strokeRect(iconX - 8, iconY - 10, 13, 19)
                    ctx.strokeRect(iconX - 5, iconY - 7, 7, 6)
                    ctx.beginPath()
                    ctx.moveTo(iconX + 5, iconY - 6)
                    ctx.quadraticCurveTo(iconX + 13, iconY - 4,
                                         iconX + 11, iconY + 6)
                    ctx.lineTo(iconX + 8, iconY + 6)
                    ctx.stroke()
                }
            }
        }
    }

    // Cung gia tri duoc tessellate boi scene graph. Khong con Canvas JavaScript
    // repaint moi frame, nen duong cong net hon va on dinh hon tren Raspberry Pi.
    Item {
        id: dynamicArcLayer
        x: (root.width - root.dialSize) / 2
        y: (root.height - root.dialSize) / 2
        width: root.dialSize
        height: width
        antialiasing: true

        // Shape duoc render vao texture 2x va thu ve kich thuoc that.
        // Day la supersampling rieng cho vong sang, tach voi backgroundCanvas.
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4
        layer.textureSize: Qt.size(Math.ceil(width * root.arcRenderScale),
                                   Math.ceil(height * root.arcRenderScale))

        Shape {
            anchors.fill: parent
            opacity: 0.10 + root.progress * 0.20

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.normalArcProgress > 0
                             ? root.accentColor : "transparent"
                strokeWidth: root.dialSize * 0.032
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.dialRadius
                    centerY: root.dialRadius
                    radiusX: root.arcRadius
                    radiusY: root.arcRadius
                    startAngle: root.pathStartAngle
                    sweepAngle: root.normalArcProgress * root.sweepAngle
                    moveToStart: true
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.dangerArcProgress > 0
                             ? root.dangerColor : "transparent"
                strokeWidth: root.dialSize * 0.032
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.dialRadius
                    centerY: root.dialRadius
                    radiusX: root.arcRadius
                    radiusY: root.arcRadius
                    startAngle: root.pathStartAngle
                                + root.dangerProgress * root.sweepAngle
                    sweepAngle: root.dangerArcProgress * root.sweepAngle
                    moveToStart: true
                }
            }
        }

        // Loi sang mong nam tren chinh dau cac vach chia.
        Shape {
            anchors.fill: parent
            opacity: root.dynamicArcOpacity

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.normalArcProgress > 0
                             ? root.accentColor : "transparent"
                strokeWidth: root.dialSize * 0.011
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.dialRadius
                    centerY: root.dialRadius
                    radiusX: root.arcRadius
                    radiusY: root.arcRadius
                    startAngle: root.pathStartAngle
                    sweepAngle: root.normalArcProgress * root.sweepAngle
                    moveToStart: true
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.dangerArcProgress > 0
                             ? root.dangerColor : "transparent"
                strokeWidth: root.dialSize * 0.011
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.dialRadius
                    centerY: root.dialRadius
                    radiusX: root.arcRadius
                    radiusY: root.arcRadius
                    startAngle: root.pathStartAngle
                                + root.dangerProgress * root.sweepAngle
                    sweepAngle: root.dangerArcProgress * root.sweepAngle
                    moveToStart: true
                }
            }
        }

        // Dau cung sang hon tao cam giac dai anh sang dang chay.
        Shape {
            anchors.fill: parent
            opacity: Math.min(0.92, root.dynamicArcOpacity + 0.1)

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.progress > root.dangerProgress
                             ? "#efc6cb" : "#bddce8"
                strokeWidth: root.dialSize * 0.0045
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.dialRadius
                    centerY: root.dialRadius
                    radiusX: root.arcRadius
                    radiusY: root.arcRadius
                    startAngle: root.pathStartAngle
                                + root.arcHeadStart * root.sweepAngle
                    sweepAngle: (root.progress - root.arcHeadStart)
                                * root.sweepAngle
                    moveToStart: true
                }
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.dialSize * 0.015
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Number(root.value).toFixed(root.displayDecimals)
            color: "#f7fbff"
            font.pixelSize: root.dialSize * 0.15
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unitText
            color: "#9aabb8"
            font.pixelSize: root.dialSize * 0.038
            font.letterSpacing: 0.6
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(34,
                                    (root.height - root.dialSize) / 2
                                    + root.dialSize * 0.25)
        text: root.titleText
        color: "#7990a2"
        font.pixelSize: root.dialSize * 0.028
        font.bold: true
        font.letterSpacing: 2
    }
}
