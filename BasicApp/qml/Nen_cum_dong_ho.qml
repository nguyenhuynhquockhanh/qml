import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property real rasterScale: 1

    // Nen xanh-den phu toan man hinh, toa sang nhe tu tam cluster.
    Canvas {
        id: clusterBody
        x: 0
        y: 0
        width: root.width * root.rasterScale
        height: root.height * root.rasterScale
        scale: 1 / root.rasterScale
        transformOrigin: Item.TopLeft
        renderTarget: Canvas.FramebufferObject
        antialiasing: true

        onAvailableChanged: if (available) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.scale(root.rasterScale, root.rasterScale)

            var display = ctx.createRadialGradient(512, 285, 12,
                                                   512, 300, 630)
            display.addColorStop(0.0, "#0a2b46")
            display.addColorStop(0.28, "#071d30")
            display.addColorStop(0.58, "#03101b")
            display.addColorStop(0.82, "#01070c")
            display.addColorStop(1.0, "#000204")
            ctx.fillStyle = display
            ctx.fillRect(0, 0, root.width, root.height)
        }
    }
}
