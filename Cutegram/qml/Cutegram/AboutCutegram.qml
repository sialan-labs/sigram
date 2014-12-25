import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: Desktop.titleBarColor

    Image {
        id: logo_img
        anchors.centerIn: parent
        width: 192
        height: width
        sourceSize: Qt.size(width,height)
        source: "files/icon.png"
    }

    Text {
        id: cutegram_txt
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo_img.bottom
        font.family: AsemanApp.globalFontFamily
        font.pixelSize: 30*Devices.fontDensity
        color: Desktop.titleBarTextColor
        text: "Cutegram"
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: cutegram_txt.bottom
        anchors.leftMargin: 40*Devices.density
        anchors.rightMargin: 40*Devices.density
        font.family: AsemanApp.globalFontFamily
        font.pixelSize: 9*Devices.fontDensity
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: Desktop.titleBarTextColor
        text: qsTr("Cutegram is a telegram client by Aseman. It's free and opensource and released "+
                   "under GPLv3 licenses.")
    }

    AsemanLogo {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        height: 30*Devices.density
        dark: !Desktop.titleBarIsDark
    }
}

