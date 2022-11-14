import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../inputs" as Inputs
import "../globals"

ToolKit.AccountHomeItem {
    id: msgFrame

    property alias engine: msgList.engine
    property alias currentPeer: msgList.currentPeer

    property alias refreshing: msgList.refreshing

    Image {
        width: parent.width + 100*Devices.density
        height: parent.height
        opacity: 0.5
        source: "files/default_background.png"
        fillMode: Image.PreserveAspectCrop
    }

    MessageList {
        id: msgList
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: msgList.model.editable? messageInput.height : 0
        onReplyRequest: messageInput.reply(peer, message)
    }

    Inputs.MessageInput {
        id: messageInput
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: extraY
        engine: msgFrame.engine
        currentPeer: msgFrame.currentPeer
        messagesModel: msgList.model
        forwarding: msgList.forwarding
        onForward: msgList.forward()

        property real extraY: msgList.model.editable? 0 : -height

        Behavior on extraY {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 200}
        }
    }

    ToolKit.FileDropArea {
        anchors.fill: msgList
        onSendDocumentRequest: msgList.sendDocument(path)
        onSendPhotoRequest: msgList.sendPhoto(path)
    }

    function forwardRequest(inputPeer, msgIds) {
        msgList.forwardMessages(inputPeer, msgIds)
    }

    function forwardDialog(msgIds) {
        msgList.forwardDialog(msgIds)
    }

    function loadFrom(message) {
        msgList.loadFrom(message)
    }
}

