import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: msg_item
    width: 100
    height: logicalHeight<minimumHeight? minimumHeight : logicalHeight
    clip: true

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

    property alias hasMedia: msg_media.hasMedia
    property bool encryptMedia: message.message.length==0 && message.encrypted

    onSentChanged: {
        if( sent )
            indicator.stop()
        else
            indicator.start()
    }

    AccountMessageAction {
        id: action_item
        anchors.left: parent.left
        anchors.right: parent.right
        message: msg_item.message
    }

    Row {
        id: frame_row
        anchors.fill: parent
        layoutDirection: message.out? Qt.RightToLeft : Qt.LeftToRight
        visible: !action_item.hasAction
        spacing: frameMargins

        ContactImage {
            id: img
            anchors.verticalCenter: parent.verticalCenter
            width: 40*Devices.density
            height: width
            user: msg_item.user
            isChat: false
        }

        ContactImage {
            id: forward_img
            anchors.verticalCenter: parent.verticalCenter
            width: img.width
            height: img.height
            visible: message.fwdFromId != 0
            user: msg_item.fwdUser
            isChat: false
        }

        Rectangle {
            id: back_rect
            width: column.width + 2*textMargins
            height: column.height + 2*textMargins
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            radius: 6*Devices.density

            Rectangle {
                anchors.fill: parent
                opacity: hasMedia || encryptMedia? 1 : 0.3
                radius: parent.radius
                color: {
                    if(hasMedia || encryptMedia)
                        return "#111111"
                    else
                    if(message.out)
                        return Cutegram.highlightColor
                    else
                        return "#ffffff"
                }
            }

            Column {
                id: column
                anchors.centerIn: parent
                height: (visibleNames?user_name.height:0) + (uploading?upload_img.height:0) + (msg_media.hasMedia?msg_media.height:0) + spacing + msg_row.height - 20*Devices.density
                clip: true

                Text {
                    id: user_name
                    font.pixelSize: 10*Devices.fontDensity
                    font.family: AsemanApp.globalFontFamily
                    color: Cutegram.highlightColor
                    text: user.firstName + " " + user.lastName
                    visible: visibleNames
                }

                Image {
                    id: upload_img
                    visible: uploading
                    width: height*imageSize.width/imageSize.height
                    height: 200*Devices.density
                    sourceSize: Qt.size(width,height)
                    smooth: true
                    source: uploading? "file://" + message.upload.location : ""

                    property size imageSize: uploading? Cutegram.imageSize(message.upload.location) : Qt.size(0,0)
                }

                AccountMessageMedia {
                    id: msg_media
                    media: message.media
                    visible: msg_media.hasMedia && !uploading
                }

                Row {
                    id: msg_row

                    Text {
                        id: msg_txt
                        width: htmlWidth>maximumWidth? maximumWidth : htmlWidth
                        font.pixelSize: 9*Devices.fontDensity
                        font.family: AsemanApp.globalFontFamily
                        color: encryptMedia? "#ffffff" : textColor0
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: emojis.bodyTextToEmojiText(messageText)
                        onLinkActivated: Qt.openUrlExternally(link)
                        visible: !msg_media.hasMedia && !uploading

                        property real htmlWidth: Cutegram.htmlWidth(text)
                        property string messageText: encryptMedia? qsTr("Media files is not supported on secret chat currently") : message.message
                    }

                    Text {
                        id: time_txt
                        anchors.bottom: parent.bottom
                        anchors.margins: 18*Devices.density
                        font.family: AsemanApp.globalFontFamily
                        font.pixelSize: 9*Devices.fontDensity
                        color: textColor2
                        text: Cutegram.getTimeString(msgDate)

                        property variant msgDate: CalendarConv.fromTime_t(message.date)
                    }
                }
            }

            Item {
                id: state_indict
                width: 12
                height: 8
                anchors.right: back_rect.right
                anchors.bottom: back_rect.bottom
                anchors.margins: 2*Devices.density
                visible: message.out

                Image {
                    id: seen_indict
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    width: 8
                    height: width
                    visible: !message.unread && message.out
                    source: "files/sent.png"
                    sourceSize: Qt.size(width,height)
                }

                Image {
                    id: sent_indict
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    width: 8
                    height: width
                    visible: message.sent && message.out
                    source: "files/sent.png"
                    sourceSize: Qt.size(width,height)
                }
            }

            Indicator {
                id: indicator
                anchors.right: back_rect.right
                anchors.bottom: back_rect.bottom
                anchors.margins: 2*Devices.density
                light: false
                modern: true
                indicatorSize: 10*Devices.density
                Component.onCompleted: if(!sent) start()
            }
        }
    }

    function click() {
        msg_media.click()
    }
}
