import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "types" as Types
import "../../awesome"
import "../../toolkit" as ToolKit
import "../../thirdparty"
import "../../globals"

Item {
    property MessageListModel messagesModel
    property Flickable view

    property real maximumHeight
    property real maximumWidth
    property Engine engine
    property Message messageItem
    property User fromUserItem
    property string message
    property string dateTime
    property bool out
    property bool sent
    property bool unread
    property int replyMsgId
    property int views

    property int messageType
    property int replyType
    property string fileName
    property string fileMimeType
    property string fileTitle
    property string filePerformer
    property int fileDuration
    property bool fileIsVoice
    property int fileSize

    property variant forwardFromPeer
    property Message replyMessage
    property variant replyPeer

    property bool downloadable
    property bool uploading
    property bool downloading
    property bool transfaring
    property real transfared
    property real transfaredSize
    property real totalSize
    property string filePath
    property string thumbPath

    signal forwardRequest()
    signal replyRequest()
    signal focusRequest(variant message)
}

