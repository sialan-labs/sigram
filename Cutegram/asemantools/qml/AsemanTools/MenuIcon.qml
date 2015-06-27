import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: menu_icon
    width: 100*Devices.density
    height: 100*Devices.density

    property color color: "#ffffff"

    Column {
        width: Math.min(parent.width, parent.height)
        anchors.centerIn: parent
        spacing: 3*Devices.density

        Rectangle {
            width: parent.width
            height: 2*Devices.density
            radius: height/2
            color: menu_icon.color
        }

        Rectangle {
            width: parent.width
            height: 2*Devices.density
            radius: height/2
            color: menu_icon.color
        }

        Rectangle {
            width: parent.width
            height: 2*Devices.density
            radius: height/2
            color: menu_icon.color
        }
    }
}

