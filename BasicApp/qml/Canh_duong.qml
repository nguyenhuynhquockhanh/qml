import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property real detailRenderScale: 2

    // Lan duong phoi canh, ve mot lan o 2x de sac net tren man hinh Pi.
    Canvas {
        id: roadScene
        z: 1
        x: 352
        y: 215
        width: 320 * root.detailRenderScale
        height: 270 * root.detailRenderScale
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
}
