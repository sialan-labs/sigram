import QtQuick 2.0
import AsemanTools 1.0

Item {
    width: 100*Devices.density
    height: 20*Devices.density

    property bool closeButton: true
    property bool minimizeButton: true
    property bool fullscreenButton: true
    property bool fullscreened: false

    property bool hovered: marea.containsMouse || close_marea.containsMouse ||
                           minimize_marea.containsMouse || fscreen_marea.containsMouse

    QtObject {
        id: privates

        property size windowSize: Qt.size(View.window.width, View.window.height)
        onWindowSizeChanged: if(!signal_blocker.running) fullscreened = false
    }

    Timer {
        id: signal_blocker
        interval: 1000
    }

    MouseArea {
        id: marea
        hoverEnabled: true
        anchors.fill: parent
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
            color: closeButton && View.window.active? "#ff3333" : "#aa888888"
            visible: closeButton

            Item {
                anchors.fill: parent
                visible: hovered

                Rectangle {
                    width: parent.width - 4*Devices.density
                    height: 2*Devices.density
                    color: "#444444"
                    rotation: 45
                    transformOrigin: Item.Center
                    anchors.centerIn: parent
                    smooth: true
                }

                Rectangle {
                    width: parent.width - 4*Devices.density
                    height: 2*Devices.density
                    color: "#444444"
                    rotation: -45
                    transformOrigin: Item.Center
                    anchors.centerIn: parent
                    smooth: true
                }
            }

            MouseArea {
                id: close_marea
                hoverEnabled: true
                onClicked: View.window.close()
                visible: closeButton
                anchors.fill: parent
            }
        }

        Rectangle {
            height: parent.height
            width: height
            radius: height/2
            color: minimizeButton && View.window.active? "#ffcc00" : "#aa888888"
            visible: minimizeButton

            Rectangle {
                width: parent.width - 4*Devices.density
                height: 2*Devices.density
                color: "#444444"
                anchors.centerIn: parent
                smooth: true
                visible: hovered
            }

            MouseArea {
                id: minimize_marea
                hoverEnabled: true
                onClicked: View.window.showMinimized()
                visible: minimizeButton
                anchors.fill: parent
            }
        }

        Rectangle {
            height: parent.height
            width: height
            radius: height/2
            color: fullscreenButton && View.window.active? "#33cc00" : "#aa888888"

            MouseArea {
                id: fscreen_marea
                hoverEnabled: true
                anchors.fill: parent
                visible: fullscreenButton
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

