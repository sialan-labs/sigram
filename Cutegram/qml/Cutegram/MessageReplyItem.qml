import QtQuick 2.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import AsemanTools 1.0

Item {
    id: msg_reply
    width: row.width + 12*Devices.density
    height: row.height + 4*Devices.density
    visible: replyMessage || (message && message.replyToMsgId != 0)

    property Telegram telegram
    property Message message
    property Message replyMessage

    property real typeMessageMediaDocument: 0x2fda2204
    property real typeMessageMediaContact: 0x5e7d2f39
    property real typeMessageMediaEmpty: 0x3ded6320
    property real typeMessageMediaVideo: 0xa2d24290
    property real typeMessageMediaUnsupported: 0x9f84f49e
    property real typeMessageMediaAudio: 0xc6b68300
    property real typeMessageMediaPhoto: 0xc8c45a2a
    property real typeMessageMediaGeo: 0x56e0d474

    signal messageFocusRequest(int msgId)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2*Devices.density

        Rectangle {
            width: 2*Devices.density
            height: parent.height
            color: Cutegram.currentTheme.masterColor
        }

        Column {
            id: column
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2*Devices.density

            Text {
                id: name_text
                font.pixelSize: Math.floor(11*Devices.fontDensity)
                font.family: AsemanApp.globalFont.family
                opacity: 0.8
                color: {
                    if(!replyMessage && (!message || message.out))
                        return Cutegram.currentTheme.messageOutgoingNameColor
                    else
                        return Cutegram.currentTheme.messageIncomingNameColor
                }
                text: {
                    if(!replyMessage && (!message || message.replyToMsgId == 0))
                        return ""

                    var replyMsg = replyMessage? replyMessage : telegram.message(message.replyToMsgId)
                    var replyUser = telegram.user(replyMsg.fromId)
                    return replyUser.firstName + " " + replyUser.lastName
                }
            }

            Image {
                id: media_img
                width: height*imageSize.width/imageSize.height
                height: 48*Devices.density
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                sourceSize: Qt.size(width,height)
                smooth: true
                visible: path.length != 0
                source: path

                property size imageSize: Cutegram.imageSize(source)
                property variant media: {
                    if(!replyMessage && (!message || message.replyToMsgId == 0))
                        return 0

                    var replyMsg = replyMessage? replyMessage : telegram.message(message.replyToMsgId)
                    return replyMsg.media
                }

                property bool hasMedia: media? media.classType != typeMessageMediaEmpty : false
                onHasMediaChanged: {
                    if( !hasMedia )
                        return

                    switch( media.classType )
                    {
                    case typeMessageMediaPhoto:
                        telegramObject.getFile(media.photo.sizes.last.location)
                        break;

                    case typeMessageMediaVideo:
                        telegramObject.getFile(media.video.thumb.location)
                        break;

                    case typeMessageMediaDocument:
                        telegramObject.getFile(media.document.thumb.location)
                        break;

                    default:
                        break;
                    }
                }

                property string path: {
                    var result
                    if(!media)
                        return ""

                    switch( media.classType )
                    {
                    case typeMessageMediaPhoto:
                        result = media.photo.sizes.last.location.download.location;
                        break;

                    case typeMessageMediaVideo:
                        result = media.video.thumb.location.download.location;
                        break;

                    case typeMessageMediaAudio:
                        result = "files/audio.png"
                        break;

                    case typeMessageMediaUnsupported:
                        result = "files/document.png"
                        break;

                    case typeMessageMediaDocument:
                        result = media.document.thumb.location.download.location
                        break;

                    default:
                        result = ""
                        break;
                    }

                    return result
                }
            }

            Text {
                id: txt
                width: htmlWidth>200*Devices.density? 200*Devices.density : htmlWidth
                font.pixelSize: Math.floor(Cutegram.font.pointSize*Devices.fontDensity)-1
                font.family: Cutegram.font.family
                horizontalAlignment: Text.AlignLeft
                opacity: 0.8
                visible: text.length != 0
                textFormat: Text.RichText
                color: {
                    if(!replyMessage && (!message || message.out))
                        return Cutegram.currentTheme.messageOutgoingFontColor
                    else
                        return Cutegram.currentTheme.messageIncomingFontColor
                }
                maximumLineCount: 1
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: {
                    if(!replyMessage && (!message || message.replyToMsgId == 0))
                        return ""

                    var replyMsg = replyMessage? replyMessage : telegram.message(message.replyToMsgId)
                    var msgText = replyMsg.message
                    if(msgText.length > 100)
                        msgText = msgText.slice(0, 100) + "..."

                    return emojis.textToEmojiText(msgText,16,true)
                }

                property real htmlWidth: Cutegram.htmlWidth(text)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(!replyMessage && message.replyToMsgId == 0)
                return

            var replyMsg = replyMessage? replyMessage : telegram.message(message.replyToMsgId)
            msg_reply.messageFocusRequest(replyMsg.id)
        }
    }
}

