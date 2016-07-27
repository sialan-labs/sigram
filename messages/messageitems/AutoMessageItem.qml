import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram

AbstractMessageItem {
    id: item
    height: itemObj? itemObj.height : 100*Devices.density

    property AbstractMessageItem itemObj
    property int peerType: -1

    property bool selected: false

    onPeerTypeChanged: {
        if(itemObj) itemObj.destroy()

        switch(peerType) {
        case Telegram.InputPeer.TypeInputPeerChannel:
            if(messagesModel.megagroup)
                itemObj = chat_component.createObject(item)
            else
                itemObj = channel_component.createObject(item)
            break
        case Telegram.InputPeer.TypeInputPeerSelf:
        case Telegram.InputPeer.TypeInputPeerUser:
            itemObj = conversation_component.createObject(item)
            break
        case Telegram.InputPeer.TypeInputPeerChat:
            itemObj = chat_component.createObject(item)
            break
        default:
            break
        }
    }

    Rectangle {
        color: "#88aaaabb"
        anchors.fill: parent
        visible: selected
    }

    MouseArea {
        anchors.fill: parent
        onClicked: selected = !selected
    }

    Component {
        id: conversation_component
        ConversationMessageItem {
            width: item.width
            maximumHeight: item.maximumHeight
            maximumWidth: item.maximumWidth
            messagesModel: item.messagesModel
            view: item.view
            engine: item.engine
            messageItem: item.messageItem
            message: item.message
            dateTime: item.dateTime
            out: item.out
            sent: item.sent
            unread: item.unread
            replyMsgId: item.replyMsgId
            views: item.views

            fileName: item.fileName
            fileMimeType: item.fileMimeType
            fileTitle: item.fileTitle
            filePerformer: item.filePerformer
            fileDuration: item.fileDuration
            fileIsVoice: item.fileIsVoice
            fileSize: item.fileSize

            downloadable: item.downloadable
            uploading: item.uploading
            downloading: item.downloading
            transfaring: item.transfaring
            transfared: item.transfared
            transfaredSize: item.transfaredSize
            totalSize: item.totalSize
            filePath: item.filePath
            thumbPath: item.thumbPath

            forwardFromPeer: item.forwardFromPeer
            messageType: item.messageType
            replyMessage: item.replyMessage
            replyPeer: item.replyPeer
            replyType: item.replyType

            onForwardRequest: item.forwardRequest()
            onReplyRequest: item.replyRequest()
            onFocusRequest: item.focusRequest(message)
        }
    }
    Component {
        id: channel_component
        ChannelMessageItem {
            width: item.width
            maximumHeight: item.maximumHeight
            maximumWidth: item.maximumWidth
            messagesModel: item.messagesModel
            view: item.view
            engine: item.engine
            messageItem: item.messageItem
            message: item.message
            dateTime: item.dateTime
            out: item.out
            sent: item.sent
            unread: item.unread
            replyMsgId: item.replyMsgId
            views: item.views

            fileName: item.fileName
            fileMimeType: item.fileMimeType
            fileTitle: item.fileTitle
            filePerformer: item.filePerformer
            fileDuration: item.fileDuration
            fileIsVoice: item.fileIsVoice
            fileSize: item.fileSize

            downloadable: item.downloadable
            uploading: item.uploading
            downloading: item.downloading
            transfaring: item.transfaring
            transfared: item.transfared
            transfaredSize: item.transfaredSize
            totalSize: item.totalSize
            filePath: item.filePath
            thumbPath: item.thumbPath

            forwardFromPeer: item.forwardFromPeer
            messageType: item.messageType
            replyMessage: item.replyMessage
            replyPeer: item.replyPeer
            replyType: item.replyType

            onForwardRequest: item.forwardRequest()
            onReplyRequest: item.replyRequest()
            onFocusRequest: item.focusRequest(message)
        }
    }
    Component {
        id: chat_component
        ChatMessageItem {
            width: item.width
            maximumHeight: item.maximumHeight
            maximumWidth: item.maximumWidth
            messagesModel: item.messagesModel
            view: item.view
            engine: item.engine
            fromUserItem: item.fromUserItem
            messageItem: item.messageItem
            message: item.message
            dateTime: item.dateTime
            out: item.out
            sent: item.sent
            unread: item.unread
            replyMsgId: item.replyMsgId
            views: item.views

            fileName: item.fileName
            fileMimeType: item.fileMimeType
            fileTitle: item.fileTitle
            filePerformer: item.filePerformer
            fileDuration: item.fileDuration
            fileIsVoice: item.fileIsVoice
            fileSize: item.fileSize

            downloadable: item.downloadable
            uploading: item.uploading
            downloading: item.downloading
            transfaring: item.transfaring
            transfared: item.transfared
            transfaredSize: item.transfaredSize
            totalSize: item.totalSize
            filePath: item.filePath
            thumbPath: item.thumbPath

            forwardFromPeer: item.forwardFromPeer
            messageType: item.messageType
            replyMessage: item.replyMessage
            replyPeer: item.replyPeer
            replyType: item.replyType

            onForwardRequest: item.forwardRequest()
            onReplyRequest: item.replyRequest()
            onFocusRequest: item.focusRequest(message)
        }
    }
}

