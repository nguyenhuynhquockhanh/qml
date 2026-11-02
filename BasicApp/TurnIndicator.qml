import QtQuick 2.15

Item {
    id: root

    property bool pointsLeft: true
    property bool active: true
    property color signalColor: "#49ef70"
    property real pulseOpacity: 1.0

    width: 48
    height: 24
    opacity: active ? pulseOpacity : 0.22

    Canvas {
        id: iconCanvas
        width: root.width * 2
        height: root.height * 2
        scale: 0.5
        transformOrigin: Item.TopLeft
        renderTarget: Canvas.Image
        antialiasing: true

        onAvailableChanged: if (available) requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.scale(2, 2)

            if (!root.pointsLeft) {
                ctx.translate(root.width, 0)
                ctx.scale(-1, 1)
            }

            ctx.save()
            ctx.shadowBlur = 7
            ctx.shadowColor = root.signalColor
            ctx.fillStyle = root.signalColor
            ctx.beginPath()
            ctx.moveTo(2, 12)
            ctx.lineTo(17, 2)
            ctx.lineTo(17, 8)
            ctx.lineTo(37, 8)
            ctx.lineTo(37, 16)
            ctx.lineTo(17, 16)
            ctx.lineTo(17, 22)
            ctx.closePath()
            ctx.fill()
            ctx.restore()

            ctx.strokeStyle = root.signalColor
            ctx.lineWidth = 1.4
            ctx.globalAlpha = 0.72
            ctx.beginPath()
            ctx.moveTo(40, 8)
            ctx.lineTo(46, 8)
            ctx.moveTo(40, 12)
            ctx.lineTo(47, 12)
            ctx.moveTo(40, 16)
            ctx.lineTo(46, 16)
            ctx.stroke()
        }
    }

    onPointsLeftChanged: iconCanvas.requestPaint()
    onSignalColorChanged: iconCanvas.requestPaint()

    SequentialAnimation on pulseOpacity {
        running: root.active
        loops: Animation.Infinite

        NumberAnimation {
            from: 1.0
            to: 0.24
            duration: 380
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            from: 0.24
            to: 1.0
            duration: 380
            easing.type: Easing.InOutQuad
        }
    }
}
