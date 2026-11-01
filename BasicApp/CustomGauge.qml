import QtQuick 2.15

Item {
    id: root

    property real value: 0
    property real minValue: 0
    property real maxValue: 240
    property real majorStep: 20
    property int minorTicksPerStep: 4
    property string titleText: "SPEED"
    property string unitText: "km/h"
    property color accentColor: "#2e92bf"
    property color dangerColor: "#d8263d"
    property real dangerStart: 220
    property int displayDecimals: 0
    property bool enableDynamicBlur: false
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
    readonly property real renderScale: 2
    readonly property real dialSize: Math.min(width, height)

    function requestBackgroundPaint() {
        backgroundCanvas.requestPaint()
    }

    onWidthChanged: {
        requestBackgroundPaint()
        valueArcCanvas.requestPaint()
    }
    onHeightChanged: {
        requestBackgroundPaint()
        valueArcCanvas.requestPaint()
    }
    onProgressChanged: valueArcCanvas.requestPaint()
    onMinValueChanged: requestBackgroundPaint()
    onMaxValueChanged: requestBackgroundPaint()
    onMajorStepChanged: requestBackgroundPaint()
    onMinorTicksPerStepChanged: requestBackgroundPaint()
    onAccentColorChanged: {
        requestBackgroundPaint()
        valueArcCanvas.requestPaint()
    }
    onDangerColorChanged: {
        requestBackgroundPaint()
        valueArcCanvas.requestPaint()
    }
    onDangerStartChanged: {
        requestBackgroundPaint()
        valueArcCanvas.requestPaint()
    }
    onEnableDynamicBlurChanged: valueArcCanvas.requestPaint()
    onShowSubGaugeChanged: requestBackgroundPaint()
    onSubGaugeTypeChanged: requestBackgroundPaint()
    onSubValueChanged: requestBackgroundPaint()
    onSubMinTextChanged: requestBackgroundPaint()
    onSubMaxTextChanged: requestBackgroundPaint()

    Canvas {
        id: backgroundCanvas
        width: Math.ceil(root.width * root.renderScale)
        height: Math.ceil(root.height * root.renderScale)
        scale: 1 / root.renderScale
        transformOrigin: Item.TopLeft
        renderTarget: Canvas.Image
        antialiasing: true

        onAvailableChanged: if (available) requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.scale(root.renderScale, root.renderScale)

            var cx = root.width / 2
            var cy = root.height / 2
            var radius = root.dialSize / 2 - 18
            if (radius <= 60)
                return

            function radians(angle) {
                return (angle - 90) * Math.PI / 180
            }

            var arcRadius = radius - 29
            var startRad = radians(root.startAngle)
            var endRad = radians(root.startAngle + root.sweepAngle)
            var dangerFraction = Math.max(0, Math.min(1,
                (root.dangerStart - root.minValue) / (root.maxValue - root.minValue)))
            var dangerRad = radians(root.startAngle + dangerFraction * root.sweepAngle)

            ctx.beginPath()
            ctx.arc(cx, cy, arcRadius, startRad, endRad)
            ctx.lineWidth = 4
            ctx.strokeStyle = "#14232d"
            ctx.stroke()

            // Vung redline co dinh; cung gia tri dong se duoc ve o Canvas rieng.
            ctx.save()
            ctx.shadowBlur = 3
            ctx.shadowColor = root.dangerColor
            ctx.beginPath()
            ctx.arc(cx, cy, arcRadius, dangerRad, endRad)
            ctx.lineWidth = 3.5
            ctx.strokeStyle = root.dangerColor
            ctx.stroke()
            ctx.restore()

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
                var tickOuter = radius - 38
                var tickInner = tickOuter - (isMajor ? 20 : 10)
                var tickValue = root.minValue + fraction * range
                var isDanger = tickValue >= root.dangerStart

                ctx.beginPath()
                ctx.moveTo(cx + tickOuter * cosA, cy + tickOuter * sinA)
                ctx.lineTo(cx + tickInner * cosA, cy + tickInner * sinA)
                ctx.lineWidth = isMajor ? 2.4 : 1.1
                ctx.strokeStyle = isDanger ? root.dangerColor
                                           : (isMajor ? "#f2f7fb" : "#7e8d9b")
                ctx.stroke()

                if (isMajor) {
                    var labelRadius = radius - 77
                    var labelValue = root.minValue + (i / totalTicks) * range
                    ctx.fillStyle = "#eef5fa"
                    ctx.font = "17px sans-serif"
                    ctx.fillText(Math.round(labelValue).toString(),
                                 cx + labelRadius * cosA,
                                 cy + labelRadius * sinA)
                }
            }

            if (root.showSubGauge) {
                var subRadius = radius - 38
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
                ctx.lineWidth = 4.5
                ctx.strokeStyle = root.accentColor
                ctx.stroke()
                ctx.restore()

                ctx.save()
                ctx.shadowBlur = 3
                ctx.shadowColor = root.dangerColor
                ctx.beginPath()
                ctx.arc(cx, cy, subRadius, subSplitRad, subEndRad, true)
                ctx.lineWidth = 4.5
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
                    ctx.lineWidth = 1.5
                    ctx.strokeStyle = j >= 5 ? root.dangerColor : "#dce8f1"
                    ctx.stroke()
                }

                // E/F hoac C/H o hai dau cung.
                var labelRadius = subRadius - 24
                var minRad = radians(subStartAngle)
                var maxRad = radians(subEndAngle)
                ctx.font = "bold 16px sans-serif"
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
                ctx.arc(indicatorX, indicatorY, 5, 0, Math.PI * 2)
                ctx.fillStyle = "#ffffff"
                ctx.fill()
                ctx.lineWidth = 2
                ctx.strokeStyle = "#20384a"
                ctx.stroke()

                // Bieu tuong nhien lieu hoac nhiet do dong co.
                var iconX = cx
                var iconY = cy + radius - 76
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

    // Cung sang thay cho kim, chay quanh mat so theo gia tri hien tai.
    Canvas {
        id: valueArcCanvas
        width: root.dialSize
        height: width
        anchors.centerIn: parent
        renderTarget: Canvas.Image
        antialiasing: true

        onAvailableChanged: if (available) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = width / 2
            var cy = height / 2
            var radius = width / 2 - 18
            var arcRadius = radius - 29
            var currentProgress = root.progress
            if (radius <= 60 || currentProgress <= 0)
                return

            function radians(angle) {
                return (angle - 90) * Math.PI / 180
            }

            function drawGlowArc(fromProgress, toProgress, color,
                                 lineWidth, blur, opacity) {
                if (toProgress <= fromProgress)
                    return

                var fromAngle = root.startAngle + fromProgress * root.sweepAngle
                var toAngle = root.startAngle + toProgress * root.sweepAngle
                ctx.save()
                ctx.lineCap = "round"
                ctx.globalAlpha = opacity
                ctx.shadowBlur = root.enableDynamicBlur ? blur : 0
                ctx.shadowColor = color
                ctx.beginPath()
                ctx.arc(cx, cy, arcRadius,
                        radians(fromAngle), radians(toAngle))
                ctx.lineWidth = lineWidth
                ctx.strokeStyle = color
                ctx.stroke()
                ctx.restore()
            }

            var dangerProgress = Math.max(0, Math.min(1,
                (root.dangerStart - root.minValue) / (root.maxValue - root.minValue)))
            var normalEnd = Math.min(currentProgress, dangerProgress)
            var colorIntensity = 0.34 + currentProgress * 0.48

            drawGlowArc(0, normalEnd, root.accentColor,
                        5, 10, colorIntensity)
            if (currentProgress > dangerProgress)
                drawGlowArc(dangerProgress, currentProgress,
                            root.dangerColor, 5, 10, colorIntensity)

            // Dau cung sang hon tao cam giac anh sang dang chay.
            var headStart = Math.max(0, currentProgress - 0.055)
            var headColor = currentProgress > dangerProgress
                            ? "#efc6cb" : "#bddce8"
            drawGlowArc(headStart, currentProgress, headColor,
                        2, 12, Math.min(0.92, colorIntensity + 0.1))
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
            font.pixelSize: root.dialSize * 0.16
            font.weight: Font.Bold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unitText
            color: "#9aabb8"
            font.pixelSize: root.dialSize * 0.032
            font.letterSpacing: 0.8
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
