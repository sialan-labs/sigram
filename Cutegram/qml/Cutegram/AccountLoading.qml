import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: backColor0
    visible: active

    property bool active: false

    onActiveChanged: {
        if( active ) {
            indicator.start()
            logout_timout.restart()
        } else {
            indicator.stop()
            logout_timout.stop()
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    Column {
        anchors.centerIn: parent
        spacing: 8*Devices.density

        Indicator {
            id: indicator
            anchors.horizontalCenter: parent.horizontalCenter
            indicatorSize: 22*Devices.density
            modern: true
            light: false
            Component.onCompleted: start()
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(11*Devices.fontDensity)
            color: textColor0
            text: qsTr("Loading...")
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: 80*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 10*Devices.fontDensity
        font.underline: true
        color: masterPalette.highlight
        text: qsTr("Logout & Relogin")
        visible: !logout_timout.running

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10*Devices.density
            cursorShape: Qt.PointingHandCursor
            onClicked: Cutegram.logout(telegramObject.phoneNumber)
        }
    }

    Timer {
        id: logout_timout
        interval: 20000
        repeat: false
    }
}
