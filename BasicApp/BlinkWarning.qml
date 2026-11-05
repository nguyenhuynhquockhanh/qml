import QtQuick 2.15

Image {
    id: root
    property bool active: false

    visible: active
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true

    SequentialAnimation on opacity {
        running: root.active
        loops: Animation.Infinite

        NumberAnimation { from: 1.0; to: 0.2; duration: 400 }
        NumberAnimation { from: 0.2; to: 1.0; duration: 400 }
    }
}
