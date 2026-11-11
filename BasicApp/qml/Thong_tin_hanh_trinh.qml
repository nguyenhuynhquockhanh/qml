import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property string driveMode: "Driving"
    property int remainingRange: 450
    property int odometer: 12580
    property real detailRenderScale: 2

    Text {
        z: 4
        x: 430
        y: 176
        width: 170
        horizontalAlignment: Text.AlignHCenter
        text: root.driveMode
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
            width: 39 * root.detailRenderScale
            height: 30 * root.detailRenderScale
            scale: 1 / root.detailRenderScale
            transformOrigin: Item.TopLeft
            renderTarget: Canvas.FramebufferObject
            antialiasing: true

            onAvailableChanged: if (available) requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.scale(root.detailRenderScale,
                          root.detailRenderScale)
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
            text: root.remainingRange
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
            text: root.odometer
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
}
