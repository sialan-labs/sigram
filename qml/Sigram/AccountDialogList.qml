import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    width: 100
    height: 62

    property alias telegramObject: dialogs_model.telegram
    property Dialog currentDialog

    DialogsModel {
        id: dialogs_model
        onIntializingChanged: {
            if( intializing )
                indicator.start()
            else
                indicator.stop()
        }
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: false
        modern: true
        indicatorSize: 20*physicalPlatformScale
    }

    ListView {
        id: dlist
        anchors.fill: parent
        anchors.rightMargin: 6*physicalPlatformScale
        clip: true
        model: dialogs_model
        delegate: Rectangle {
            id: list_item
            width: dlist.width
            height: 60*physicalPlatformScale
            color: marea.pressed? "#88339DCC" : (selected? "#66339DCC" : "#00000000")

            property Dialog dItem: item
            property bool isChat: dItem.peer.chatId != 0
            property User user: telegramObject.user(dItem.peer.userId)
            property Chat chat: telegramObject.chat(dItem.peer.chatId)
            property Message message: telegramObject.message(dItem.topMessage)
            property variant msgDate: CalendarConv.fromTime_t(message.date)

            property bool selected: currentDialog==dItem

            Image {
                id: profile_img
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 4*physicalPlatformScale
                width: height
                sourceSize: Qt.size(width,height)
                source: imgPath.length==0? "files/unknown.jpg" : imgPath

                property string imgPath: isChat? chat.photo.photoSmall.download.location : user.photo.photoSmall.download.location
            }

            Text {
                id: title_txt
                anchors.top: parent.top
                anchors.bottom: parent.verticalCenter
                anchors.left: profile_img.right
                anchors.right: time_txt.left
                anchors.margins: 4*physicalPlatformScale
                anchors.bottomMargin: 0
                font.family: SApp.globalFontFamily
                font.pixelSize: 11*fontsScale
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: textColor0
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                text: isChat? chat.title : user.firstName + " " + user.lastName
            }

            Text {
                id: msg_txt
                anchors.top: parent.verticalCenter
                anchors.bottom: parent.bottom
                anchors.left: profile_img.right
                anchors.right: parent.right
                anchors.margins: 4*physicalPlatformScale
                anchors.topMargin: 0
                font.family: SApp.globalFontFamily
                font.pixelSize: 9*fontsScale
                color: textColor2
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                text: emojis.textToEmojiText(message.message)
            }

            Text {
                id: time_txt
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4*physicalPlatformScale
                font.family: SApp.globalFontFamily
                font.pixelSize: 9*fontsScale
                color: textColor1
                text: Sigram.getTimeString(msgDate)
            }

            UnreadItem {
                unread: dItem.unreadCount
                visible: unread != 0 && !selected
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: currentDialog = list_item.dItem
            }
        }
    }

    NormalWheelScroll {
        flick: dlist
    }

    PhysicalScrollBar {
        scrollArea: dlist; height: dlist.height; width: 6*physicalPlatformScale
        anchors.left: dlist.right; anchors.top: dlist.top; color: textColor0
    }
}
