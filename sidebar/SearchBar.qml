import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Rectangle {
    color: "#e6e6e6"
    height: 36*Devices.density

    signal searchRequest(string keyword)

    TextInput {
        anchors.fill: parent
        anchors.margins: 10*Devices.density
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignLeft
        selectByMouse: true
        selectionColor: CutegramGlobals.baseColor
        selectedTextColor: "#ffffff"
        color: "#333333"
        font.pixelSize: 9*Devices.fontDensity
        onAccepted: searchRequest(text)

        Text {
            anchors.fill: parent
            font: parent.font
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: "#999999"
            text: qsTr("Search")
            visible: parent.text.length == 0
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10*Devices.density
        font.family: Awesome.family
        font.pixelSize: 10*Devices.fontDensity
        color: "#959595"
        text: Awesome.fa_search
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onPressed: mouse.accepted = false
    }
}

