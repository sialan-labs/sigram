import QtQuick 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import "../globals"

Rectangle {
    width: parent.width
    height: 36*Devices.density
    y: opened? 0 : -height

    property bool opened: false

    Behavior on y {
        NumberAnimation {easing.type: Easing.OutCubic; duration: 200}
    }

    Text {
        id: txt
        anchors.verticalCenter: parent.verticalCenter
        x: y
        font.pixelSize: 9*Devices.fontDensity
        color: "#333333"
    }

    Button {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: y
        normalColor: "#00000000"
        highlightColor: "#11000000"
        hoverColor: "#00000000"
        radius: 3*Devices.density
        textColor: CutegramGlobals.highlightColors
        text: qsTr("Dismiss")
        onClicked: opened = false
    }

    Timer {
        id: hideTimer
        interval: 3000
        repeat: false
        onTriggered: opened = false
    }

    function showError(code, text) {
        txt.text = qsTr("Error %1: %2").arg(mlmodel.errorCode).arg(mlmodel.errorText)
        opened = true
        hideTimer.restart()

    }
}
