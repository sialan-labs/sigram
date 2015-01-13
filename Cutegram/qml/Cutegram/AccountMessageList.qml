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

    property real topMargin
    property real bottomMargin

    property real maximumMediaHeight: (height-topMargin-bottomMargin)*0.75
    property real maximumMediaWidth: width*0.75

    property bool isActive: View.active && View.visible
    property bool messageDraging: false

    property EncryptedChat enchat: telegramObject.encryptedChat(currentDialog.peer.userId)
    property int enChatUid: enchat.adminId==telegramObject.me? enchat.participantId : enchat.adminId

    property real typeEncryptedChatWaiting: 0x3bf703dc
    property real typeEncryptedChatRequested: 0xc878527e
    property real typeEncryptedChatEmpty: 0xab7ec0a0
    property real typeEncryptedChatDiscarded: 0x13d6dd27
    property real typeEncryptedChat: 0xfa56ce36

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
            font.pixelSize: (Cutegram.font.pointSize+1)*Devices.fontDensity
            font.family: Cutegram.font.family
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

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 300; easing.type: Easing.OutCubic }
        }

        header: Item{ width: 4; height: acc_msg_list.bottomMargin }
        footer: Item{ width: 4; height: acc_msg_list.topMargin }
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
                z: -1
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
                        var actions = [qsTr("Forward"),qsTr("Copy"),qsTr("Delete")]
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
        scrollArea: mlist; height: mlist.height-bottomMargin-topMargin; width: 6*Devices.density
        anchors.right: mlist.right; anchors.top: mlist.top; color: textColor0
        anchors.topMargin: topMargin; forceVisible: true
    }

    Button {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: bottomMargin + 8*Devices.density
        anchors.rightMargin: 8*Devices.density
        width: 32*Devices.density
        height: width
        radius: 5*Devices.density
        normalColor: "#88000000"
        highlightColor: "#aa000000"
        icon: "files/down.png"
        cursorShape: Qt.PointingHandCursor
        iconHeight: 18*Devices.density
        visible: opacity != 0
        opacity: mlist.visibleArea.yPosition+mlist.visibleArea.heightRatio < 0.95? 1 : 0
        onClicked: mlist.positionViewAtBeginning()

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 300 }
        }
    }

    Text {
        id: acc_rjc_txt
        anchors.top: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 100*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 12*Devices.fontDensity
        text: qsTr("Secret chat request. Please Accept or Reject.")
        visible: enchat.classType == typeEncryptedChatRequested
    }

    Row {
        anchors.top: acc_rjc_txt.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10*Devices.density
        visible: acc_rjc_txt.visible

        Button {
            anchors.margins: 20*Devices.density
            normalColor: "#3FDA3A"
            highlightColor: Qt.darker(normalColor)
            textColor: "#ffffff"
            width: 100*Devices.density
            height: 36*Devices.density
            text: qsTr("Accept")
            onClicked: {
                telegramObject.messagesAcceptEncryptedChat(currentDialog.peer.userId)
            }
        }

        Button {
            anchors.margins: 20*Devices.density
            normalColor: "#DA3737"
            highlightColor: Qt.darker(normalColor)
            textColor: "#ffffff"
            width: 100*Devices.density
            height: 36*Devices.density
            text: qsTr("Reject")
            onClicked: {
                telegramObject.messagesDiscardEncryptedChat(currentDialog.peer.userId)
            }
        }
    }

    function sendMessage( txt ) {
        messages_model.sendMessage(txt)
    }
}
