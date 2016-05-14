import QtQuick 2.0
import AsemanTools 1.0
import "../globals"

Item {
    width: txt.width + combo.width + 10*Devices.density
    height: Math.max(txt.height, combo.height)

    property alias text: txt.text
    property alias textColor: txt.color
    property alias textFont: txt.font

    property alias modelArray: combo.modelArray
    property alias currentIndex: combo.currentIndex
    readonly property bool menuVisible: combo.menuVisible

    Text {
        id: txt
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        font.pixelSize: 12*Devices.fontDensity
        color: "#666666"
    }

    ComboBox {
        id: combo
        width: 120*Devices.density
        height: 32*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: -14*Devices.density
        layoutDirection: Qt.RightToLeft
        iconColor: CutegramGlobals.highlightColors
        textColor: iconColor
        iconSize: 15*Devices.fontDensity
    }
}

