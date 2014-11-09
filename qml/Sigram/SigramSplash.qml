import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0

Rectangle {
    width: 100
    height: 62
    color: "#333333"

    Column {
        anchors.centerIn: parent
        spacing: 20*physicalPlatformScale

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: SApp.globalFontFamily
            font.pixelSize: 50*fontsScale
            text: "Sigram One"
            color: "#ffffff"
        }

        Indicator {
            id: indicator
            anchors.horizontalCenter: parent.horizontalCenter
            indicatorSize: 22*physicalPlatformScale
            modern: true
            light: true
            Component.onCompleted: start()
        }
    }

    SialanLogo {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*physicalPlatformScale
        height: 16
    }
}
