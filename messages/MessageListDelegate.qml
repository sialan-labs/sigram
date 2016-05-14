import QtQuick 2.0
import "messageitems" as MessageItems

MessageItems.AutoMessageItem {
    engine: messagesModel.engine
    messageItem: model.item
    message: model.message
    fromUserItem: model.fromUserItem
    out: model.out
    sent: model.sent
    unread: model.unread
    dateTime: model.dateTime
    forwardFromPeer: model.forwardFromPeer
    replyMsgId: model.replyMsgId
    views: model.item.views
    fileName: model.fileName
    fileMimeType: model.fileMimeType
    fileTitle: model.fileTitle
    filePerformer: model.filePerformer
    fileDuration: model.fileDuration
    fileIsVoice: model.fileIsVoice
    fileSize: model.fileSize

    downloadable: model.downloadable
    uploading: model.uploading
    downloading: model.downloading
    transfaring: model.transfaring
    transfared: model.transfared
    transfaredSize: model.transfaredSize
    totalSize: model.totalSize
    filePath: model.filePath
    thumbPath: model.thumbPath

    messageType: model.messageType
    replyType: model.replyType
    peerType: messagesModel.currentPeer? messagesModel.currentPeer.classType : -1
    replyMessage: model.replyMessage
    replyPeer: model.replyPeer
    transformOrigin: out? Item.Right : Item.Left
}

