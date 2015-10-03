import QtQuick 2.0
import AsemanTools 1.0

Item {
    width: 100*Devices.density
    height: 20*Devices.density

    property bool closeButton: true
    property bool minimizeButton: true
    property bool fullscreenButton: true
    property bool fullscreened: false

    QtObject {
        id: privates

        property size windowSize: Qt.size(View.window.width, View.window.height)
        onWindowSizeChanged: if(!signal_blocker.running) fullscreened = false
    }

    Timer {
        id: signal_blocker
        interval: 1000
    }

    Row {
        height: 12*Devices.density
        x: 8*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8*Devices.density

        Rectangle {
            height: parent.height
            width: height
            radius: height/2
            color: "#ff3333"
            visible: closeButton

            MouseArea {
                onClicked: View.window.close()
                anchors.fill: parent
            }
        }

        Rectangle {
            height: parent.height
            width: height
            radius: height/2
            color: "#ffcc00"
            visible: minimizeButton

            MouseArea {
                onClicked: View.window.showMinimized()
                anchors.fill: parent
            }
        }

        Rectangle {
            height: parent.height
            width: height
            radius: height/2
            color: "#33cc00"
            visible: fullscreenButton

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    signal_blocker.restart()
                    var size = View.screenSize()
                    View.window.showFullScreen()
                    View.window.resize(size.width, size.height)
                    fullscreened = true
                }
            }
        }
    }
}

