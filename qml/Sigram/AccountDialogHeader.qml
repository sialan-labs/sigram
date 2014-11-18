import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Rectangle {
    id: header
    height: 60*physicalPlatformScale
    color: backColor2

    property Dialog currentDialog

    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false
    property User user: currentDialog? telegramObject.user(currentDialog.peer.userId) : 0
    property Chat chat: currentDialog? telegramObject.chat(currentDialog.peer.chatId) : 0

    property bool refreshing: false

    onRefreshingChanged: {
        if( refreshing )
            indicator.start()
        else
            indicator.stop()
    }

    Text {
        anchors.centerIn: parent
        color: textColor0
        font.pixelSize: 15*fontsScale
        font.family: SApp.globalFontFamily
        text: {
            if( !currentDialog )
                return ""
            if( isChat )
                return chat? chat.title : ""
            else
                return user? user.firstName + " " + user.lastName : ""
        }
    }

    Indicator {
        id: indicator
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: y
        light: false
        modern: true
        indicatorSize: 20*physicalPlatformScale
    }
}
