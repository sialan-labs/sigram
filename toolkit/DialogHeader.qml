import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Rectangle {
    id: header
    color: "#00000000"

    property alias engine: details.engine
    property alias currentPeer: details.peer
    property bool detailMode

    signal detailRequest()
    signal searchRequest(variant peer)

    Telegram.PeerDetails {
        id: details
    }

    MouseArea {
        anchors.fill: parent
        height: parent.height
        onClicked: detailRequest()
    }

    Row {
        id: title_row
        x: backBtn.x - 10*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*Devices.density
        opacity: 1 - backBtn.opacity

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 10*Devices.fontDensity
            color: CutegramGlobals.titleBarTextsColor
            text: {
                var emoji = CutegramEmojis.parse(details.displayName)
                return emoji
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 9*Devices.fontDensity
            color: CutegramGlobals.titleBarTextsColor
            opacity: 0.5
            text: details.statusText
        }
    }

    Text {
        id: backBtn
        x: detailMode? 10*Devices.density : 20*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        color: header.currentPeer? CutegramGlobals.titleBarTextsColor : "#aaaaaa"
        visible: opacity != 0
        opacity: detailMode? 1 : 0
        font.family: Awesome.family
        font.pixelSize: 18*Devices.fontDensity
        text: Awesome.fa_angle_left

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
        }
        Behavior on x {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
        }
    }

    Row {
        anchors.right: parent.right
        height: parent.height
        anchors.margins: 10*Devices.density

        Button {
            width: height
            height: parent.height
            textFont.family: Awesome.family
            textFont.pixelSize: 13*Devices.fontDensity
            highlightColor: header.currentPeer? "#66e6e6e6" : "#00000000"
            textColor: header.currentPeer? CutegramGlobals.titleBarTextsColor : "#aaaaaa"
            text: Awesome.fa_folder_open_o
        }

        Button {
            width: height
            height: parent.height
            textFont.family: Awesome.family
            textFont.pixelSize: 13*Devices.fontDensity
            highlightColor: header.currentPeer? "#66e6e6e6" : "#00000000"
            textColor: header.currentPeer? CutegramGlobals.titleBarTextsColor : "#aaaaaa"
            text: Awesome.fa_search
            onClicked: searchRequest(details.peer)
        }
    }
}

