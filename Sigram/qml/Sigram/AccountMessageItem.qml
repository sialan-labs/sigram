import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    id: msg_item
    width: 100
    height: logicalHeight<minimumHeight? minimumHeight : logicalHeight
    clip: true

    property real logicalHeight: column.height + frameMargins*2 + textMargins*2
    property real minimumHeight: 48*physicalPlatformScale
    property real maximumWidth: 2*width/3

    property alias maximumMediaHeight: msg_media.maximumMediaHeight
    property alias maximumMediaWidth: msg_media.maximumMediaWidth

    property bool visibleNames: true

    property Message message
    property User user: telegramObject.user(message.fromId)
    property User fwdUser: telegramObject.user(message.fwdFromId)

    property real minimumWidth: 100*physicalPlatformScale
    property real textMargins: 4*physicalPlatformScale
    property real frameMargins: 4*physicalPlatformScale

    property bool sent: message.sent
    property bool uploading: message.upload.fileId != 0

    onSentChanged: {
        if( sent )
            indicator.stop()
        else
            indicator.start()
    }

    AccountMessageAction {
        id: action_item
        anchors.fill: parent
        message: msg_item.message
    }

    Row {
        id: frame_row
        anchors.fill: parent
        layoutDirection: message.out? Qt.RightToLeft : Qt.LeftToRight
        visible: !action_item.hasAction
        spacing: frameMargins

        Image {
            id: img
            anchors.verticalCenter: parent.verticalCenter
            width: 40*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            source: imgPath.length==0? "files/user.png" : imgPath

            property string imgPath: user.photo.photoSmall.download.location
        }

        Image {
            id: forward_img
            anchors.verticalCenter: parent.verticalCenter
            width: img.width
            height: img.height
            visible: message.fwdFromId != 0
            source: imgPath.length==0? "files/user.png" : imgPath

            property string imgPath: fwdUser.photo.photoSmall.download.location
        }

        Rectangle {
            id: back_rect
            width: column.width + 2*textMargins
            height: column.height + 2*textMargins
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"

            Rectangle {
                anchors.fill: parent
                color: message.out? masterPalette.highlight : "#ffffff"
                opacity: 0.2
            }

            Column {
                id: column
                anchors.centerIn: parent
                height: (visibleNames?user_name.height:0) + (uploading?upload_img.height:0) + (msg_media.hasMedia?msg_media.height:0) + spacing + msg_row.height - 20*physicalPlatformScale
                clip: true

                Text {
                    id: user_name
                    font.pixelSize: 10*fontsScale
                    font.family: SApp.globalFontFamily
                    color: masterPalette.highlight
                    text: user.firstName + " " + user.lastName
                    visible: visibleNames
                }

                Image {
                    id: upload_img
                    visible: uploading
                    width: height*imageSize.width/imageSize.height
                    height: 200*physicalPlatformScale
                    sourceSize: Qt.size(width,height)
                    smooth: true
                    source: uploading? "file://" + message.upload.location : ""

                    property size imageSize: uploading? Sigram.imageSize(message.upload.location) : Qt.size(0,0)
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
                        font.pixelSize: 9*fontsScale
                        font.family: SApp.globalFontFamily
                        color: textColor0
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: emojis.bodyTextToEmojiText(message.message)
                        onLinkActivated: Qt.openUrlExternally(link)
                        visible: !msg_media.hasMedia && !uploading

                        property real htmlWidth: Sigram.htmlWidth(text)
                    }

                    Text {
                        id: time_txt
                        anchors.bottom: parent.bottom
                        anchors.margins: 18*physicalPlatformScale
                        font.family: SApp.globalFontFamily
                        font.pixelSize: 9*fontsScale
                        color: textColor2
                        text: Sigram.getTimeString(msgDate)

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
                anchors.margins: 2*physicalPlatformScale
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
                anchors.margins: 2*physicalPlatformScale
                light: false
                modern: true
                indicatorSize: 10*physicalPlatformScale
                Component.onCompleted: if(!sent) start()
            }
        }
    }
}
