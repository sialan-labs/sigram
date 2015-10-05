import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: menu_icon
    height: 20*Devices.density
    width: height

    property color color: "#ffffff"
    property real ratio: 0

    property int layoutDirection: View.layoutDirection

    Column {
        width: Math.min(parent.width, parent.height)
        anchors.centerIn: parent
        spacing: 3*Devices.density
        rotation: ratio*180
        transform: Scale { origin.x: width/2; origin.y: height/2; xScale: layoutDirection==Qt.LeftToRight?1:-1}

        Rectangle {
            x: parent.width - width
            width: (1-ratio)*parent.width*0.25 + parent.width*0.75
            height: 2*Devices.density
            radius: height/2
            color: menu_icon.color
            rotation: ratio*35
        }

        Rectangle {
            x: parent.width - width
            width: parent.width + ratio*parent.width*0.1
            height: 2*Devices.density
            radius: height/2
            color: menu_icon.color
        }

        Rectangle {
            x: parent.width - width
            width: (1-ratio)*parent.width*0.25 + parent.width*0.75
            height: 2*Devices.density
            radius: height/2
            color: menu_icon.color
            rotation: -ratio*35
        }
    }
}

