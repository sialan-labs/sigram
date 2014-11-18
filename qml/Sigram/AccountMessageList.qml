import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Rectangle {
    width: 100
    height: 62

    property alias telegramObject: messages_model.telegram
    property alias currentDialog: messages_model.dialog
    property alias refreshing: messages_model.refreshing

    property alias topMargin: mlist.topMargin
    property alias bottomMargin: mlist.bottomMargin

    MessagesModel {
        id: messages_model
    }

    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        source: "files/telegram_background.png"
        opacity: 0.5
    }

    ListView {
        id: mlist
        anchors.fill: parent
        verticalLayoutDirection: ListView.BottomToTop
        onAtYBeginningChanged: if( atYBeginning && !messages_model.refreshing ) messages_model.loadMore()
        clip: true
        model: messages_model
        delegate: AccountMessageItem {
            x: 8*physicalPlatformScale
            width: mlist.width - 2*x
            message: item
        }
    }

    NormalWheelScroll {
        flick: mlist
    }

    ScrollBar {
        scrollArea: mlist; height: mlist.height-mlist.bottomMargin-mlist.topMargin; width: 6*physicalPlatformScale
        anchors.right: mlist.right; anchors.top: mlist.top; color: textColor0
        anchors.topMargin: mlist.topMargin; forceVisible: true
    }

    function sendMessage( txt ) {
        messages_model.sendMessage(txt)
    }
}
