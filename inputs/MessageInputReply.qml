import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    height: replyMsg.height + 30*Devices.density

    property alias messageId: msgFetcher.messageId
    property alias currentPeer: msgFetcher.inputPeer
    property alias engine: msgFetcher.engine
    property alias replyMessage: msgFetcher.result

    Telegram.MessageFetcher {
        id: msgFetcher
    }

    Rectangle {
        anchors.left: replyMsg.left
        anchors.leftMargin: 8*Devices.density
        anchors.top: replyMsg.bottom
        width: 2*Devices.density
        height: 8*Devices.density
        color: CutegramGlobals.highlightColors
    }

    ToolKit.ReplyMessage {
        id: replyMsg
        x: y
        color: CutegramGlobals.highlightColors
        fontsColor: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        engine: msgFetcher.engine
        user: msgFetcher.fromUser
        message: msgFetcher.result
        mediaType: msgFetcher.mediaType
    }


    Button {
        anchors.verticalCenter: parent.verticalCenter
        height: 42*Devices.density
        width: height
        anchors.right: parent.right
        anchors.rightMargin: 8*Devices.density
        text: Awesome.fa_close
        textColor: "#db2424"
        highlightColor: "#eeeeee"
        radius: 3*Devices.density
        textFont.family: Awesome.family
        textFont.pixelSize: 14*Devices.fontDensity
        onClicked: {
            messageId = 0
            currentPeer = null
        }
    }
}

