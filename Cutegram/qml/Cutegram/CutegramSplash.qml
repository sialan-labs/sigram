import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0

Rectangle {
    width: 100
    height: 62
    color: backColor0

    Column {
        anchors.centerIn: parent
        spacing: 20*Devices.density

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 50*Devices.fontDensity
            text: "Cutegram One"
            color: textColor0
        }

        Indicator {
            id: indicator
            anchors.horizontalCenter: parent.horizontalCenter
            indicatorSize: 22*Devices.density
            modern: true
            light: false
            Component.onCompleted: start()
        }
    }

    AsemanLogo {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        height: 16
        dark: true
    }
}
