import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Rectangle {
    width: 100
    height: 62
    color: "#333333"

    property alias telegramObject: dialogs_model.telegram

    DialogsModel {
        id: dialogs_model
    }

    ListView {
        id: dlist
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 300*physicalPlatformScale
        clip: true
        model: dialogs_model
        delegate: Column {
            width: dlist.width

            Text {
                color: "#ffffff"
                text: isChat? chat.title : user.firstName + " " + user.lastName
            }
            Text {
                color: "#ffffff"
                text: message.message
            }

            property Dialog dItem: item
            property bool isChat: dItem.peer.chatId != 0
            property User user: telegramObject.user(dItem.peer.userId)
            property Chat chat: telegramObject.chat(dItem.peer.chatId)
            property Message message: telegramObject.message(dItem.topMessage)
        }
    }
}
