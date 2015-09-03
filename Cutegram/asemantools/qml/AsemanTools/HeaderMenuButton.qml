import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: hmb
    width: height
    height: Devices.standardTitleBarHeight
    y: View.statusBarHeight
    x: View.layoutDirection==Qt.LeftToRight? 0 : parent.width - width

    property alias color: rect.color
    property alias buttonColor: menuIcon.color

    property alias ratio: menuIcon.ratio
    property alias pressed: marea.pressed

    signal clicked()

    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.margins: 10*Devices.density
        color: menuIcon.color
        radius: 3*Devices.density
        opacity: pressed? 0.2 : 0
    }

    MenuIcon {
        id: menuIcon
        anchors.centerIn: parent
        layoutDirection: View.layoutDirection

        Behavior on color {
            ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
        }
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        onClicked: hmb.clicked()
    }
}

