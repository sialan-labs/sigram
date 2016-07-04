import QtQuick 2.0
import AsemanTools 1.0
import "../globals"

Item {
    width: txt.width + rect.width + 10*Devices.density
    height: Math.max(txt.height, rect.height)

    property alias text: txt.text
    property alias textColor: txt.color
    property alias textFont: txt.font

    property alias color: rect.color
    property alias background: back.color
    property bool checked: false

    Text {
        id: txt
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        font.pixelSize: 12*Devices.fontDensity
        color: "#666666"
    }

    Rectangle {
        id: rect
        width: 24*Devices.density
        height: 16*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        radius: height/2
        color: checked? CutegramGlobals.highlightColors : "#ffffff"
        border.width: 2*Devices.density
        border.color: CutegramGlobals.highlightColors

        Behavior on color {
            ColorAnimation{easing.type: Easing.OutCubic; duration: 250}
        }

        Rectangle {
            height: parent.height
            width: height
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            x: checked? parent.width - width : 0
            color: CutegramGlobals.highlightColors

            Behavior on x {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
            }

            Rectangle {
                id: back
                anchors.fill: parent
                anchors.margins: 2*Devices.density
                radius: height/2
                color: "#ffffff"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: checked = !checked
    }
}

