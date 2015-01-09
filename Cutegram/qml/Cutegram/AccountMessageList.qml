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
    property bool messageDraging: false

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

    Rectangle {
        anchors.centerIn: parent
        color: "#ffffff"
        width: welcome_txt.width + 20*Devices.density
        height: welcome_txt.height + 10*Devices.density
        radius: 5*Devices.density
        visible: currentDialog == telegramObject.nullDialog

        Text {
            id: welcome_txt
            anchors.centerIn: parent
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 11*Devices.fontDensity
            text: qsTr("Welcome :)")
            color: "#111111"
        }
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
            id: msg_item
            x: 8*Devices.density
            width: mlist.width - 2*x
            maximumMediaHeight: acc_msg_list.maximumMediaHeight
            maximumMediaWidth: acc_msg_list.maximumMediaWidth
            message: item

            DragObject {
                id: drag
                mimeData: mime
                source: marea
                image: "files/message.png"
                hotSpot: Qt.point(22,22)
            }

            MimeData {
                id: mime
                dataMap: {"land.aseman.cutegram/messageId": message.id}
                text: message.message
            }

            MouseArea {
                id: marea
                x: messageFrameX
                y: messageFrameY
                width: messageFrameWidth
                height: messageFrameHeight
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: {
                    var destX = mouseX-startPoint.x
                    var destY = mouseY-startPoint.y
                    var dest = Math.pow(destX*destX+destY*destY, 0.5)
                    if(dest < 7)
                        return

                    messageDraging = true
                    drag.start()
                    messageDraging = false
                }

                onReleased: msg_item.click()

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
                    }
                    else {
                        startPoint = Qt.point(mouseX, mouseY)
                    }
                }

                property point startPoint
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
