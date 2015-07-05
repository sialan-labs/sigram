import QtQuick 2.0
import AsemanTools.Controls 1.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: msg_item
    width: 100
    height: logicalHeight<minimumHeight? minimumHeight : logicalHeight
//    clip: true

    property real messageFrameX: back_rect.x
    property real messageFrameY: back_rect.y
    property real messageFrameWidth: back_rect.width
    property real messageFrameHeight: back_rect.height

    property real logicalHeight: action_item.hasAction? action_item.height: column.height + frameMargins*2 + textMargins*2
    property real minimumHeight: 48*Devices.density
    property real maximumWidth: 2*width/3

    property alias maximumMediaHeight: msg_media.maximumMediaHeight
    property alias maximumMediaWidth: msg_media.maximumMediaWidth

    property bool visibleNames: true

    property Message message
    property User user: telegramObject.user(message.fromId)
    property User fwdUser: telegramObject.user(message.fwdFromId)

    property real minimumWidth: 100*Devices.density
    property real textMargins: 4*Devices.density
    property real frameMargins: 4*Devices.density

    property bool sent: message.sent
    property bool uploading: message.upload.fileId != 0
    property alias isSticker: msg_media.isSticker

    property alias hasMedia: msg_media.hasMedia
    property bool encryptMedia: message.message.length==0 && message.encrypted
    property alias mediaLocation: msg_media.location

    property alias selectedText: msg_txt.selectedText
    property alias messageRect: back_rect

    property bool modernMode: false

    property variant messageLinks: Tools.stringLinks(message.message)
    property bool hasLink: (messageLinks.length!=0)
    property bool allowLoadLinks: telegramObject.userData.isLoadLink(user.id)

    signal dialogRequest(variant dialogObject)
    signal tagSearchRequest(string tag)
    signal messageFocusRequest(int msgId)

    onSentChanged: {
        if( sent )
            indicator.stop()
        else
            indicator.start()
    }

    Connections {
        target: telegramObject.userData
        onLoadLinkChanged: {
            if(id != user.id)
                return

            allowLoadLinks = telegramObject.userData.isLoadLink(user.id)
        }
    }

    AccountMessageAction {
        id: action_item
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        message: msg_item.message
    }

    Row {
        id: frame_row
        anchors.fill: parent
        layoutDirection: message.out? Qt.RightToLeft : Qt.LeftToRight
        visible: !action_item.hasAction
        spacing: frameMargins

        FramedContactImage {
            id: img
            anchors.verticalCenter: parent.verticalCenter
            width: 40*Devices.density
            height: width
            user: msg_item.user
            isChat: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: msg_item.dialogRequest( telegramObject.fakeDialogObject(img.user.id, false) )
            }
        }

        FramedContactImage {
            id: forward_img
            anchors.verticalCenter: parent.verticalCenter
            width: img.width
            height: img.height
            visible: message.fwdFromId != 0 && !msg_media.isSticker
            user: msg_item.fwdUser
            isChat: false

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: msg_item.dialogRequest( telegramObject.fakeDialogObject(forward_img.user.id, false) )
            }
        }

        Item {
            id: spacer
            height: 10
            visible: modernMode
            width: parent.width/2 - (forward_img.width+frameMargins)*forward_img.visible
                   - (img.width+frameMargins) - back_rect.width/2
        }

        Item {
            height: 10
            width: 10*Devices.density
        }

        Item {
            id: back_rect
            width: column.width + 2*textMargins
            height: column.height + 2*textMargins
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: msg_frame_box
                anchors.fill: parent
                anchors.margins: -20*Devices.density
                visible: !Cutegram.currentTheme.messageShadow && !msg_media.isSticker && !uploadItem.isSticker

                Item {
                    anchors.fill: parent
                    anchors.margins: 20*Devices.density

                    Rectangle {
                        id: pointer_rect
                        height: Cutegram.currentTheme.messagePointerHeight*Devices.density
                        width: height
                        anchors.horizontalCenter: message.out? parent.right : parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: back_rect_layer.color
                        transformOrigin: Item.Center
                        rotation: 45
                    }

                    Rectangle {
                        id: back_rect_layer
                        anchors.fill: parent
                        radius: Cutegram.currentTheme.messageRadius*Devices.density
                        color: {
                            if(msg_media.mediaPlayer)
                                return Cutegram.currentTheme.messageAudioColor
                            else
                            if(hasMedia || encryptMedia)
                                return Cutegram.currentTheme.messageMediaColor
                            else
                            if(message.out)
                                return Cutegram.currentTheme.messageOutgoingColor
                            else
                                return Cutegram.currentTheme.messageIncomingColor
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: source
                source: msg_frame_box
                radius: Cutegram.currentTheme.messageShadowSize*Devices.density
                samples: 16
                horizontalOffset: 0
                verticalOffset: 1*Devices.density
                visible: Cutegram.currentTheme.messageShadow && !msg_media.isSticker && !uploadItem.isSticker
                color: Cutegram.currentTheme.messageShadowColor
            }

            Column {
                id: column
                anchors.centerIn: parent
                height: (visibleNames?user_name.height:0) + (uploading?uploadItem.height:0)
                        + (msg_media.hasMedia?msg_media.height:0) + spacing + msg_column.height +
                        (msg_reply.visible? msg_reply.height : 0)
                clip: true

                Text {
                    id: user_name
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    font.family: AsemanApp.globalFont.family
                    lineHeight: 1.3
                    text: user.firstName + " " + user.lastName
                    visible: visibleNames
                    color: {
                        if(msg_media.mediaPlayer)
                            return Cutegram.currentTheme.messageAudioNameColor
                        else
                        if(hasMedia || encryptMedia)
                            return Cutegram.currentTheme.messageMediaNameColor
                        else
                        if(message.out)
                            return Cutegram.currentTheme.messageOutgoingNameColor
                        else
                            return Cutegram.currentTheme.messageIncomingNameColor
                    }
                }

                MessageReplyItem {
                    id: msg_reply
                    telegram: telegramObject
                    message: msg_item.message
                    onMessageFocusRequest: msg_item.messageFocusRequest(msgId)
                }

                AccountMessageUpload {
                    id: uploadItem
                    telegram: telegramObject
                    message: msg_item.message
                }

                AccountMessageMedia {
                    id: msg_media
                    message: msg_item.message
                    visible: msg_media.hasMedia && !uploading
                }

                Column {
                    id: msg_column
                    anchors.right: parent.right

                    Item {
                        id: msg_txt_frame
                        width: msg_txt.width + 8*Devices.density
                        height: msg_txt.height + 8*Devices.density
                        visible: !msg_media.hasMedia && !uploading

                        TextEdit {
                            id: msg_txt
                            width: htmlWidth>maximumWidth? maximumWidth : htmlWidth
                            anchors.centerIn: parent
                            font.pixelSize: Math.floor(Cutegram.font.pointSize*Devices.fontDensity)
                            font.family: Cutegram.font.family
                            persistentSelection: true
                            activeFocusOnPress: false
                            selectByMouse: true
                            readOnly: true
                            selectionColor: masterPalette.highlight
                            selectedTextColor: masterPalette.highlightedText
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: emojis.bodyTextToEmojiText(messageText)
                            textFormat: Text.RichText
                            height: contentHeight
                            color: {
                                if(msg_media.isSticker)
                                    return "#333333"
                                else
                                if(msg_media.mediaPlayer)
                                    return Cutegram.currentTheme.messageAudioDateColor
                                else
                                if(hasMedia || encryptMedia)
                                    return Cutegram.currentTheme.messageMediaDateColor
                                else
                                if(message.out)
                                    return Cutegram.currentTheme.messageOutgoingFontColor
                                else
                                    return Cutegram.currentTheme.messageIncomingFontColor
                            }
                            onLinkActivated: {
                                if(link.slice(0,6) == "tag://")
                                    msg_item.tagSearchRequest(link.slice(6, link.length))
                                else
                                    Qt.openUrlExternally(link)
                            }

                            property real htmlWidth: Cutegram.htmlWidth(text)
                            property string messageText: encryptMedia? qsTr("Media files are not currently supported on secret chats.") : message.message
                        }
                    }

                    MessageLinkImage {
                        id: message_link
                        visible: link.length != 0
                        link: {
                            if(user.id == telegramObject.cutegramId)
                                return ""
                            var msgLink = !messageLinks || messageLinks.length == 0? "" : messageLinks[0]
                            var checkPath = webPageGrabber.check(msgLink)
                            if(checkPath != "")
                                return msgLink
                            if(allowLoadLinks)
                                return msgLink
                            else
                                return ""
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 4*Devices.density

                        Text {
                            id: time_txt
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: Math.floor(9*Devices.fontDensity)
                            text: Cutegram.getTimeString(msgDate)
                            verticalAlignment: Text.AlignVCenter
                            color: {
                                if(msg_media.isSticker)
                                    return "#333333"
                                else
                                if(msg_media.mediaPlayer)
                                    return Cutegram.currentTheme.messageAudioDateColor
                                else
                                if(hasMedia || encryptMedia)
                                    return Cutegram.currentTheme.messageMediaDateColor
                                else
                                if(message.out)
                                    return Cutegram.currentTheme.messageOutgoingDateColor
                                else
                                    return Cutegram.currentTheme.messageIncomingDateColor
                            }

                            property variant msgDate: CalendarConv.fromTime_t(message.date)
                        }

                        Item {
                            id: state_indict
                            width: 12*Devices.density
                            height: 8*Devices.density
                            visible: message.out
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: seen_indict
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                width: 8*Devices.density
                                height: width
                                visible: !message.unread && message.out
                                sourceSize: Qt.size(width,height)
                                source: indicator.light? "files/sent-light.png" : "files/sent.png"
                            }

                            Image {
                                id: sent_indict
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                width: 8*Devices.density
                                height: width
                                visible: message.sent && message.out
                                sourceSize: Qt.size(width,height)
                                source: indicator.light? "files/sent-light.png" : "files/sent.png"
                            }

                            Indicator {
                                id: indicator
                                anchors.centerIn: parent
                                modern: true
                                indicatorSize: 10*Devices.density
                                Component.onCompleted: if(!sent) start()
                                light: {
                                    if(msg_media.isSticker)
                                        return false
                                    else
                                    if(msg_media.mediaPlayer)
                                        return Cutegram.currentTheme.messageAudioLightIcon
                                    else
                                    if(hasMedia || encryptMedia) {
                                        return Cutegram.currentTheme.messageMediaLightIcon
                                    } else if(message.out) {
                                        return Cutegram.currentTheme.messageOutgoingLightIcon
                                    } else {
                                        return Cutegram.currentTheme.messageIncomingLightIcon
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Button {
            anchors.verticalCenter: parent.verticalCenter
            normalColor: "#cccccc"
            highlightColor: "#bbbbbb"
            textColor: "#555555"
            visible: hasLink && webPageGrabber.isAvailable && (user.id != telegramObject.cutegramId)
            text: {
                if(message_link.visible) {
                    if(allowLoadLinks)
                        return qsTr("Don't Load Anymore")
                    else
                        return qsTr("Load Always")
                }
                else
                    qsTr("Load Link")
            }
            radius: 3*Devices.density
            onClicked: {
                if(message_link.visible) {
                    if(allowLoadLinks)
                        telegramObject.userData.removeLoadlink(user.id)
                    else
                        telegramObject.userData.addLoadLink(user.id)
                } else {
                    showLink()
                }
            }
        }

    }

    function click() {
        return msg_media.click()
    }

    function showLink() {
        message_link.link = (!messageLinks || messageLinks.length == 0? "" : messageLinks[0])
    }

    function copy() {
        if(hasMedia)
            Devices.clipboardUrl = [msg_media.location]
        else
        if(msg_txt.selectedText.length == 0)
            Devices.clipboard = message.message
        else
            msg_txt.copy()
    }

    function discardSelection() {
        msg_txt.deselect()
    }
}
