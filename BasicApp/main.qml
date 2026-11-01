import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Window {
    id: window

    readonly property real designWidth: 1024
    readonly property real designHeight: 600

    width: designWidth
    height: designHeight
    visible: true
    title: "Instrument Cluster"
    color: "#020509"

    property real speedVal: 0
    readonly property real rpmVal: speedVal / 30
    property bool increasing: true
    property real speedVelocity: 0
    property date currentDateTime: new Date()
    property int ambientTemperature: 20
    property string driveMode: "SPORT"
    property bool enableGaugeBlur: false

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: window.currentDateTime = new Date()
    }

    // Du lieu mo phong de kiem tra chuyen dong cua hai dong ho.
    Timer {
        interval: 16
        running: true
        repeat: true

        onTriggered: {
            if (increasing) {
                speedVelocity = Math.min(2.4, speedVelocity + 0.03)
                speedVal = Math.min(240, speedVal + speedVelocity)
                if (speedVal >= 240) {
                    increasing = false
                    speedVelocity = 0
                }
            } else {
                speedVelocity = Math.min(2.8, speedVelocity + 0.035)
                speedVal = Math.max(0, speedVal - speedVelocity)
                if (speedVal <= 0) {
                    increasing = true
                    speedVelocity = 0
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#07111c" }
            GradientStop { position: 0.48; color: "#02070c" }
            GradientStop { position: 1.0; color: "#000204" }
        }
    }

    // Toan bo giao dien duoc thiet ke tren khung 1024x600 va scale dong deu.
    Item {
        id: designArea
        width: window.designWidth
        height: window.designHeight
        anchors.centerIn: parent
        transformOrigin: Item.Center
        scale: Math.min(window.width / width, window.height / height)

        // Vien kim loai bao quanh toan bo instrument cluster.
        Rectangle {
            id: clusterOuterBorder
            anchors.fill: parent
            anchors.margins: 4
            radius: 74
            border.width: 2
            border.color: "#e1e6e9"

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#dbe1e4" }
                GradientStop { position: 0.28; color: "#77838b" }
                GradientStop { position: 0.58; color: "#3c474f" }
                GradientStop { position: 0.82; color: "#aeb7bc" }
                GradientStop { position: 1.0; color: "#eef1f2" }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 7
                radius: 67
                color: "#02070c"
                border.width: 2
                border.color: "#263b49"
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 9

            CustomGauge {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 370
                Layout.preferredWidth: 400
                Layout.maximumWidth: 400
                minValue: 0
                maxValue: 240
                majorStep: 20
                value: window.speedVal
                titleText: ""
                unitText: "km/h"
                accentColor: "#16a9ff"
                dangerStart: 220
                displayDecimals: 0
                enableDynamicBlur: window.enableGaugeBlur
                showSubGauge: true
                subGaugeType: "fuel"
                subValue: 0.62
                subMinText: "E"
                subMaxText: "F"
            }

            Item {
                Layout.preferredWidth: 226
                Layout.fillHeight: true

                Column {
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: 13

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(window.currentDateTime, "dd / MM / yyyy")
                        color: "#a9bbc8"
                        font.pixelSize: 16
                        font.letterSpacing: 1.2
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 150
                        height: 1
                        color: "#1b6d9f"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "D"
                        color: "#f7fbff"
                        font.pixelSize: 72
                        font.weight: Font.Light
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "READY TO DRIVE"
                        color: "#16a9ff"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.6
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 176
                        height: 70
                        radius: 8
                        color: "#07121b"
                        border.width: 1
                        border.color: "#173447"

                        Column {
                            anchors.centerIn: parent
                            spacing: 3

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "AMBIENT TEMP"
                                color: "#718696"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: window.ambientTemperature + "\u00b0C"
                                color: "#f2f7fb"
                                font.pixelSize: 25
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 176
                        height: 70
                        radius: 8
                        color: "#07121b"
                        border.width: 1
                        border.color: "#173447"

                        Column {
                            anchors.centerIn: parent
                            spacing: 3

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "DRIVE MODE"
                                color: "#718696"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: window.driveMode
                                color: "#ff4055"
                                font.pixelSize: 22
                                font.bold: true
                                font.letterSpacing: 1.8
                            }
                        }
                    }
                }
            }

            CustomGauge {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 330
                Layout.preferredWidth: 350
                Layout.maximumWidth: 350
                minValue: 0
                maxValue: 8
                majorStep: 1
                value: window.rpmVal
                titleText: ""
                unitText: "x1000 rpm"
                accentColor: "#16a9ff"
                dangerStart: 6.5
                displayDecimals: 1
                enableDynamicBlur: window.enableGaugeBlur
                showSubGauge: true
                subGaugeType: "temperature"
                subValue: 0.48
                subMinText: "C"
                subMaxText: "H"
            }
        }
    }
}
