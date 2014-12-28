import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

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

    property bool isActive: View.active && View.visible

    signal forwardRequest( variant message )

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

    Timer {
        id: refresh_timer
        repeat: true
        interval: 10000
        onTriggered: messages_model.refresh()
        Component.onCompleted: start()
    }

    Image {
        anchors.fill: parent
        fillMode: Cutegram.background.length==0? Image.Tile : Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        sourceSize: Cutegram.background.length==0? Cutegram.imageSize(":/qml/files/telegram_background.png") : Qt.size(width,height)
        source: Cutegram.background.length==0? "files/telegram_background.png" : "file://" + Cutegram.background
        opacity: 0.7
    }

    ListView {
        id: mlist
        anchors.fill: parent
        verticalLayoutDirection: ListView.BottomToTop
        onAtYBeginningChanged: if( atYBeginning && !messages_model.refreshing && contentHeight>height &&
                                   currentDialog != telegramObject.nullDialog ) messages_model.loadMore()
        clip: true
        model: messages_model
        delegate: AccountMessageItem {
            x: 8*Devices.density
            width: mlist.width - 2*x
            maximumMediaHeight: acc_msg_list.maximumMediaHeight
            maximumMediaWidth: acc_msg_list.maximumMediaWidth
            message: item

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: {
                    if( mouse.button == Qt.RightButton ) {
                        var actions = ["Forward","Copy","Delete"]
                        var res = Cutegram.showMenu(actions)
                        switch(res) {
                        case 0:
                            acc_msg_list.forwardRequest(message)
                            break;

                        case 1:
                            Devices.clipboard = message.message
                            break;

                        case 2:
                            telegramObject.deleteMessage(message.id)
                            break;
                        }
                    } else {
                        mouse.accepted = false
                    }
                }
            }
        }
    }

    NormalWheelScroll {
        flick: mlist
    }

    ScrollBar {
        scrollArea: mlist; height: mlist.height-mlist.bottomMargin-mlist.topMargin; width: 6*Devices.density
        anchors.right: mlist.right; anchors.top: mlist.top; color: textColor0
        anchors.topMargin: mlist.topMargin; forceVisible: true
    }

    function sendMessage( txt ) {
        messages_model.sendMessage(txt)
    }
}
