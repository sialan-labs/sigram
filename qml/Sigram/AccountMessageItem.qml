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

    property bool visibleNames: true

    property Message message
    property User user: telegramObject.user(message.fromId)
    property MessageMedia media: message.media

    property real minimumWidth: 100*physicalPlatformScale
    property real textMargins: 4*physicalPlatformScale
    property real frameMargins: 4*physicalPlatformScale

    property bool sent: message.sent
    property bool hasMedia: media.classType != typeMessageMediaEmpty

    property variant msgDate: CalendarConv.fromTime_t(message.date)

    property real typeMessageMediaDocument: 0x2fda2204
    property real typeMessageMediaContact: 0x5e7d2f39
    property real typeMessageMediaEmpty: 0x3ded6320
    property real typeMessageMediaVideo: 0xa2d24290
    property real typeMessageMediaUnsupported: 0x29632a36
    property real typeMessageMediaAudio: 0xc6b68300
    property real typeMessageMediaPhoto: 0xc8c45a2a
    property real typeMessageMediaGeo: 0x56e0d474

    onHasMediaChanged: {
        if( !hasMedia )
            return

        if( media.classType==typeMessageMediaPhoto )
            telegramObject.getFile(media.photo.sizes.last.location)
    }

    onSentChanged: {
        if( sent )
            indicator.stop()
        else
            indicator.start()
    }

    Rectangle {
        id: back_rect
        anchors.fill: column
        anchors.margins: -textMargins
        color: message.out? "#D7D7FD" : "#ffffff"
    }

    Image {
        id: img
        x: message.out? parent.width - width : 0
        anchors.verticalCenter: parent.verticalCenter
        width: 40*physicalPlatformScale
        height: width
        sourceSize: Qt.size(width,height)
        source: imgPath.length==0? "files/unknown.jpg" : imgPath

        property string imgPath: user.photo.photoSmall.download.location
    }

    Column {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        x: message.out? msg_item.width - width - textMargins - frameMargins - img.width : textMargins + frameMargins + img.width
        height: (visibleNames?user_name.height:0) + (hasMedia?media_img.height:0) + spacing + msg_row.height - 20*physicalPlatformScale
        clip: true

        Text {
            id: user_name
            font.pixelSize: 10*fontsScale
            font.family: SApp.globalFontFamily
            color: "#0d80ec"
            text: user.firstName + " " + user.lastName
            visible: visibleNames
        }

        Image {
            id: media_img
            width: 300*physicalPlatformScale
            height: width
            visible: hasMedia
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(width,height)
            source: path

            property string path: media.classType==typeMessageMediaPhoto? media.photo.sizes.last.location.download.location : ""
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
                visible: !hasMedia

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
