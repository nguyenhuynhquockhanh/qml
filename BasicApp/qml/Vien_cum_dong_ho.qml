import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property string imagePrefix: ""

    // Vien 2:1 duoc phong theo chieu ngang va giu nguyen ti le anh.
    // Phan vien that nam can giua o khoang y=73..523 tren canvas 1024x600.
    Image {
        id: clusterBezel
        z: 15
        x: -34
        y: 27
        width: 1092
        height: 546
        source: root.imagePrefix + "cluster-bezel.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
    }
}
