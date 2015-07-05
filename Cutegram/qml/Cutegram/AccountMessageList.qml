import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import AsemanTools.Controls 1.0 as Controls

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

    property string selectedText

    property alias maxId: messages_model.maxId

    property EncryptedChat enchat: telegramObject.encryptedChat(currentDialog.peer.userId)
    property int enChatUid: enchat.adminId==telegramObject.me? enchat.participantId : enchat.adminId

    property int filterId: -1

    property real typeEncryptedChatWaiting: 0x3bf703dc
    property real typeEncryptedChatRequested: 0xc878527e
    property real typeEncryptedChatEmpty: 0xab7ec0a0
    property real typeEncryptedChatDiscarded: 0x13d6dd27
    property real typeEncryptedChat: 0xfa56ce36

    signal forwardRequest( variant messages )
    signal focusRequest()
    signal dialogRequest(variant dialogObject)
    signal tagSearchRequest(string tag)
    signal replyToRequest(int msgId)

    onIsActiveChanged: {
        if( isActive )
            messages_model.setReaded()
    }

    onCurrentDialogChanged: {
        selected_list.clear()
        add_anim_disabler.restart()
    }

    ListObject {
        id: selected_list
    }

    MessagesModel {
        id: messages_model
        onCountChanged: {
            if(count>1 && isActive)
                messages_model.setReaded()
        }
        onRefreshingChanged: {
            if(focus_msg_timer.msgId) {
                if(refreshing)
                    focus_msg_timer.stop()
                else
                    focus_msg_timer.restart()
            }
        }
        onFocusToNewRequest: {
            if(!hasNewMessage)
                return

            focus_msg_timer.msgIndex = unreads>0? unreads-1 : 0
            focus_msg_timer.restart()
        }
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: 100000
        onTriggered: messages_model.refresh()
        Component.onCompleted: start()
    }

    Image {
        anchors.fill: parent
        fillMode: Cutegram.background.length==0? Image.Tile : Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        sourceSize: Cutegram.background.length==0? Cutegram.imageSize(":/qml/files/telegram_background.png") : Qt.size(width,height)
        source: {
            if(backgroundManager.background == "")
                return Cutegram.background.length==0? "files/telegram_background.png" : Devices.localFilesPrePath + Cutegram.background
            else
                return backgroundManager.background
        }
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
            font.pixelSize: Math.floor((Cutegram.font.pointSize+1)*Devices.fontDensity)
            font.family: Cutegram.font.family
            text: qsTr("Welcome :)")
            color: "#111111"
        }
    }

    Timer {
        id: anim_enabler_timer
        interval: 400
    }

    Timer {
        id: file_delete_timer
        interval: 1000
        onTriggered: Cutegram.deleteFile(filePath)

        property string filePath
    }

    Timer {
        id: add_anim_disabler
        interval: 500
    }

    ListView {
        id: mlist
        anchors.fill: parent
        visible: enchat.classType != typeEncryptedChatDiscarded
        verticalLayoutDirection: ListView.BottomToTop
        onAtYBeginningChanged: if( atYBeginning && contentHeight>height &&
                                   currentDialog != telegramObject.nullDialog ) messages_model.loadMore()
        clip: true
        model: messages_model
        maximumFlickVelocity: 2000
        flickDeceleration: 2000

        header: Item{ width: 4; height: acc_msg_list.bottomMargin }
        footer: Item{ width: 4; height: acc_msg_list.topMargin }

//        displaced: Transition {
//            NumberAnimation { easing.type: Easing.OutCubic; properties: "y"; duration: 300 }
//        }
//        add: Transition {
//            NumberAnimation { easing.type: Easing.OutCubic; properties: "y"; duration: add_anim_disabler.running? 0 : 300 }
//        }

        section.property: "unreaded"
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            width: mlist.width
            height: unread_texts.text.length != 0 && messages_model.hasNewMessage? 30*Devices.density : 0
            clip: true

            Text {
                id: unread_texts
                anchors.centerIn: parent
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 9*Devices.fontDensity
                color: "#333333"
                text: section=="false"? qsTr("New Messages") : ""
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: unread_texts.left
                anchors.margins: 10*Devices.density
                anchors.verticalCenter: parent.verticalCenter
                color: Cutegram.currentTheme.masterColor
                height: 1*Devices.density
            }

            Rectangle {
                anchors.left: unread_texts.right
                anchors.right: parent.right
                anchors.margins: 10*Devices.density
                anchors.verticalCenter: parent.verticalCenter
                color: Cutegram.currentTheme.masterColor
                height: 1*Devices.density
            }
        }

        delegate: AccountMessageItem {
            id: msg_item
            x: 8*Devices.density
            maximumMediaHeight: acc_msg_list.maximumMediaHeight
            maximumMediaWidth: acc_msg_list.maximumMediaWidth
            message: item
            width: mlist.width - 2*x
            opacity: filterId == user.id || filterId == -1? 1 : 0.1
            onSelectedTextChanged: {
                if(selectedText.length = 0)
                    return

                acc_msg_list.selectedText = selectedText
                mlist.currentIndex = index
            }
            onDialogRequest: acc_msg_list.dialogRequest(dialogObject)
            onTagSearchRequest: acc_msg_list.tagSearchRequest(tag)
            onMessageFocusRequest: focusOnMessage(msgId)

            property string messageFile
            property bool selected: mlist.currentIndex == index

            onSelectedChanged: if(!selected) discardSelection()
            onSentChanged: if(sent && message.out) add_anim_disabler.restart()

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 200 }
            }

            Rectangle {
                id: select_rect
                anchors.fill: parent
                anchors.leftMargin: -8*Devices.density
                anchors.rightMargin: -8*Devices.density
                color: Cutegram.currentTheme.masterColor
                opacity: 0.2
                z: -100
                visible: selected_list.count==0? false : selected_list.contains(message)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(select_rect.visible)
                        selected_list.removeOne(message)
                    else
                        selected_list.append(message)
                }

                z: -100
            }

            DragObject {
                id: drag
                mimeData: mime
                source: marea
                image: "files/message.png"
                hotSpot: Qt.point(12,12)
                dropAction: Qt.CopyAction
                onDraggingChanged: anim_enabler_timer.restart()
            }

            ItemImageGrabber {
                id: grabber
                item: msg_item.messageRect
                defaultImage: "files/message.png"
                onImageChanged: {
                    drag.imageData = image
                    drag.start()
                    messageDraging = false

                    file_delete_timer.filePath = msg_item.messageFile
                    file_delete_timer.restart()
                }
            }

            MimeData {
                id: mime
                dataMap: message.encrypted? {} : {"land.aseman.cutegram/messageId": message.id}
                urls: msg_item.hasMedia? [msg_item.mediaLocation] : [msg_item.messageFile]
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
                    if(user.id == telegram.cutegramId)
                        return
                    var destX = mouseX-startPoint.x
                    var destY = mouseY-startPoint.y
                    var dest = Math.pow(destX*destX+destY*destY, 0.5)
                    if(dest < 7)
                        return
                    if(messageDraging)
                        return

                    if(!msg_item.hasMedia)
                        msg_item.messageFile = Devices.localFilesPrePath + Cutegram.storeMessage(msg_item.message.message)
                    else
                        msg_item.messageFile = ""

                    messageDraging = true
                    grabber.start()
                }

                onReleased: {
                    if(menuRequested) {
                        menuRequested = false
                        return
                    }
                    if(user.id == telegram.cutegramId)
                        return
                    if(msg_item.click())
                        return
                    if(filterId == -1)
                        filterId = user.id
                    else
                        filterId = -1
                }

                onPressed: {
                    messageDraging = false
                    menuRequested = false

                    if(user.id == telegram.cutegramId)
                        return
                    if( mouse.button != Qt.RightButton ) {
                        startPoint = Qt.point(mouseX, mouseY)
                    } else {
                        menuRequested = true
                    }
                }

                onClicked: {
                    if( mouse.button == Qt.RightButton ) {
                        var actions
                        var res
                        if(message.encrypted) {
                            actions = [qsTr("Copy"),qsTr("Delete")]
                            res = Desktop.showMenu(actions)
                            switch(res) {
                            case 0:
                                msg_item.copy()
                                break;

                            case 1:
                                telegramObject.deleteMessages([message.id])
                                break;
                            }
                        } else {
                            if(msg_item.isSticker)
                                actions = [qsTr("Reply"), qsTr("Forward"),qsTr("Copy"),qsTr("Delete"), qsTr("Add to Personal")]
                            else
                            if(msg_item.selectedText.length == 0)
                                actions = [qsTr("Reply"), qsTr("Forward"),qsTr("Copy"),qsTr("Delete")]
                            else
                                actions = [qsTr("Reply"), qsTr("Forward"),qsTr("Copy"),qsTr("Delete"), qsTr("Search on the Web")]

                            res = Desktop.showMenu(actions)
                            switch(res) {
                            case 0:
                                acc_msg_list.replyToRequest(message.id)
                                break;

                            case 1:
                                acc_msg_list.forwardRequest([message])
                                break;

                            case 2:
                                msg_item.copy()
                                break;

                            case 3:
                                telegramObject.deleteMessages([message.id])
                                break;

                            case 4:
                                if(msg_item.isSticker)
                                    Cutegram.addToPersonal(msg_item.mediaLocation)
                                else
                                    Qt.openUrlExternally(Cutegram.searchEngine + msg_item.selectedText.replace(" ","+"))
                                break;
                            }
                        }
                    }
                }

                property point startPoint
                property bool menuRequested: false
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            acc_msg_list.focusRequest()
            mouse.accepted = false
        }
    }

    NormalWheelScroll {
        flick: mlist
        animated: Cutegram.smoothScroll
        reverse: true
    }

    PhysicalScrollBar {
        scrollArea: mlist; height: mlist.height-bottomMargin-topMargin; width: 6*Devices.density
        anchors.right: mlist.right; anchors.top: mlist.top; color: textColor0
        anchors.topMargin: topMargin; reverse: true
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: acc_msg_list.topMargin
        anchors.bottomMargin: acc_msg_list.bottomMargin
        clip: true

        Rectangle {
            width: parent.width
            height: 40*Devices.density
            y: selected_list.count==0? -height : 0
            color: currentDialog.encrypted? Cutegram.currentTheme.headerSecretColor : Cutegram.currentTheme.headerColor

            Behavior on y {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }

            Row {
                id: toolbutton_row
                anchors.centerIn: parent
                height: parent.height

                property bool toolButtonLightIcon: currentDialog.encrypted? Cutegram.currentTheme.headerSecretLightIcon : Cutegram.currentTheme.headerLightIcon
                property color toolButtonColors: {
                    var mclr = Cutegram.currentTheme.masterColor
                    return Qt.rgba(mclr.r, mclr.g, mclr.b, 0.3)
                }

                Button {
                    width: height
                    height: parent.height
                    icon: toolbutton_row.toolButtonLightIcon? "files/select-none-light.png" : "files/select-none.png"
                    normalColor: "#00000000"
                    highlightColor: toolbutton_row.toolButtonColors
                    iconHeight: 22*Devices.density
                    onClicked: selected_list.clear()
                }

                Button {
                    width: height
                    height: parent.height
                    icon: toolbutton_row.toolButtonLightIcon? "files/forward-light.png" : "files/forward.png"
                    normalColor: "#00000000"
                    highlightColor: toolbutton_row.toolButtonColors
                    iconHeight: 22*Devices.density
                    onClicked: {
                        acc_msg_list.forwardRequest(selected_list.toList())
                        selected_list.clear()
                    }
                }

                Button {
                    width: height
                    height: parent.height
                    icon: "files/delete.png"
                    normalColor: "#00000000"
                    highlightColor: toolbutton_row.toolButtonColors
                    iconHeight: 22*Devices.density
                    onClicked: {
                        var ids = new Array
                        for(var i=0; i<selected_list.count; i++)
                            ids[i] = selected_list.at(i).id

                        telegramObject.deleteMessages(ids)
                        selected_list.clear()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 2*Devices.density
            opacity: selected_list.count!=0? 0.3 : 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: currentDialog.encrypted? Cutegram.currentTheme.headerSecretTitleColor : Cutegram.currentTheme.headerTitleColor }
                GradientStop { position: 1.0; color: "#00000000" }
            }

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }
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
        font.pixelSize: Math.floor(12*Devices.fontDensity)
        text: qsTr("Secret chat request. Please Accept or Reject.")
        visible: enchat.classType == typeEncryptedChatRequested
        onVisibleChanged: secret_chat_indicator.stop()
    }

    Text {
        id: rejected_txt
        anchors.top: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 100*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(12*Devices.fontDensity)
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Secret chat rejected. Or accepted from another device.\nNote that android accept secret chat automatically.")
        visible: enchat.classType == typeEncryptedChatDiscarded
        onVisibleChanged: secret_chat_indicator.stop()
    }

    Indicator {
        id: secret_chat_indicator
        light: false
        modern: true
        indicatorSize: 20*Devices.density
        anchors.top: acc_rjc_txt.bottom
        anchors.topMargin: 10*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
        anchors.top: acc_rjc_txt.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10*Devices.density
        spacing: 10*Devices.density
        visible: acc_rjc_txt.visible

        Controls.Button {
            anchors.margins: 20*Devices.density
            width: 100*Devices.density
            text: qsTr("Accept")
            style: Cutegram.currentTheme.buttonStyle
            onClicked: {
                secret_chat_indicator.start()
                telegramObject.messagesAcceptEncryptedChat(currentDialog.peer.userId)
            }
        }

        Controls.Button {
            anchors.margins: 20*Devices.density
            width: 100*Devices.density
            text: qsTr("Reject")
            style: Cutegram.currentTheme.buttonStyle
            onClicked: {
                secret_chat_indicator.start()
                telegramObject.messagesDiscardEncryptedChat(currentDialog.peer.userId)
            }
        }
    }

    Timer {
        id: focus_msg_timer
        interval: 300
        onTriggered: {
            var idx = msgIndex
            if(msgId)
                idx = messages_model.indexOf(msgId)

            mlist.positionViewAtIndex(idx, ListView.Center)
            msgIndex = 0
            msgId = 0
        }
        property int msgId
        property int msgIndex
    }

    function sendMessage( txt, inReplyTo ) {
        messages_model.sendMessage(txt, inReplyTo)
    }

    function focusOn(msgId) {
        focus_msg_timer.msgId = msgId
    }

    function focusOnMessage(msgId) {
        var idx = messages_model.indexOf(msgId)
        mlist.positionViewAtIndex(idx, ListView.Center)
    }

    function copy() {
        if(selectedText.length == 0)
            return

        Devices.clipboard = selectedText
    }
}
