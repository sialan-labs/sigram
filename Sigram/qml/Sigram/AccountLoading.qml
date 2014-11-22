import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: backColor0
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
            light: false
            Component.onCompleted: start()
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: SApp.globalFontFamily
            font.pixelSize: 11*fontsScale
            color: textColor0
            text: qsTr("Loading...")
        }
    }
}
