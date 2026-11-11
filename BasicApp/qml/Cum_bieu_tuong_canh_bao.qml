import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property bool braking: false
    property string imagePrefix: ""

    // Cac den canh bao mo phong tu bo icon vector nguoi dung cung cap.
    Item {
        id: warningIndicators
        z: 4
        anchors.fill: parent

        Repeater {
            model: [
                { px: 65, py: 224, file: "warning-headlamp.png", brake: false },
                { px: 65, py: 258, file: "warning-battery.png", brake: false },
                { px: 65, py: 292, file: "warning-tire.png", brake: false },
                { px: 65, py: 326, file: "warning-brake-left.png", brake: true },
                { px: 937, py: 224, file: "warning-engine.png", brake: false },
                { px: 937, py: 258, file: "warning-seatbelt.png", brake: false },
                { px: 937, py: 292, file: "warning-oil.png", brake: false },
                { px: 937, py: 326, file: "warning-brake-right.png", brake: true }
            ]

            delegate: Image {
                x: modelData.px
                y: modelData.py
                width: 22
                height: 22
                source: root.imagePrefix + modelData.file
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: 0.78
                visible: !modelData.brake || root.braking
            }
        }
    }
}
