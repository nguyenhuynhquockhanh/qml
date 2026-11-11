import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property string imagePrefix: ""

    Item {
        id: drivingVehicle
        z: 3
        x: 484
        y: 332
        width: 56
        height: 102

        Rectangle {
            x: 7
            y: 83
            width: 42
            height: 15
            radius: 8
            color: "#000000"
            opacity: 0.42
        }

        Image {
            anchors.fill: parent
            source: root.imagePrefix + "vehicle-top-display.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }
}
