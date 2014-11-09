import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: "#333333"
    visible: active

    property bool active: false

    onActiveChanged: {
        if( active )
            indicator.start()
        else
            indicator.stop()
    }

    MouseArea {
        anchors.fill: parent
    }

    Column {
        anchors.centerIn: parent
        spacing: 8*physicalPlatformScale

        Indicator {
            id: indicator
            anchors.horizontalCenter: parent.horizontalCenter
            indicatorSize: 22*physicalPlatformScale
            modern: true
            light: true
            Component.onCompleted: start()
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: SApp.globalFontFamily
            font.pixelSize: 11*fontsScale
            color: "#ffffff"
            text: qsTr("Loading...")
        }
    }
}
