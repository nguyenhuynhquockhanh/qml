import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600

    property real rasterScale: 1
    property real detailRenderScale: 2
    property bool runningOnEglfs: false
    property real speedVal: 0
    property real rpmVal: 0
    property bool braking: false
    property bool blindLeftActive: false
    property bool blindRightActive: false
    property date currentDateTime: new Date()
    property int ambientTemperature: 20
    property string driveMode: "Driving"
    property int remainingRange: 450
    property int odometer: 12580

    // qmlscene doc file trong images/; Pi doc anh da cai qua image provider.
    readonly property string imagePrefix: runningOnEglfs
                                          ? "image://dashboard/" : "../images/"

    Nen_cum_dong_ho {
        z: 0
        rasterScale: root.rasterScale
    }

    Canh_duong {
        z: 1
        detailRenderScale: root.detailRenderScale
    }

    Cum_hai_dong_ho {
        z: 2
        speedVal: root.speedVal
        rpmVal: root.rpmVal
        rasterScale: root.rasterScale
        imagePrefix: root.imagePrefix
    }

    Xe_trung_bay {
        z: 3
        imagePrefix: root.imagePrefix
    }

    Thong_tin_phia_tren {
        z: 4
        currentDateTime: root.currentDateTime
        ambientTemperature: root.ambientTemperature
    }

    Thong_tin_hanh_trinh {
        z: 4
        driveMode: root.driveMode
        remainingRange: root.remainingRange
        odometer: root.odometer
        detailRenderScale: root.detailRenderScale
    }

    Cum_bieu_tuong_canh_bao {
        z: 4
        braking: root.braking
        imagePrefix: root.imagePrefix
    }

    Vien_cum_dong_ho {
        z: 15
        imagePrefix: root.imagePrefix
    }

    Den_tin_hieu {
        z: 16
        blindLeftActive: root.blindLeftActive
        blindRightActive: root.blindRightActive
        detailRenderScale: root.detailRenderScale
        imagePrefix: root.imagePrefix
    }
}
