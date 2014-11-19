import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Rectangle {
    id: acc_msg_list
    width: 100
    height: 62

    property alias telegramObject: messages_model.telegram
    property alias currentDialog: messages_model.dialog
    property alias refreshing: messages_model.refreshing

    property alias topMargin: mlist.topMargin
    property alias bottomMargin: mlist.bottomMargin

    property real maximumMediaHeight: (height-topMargin-bottomMargin)*0.75
    property real maximumMediaWidth: width*0.75

    property bool isActive: View.active

    onIsActiveChanged: {
        if( isActive )
            messages_model.setReaded()
    }

    MessagesModel {
        id: messages_model
        onCountChanged: {
            if(count>1 && isActive)
                messages_model.setReaded()
        }
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
            maximumMediaHeight: acc_msg_list.maximumMediaHeight
            maximumMediaWidth: acc_msg_list.maximumMediaWidth
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
