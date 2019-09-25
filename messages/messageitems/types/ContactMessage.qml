import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit
import "../../../awesome"

AbstractMessage {
    id: contactMsg
    width: 250*Devices.density
    height: 64*Devices.density

    Telegram.Peer {
        id: peer
        userId: message? message.media.userId : 0
        classType: Telegram.Peer.TypePeerUser
    }

    onCopyRequest: Devices.clipboard = message.media.phoneNumber

    ToolKit.ProfileImage {
        id: img
        anchors.verticalCenter: parent.verticalCenter
        x: y + 8*Devices.density
        height: 48*Devices.density
        width: height
        engine: contactMsg.engine
        source: peer.userId? peer : null
    }

    Item {
        anchors.top: img.top
        anchors.bottom: img.bottom
        anchors.left: img.right
        anchors.right: img.right
        anchors.leftMargin: 8*Devices.density
        anchors.rightMargin: 8*Devices.density

        Text {
            anchors.top: parent.top
            anchors.bottom: parent.verticalCenter
            font.pixelSize: 10*Devices.fontDensity
            verticalAlignment: Text.AlignVCenter
            color: "#333333"
            text: message? (message.media.firstName + " " + message.media.lastName).trim() : ""
        }

        Text {
            anchors.top: parent.verticalCenter
            anchors.bottom: parent.bottom
            font.pixelSize: 10*Devices.fontDensity
            verticalAlignment: Text.AlignVCenter
            color: "#666666"
            text: message? message.media.phoneNumber : ""
        }
    }
}

