import QtQuick 2.15

Item {
    id: root
    width: 1024
    height: 600
    property date currentDateTime: new Date()
    property int ambientTemperature: 20

    // Cum thong tin tren cung: gio/ngay, cap so va nhiet do moi truong.
    Item {
        id: topInformation
        z: 4
        x: 352
        y: 120
        width: 320
        height: 61

        Column {
            x: 0
            y: 1
            width: 100
            spacing: -1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.currentDateTime, "hh:mm AP")
                color: "#e9f0f5"
                font.pixelSize: 17
                font.weight: Font.Medium
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(root.currentDateTime, "dd/MM/yyyy")
                color: "#728696"
                font.pixelSize: 9
                font.letterSpacing: 0.7
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: -4
            text: "D"
            color: "#f8fbfd"
            font.pixelSize: 30
            font.weight: Font.Medium
        }

        Text {
            x: 220
            y: 1
            width: 100
            horizontalAlignment: Text.AlignHCenter
            text: root.ambientTemperature + "\u00b0C"
            color: "#e9f0f5"
            font.pixelSize: 17
            font.weight: Font.Medium
        }

        Rectangle {
            x: 80
            y: 42
            width: 160
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#001a2b" }
                GradientStop { position: 0.5; color: "#157db6" }
                GradientStop { position: 1.0; color: "#001a2b" }
            }
        }
    }
}
