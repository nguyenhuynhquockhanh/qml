import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property bool blindLeftActive: false
    property bool blindRightActive: false
    property real detailRenderScale: 2
    property string imagePrefix: ""

    Xi_nhan {
        z: 16
        x: 297
        y: 124
        pointsLeft: true
        active: true
        renderScale: root.detailRenderScale
    }

    Xi_nhan {
        z: 16
        x: 679
        y: 124
        pointsLeft: false
        active: true
        renderScale: root.detailRenderScale
    }

    // Hai den diem mu su dung anh trai/phai do nguoi dung cung cap.
    Canh_bao_nhap_nhay {
        z: 16
        x: 242
        y: 115
        width: 42
        height: 42
        active: root.blindLeftActive
        source: root.imagePrefix + "blind-spot-left.png"
    }

    Canh_bao_nhap_nhay {
        z: 16
        x: 740
        y: 115
        width: 42
        height: 42
        active: root.blindRightActive
        source: root.imagePrefix + "blind-spot-right.png"
    }
}
