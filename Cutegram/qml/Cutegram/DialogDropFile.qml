import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    id: am_dropfile
    width: 100
    height: 62

    property bool containsDrag: drop_area.containsDrag && dialogItem != telegramObject.nullDialog

    property Dialog dialogItem

    property Dialog currentDialog: telegramObject.nullDialog
    property bool isChat: dialogItem? dialogItem.peer.chatId != 0 : false

    property alias color: back.color
    property real visibleRatio: containsDrag? 1 : 0

    property bool normalDrop: drop_area.drag.y<drop_doc_rect.y
    property int forwardDrop: typeFileSendDrop

    property int typeForwardDrop: 1000
    property int typeFileSendDrop: 1001
    property int typeAddPatricipants: 1002
    property int typeAddChat: 1002

    signal dropped()

    Behavior on visibleRatio {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    Rectangle {
        id: back
        anchors.fill: parent
        color: Cutegram.visualEffects?"#66ffffff":"#aaffffff"
        opacity: visibleRatio

        Behavior on color {
            ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: forwardDrop!=typeFileSendDrop? parent.bottom : drop_doc_rect.top
            anchors.margins: 6*Devices.density
            border.color: Cutegram.currentTheme.masterColor
            border.width: 2*Devices.density
            radius: 3*Devices.density
            color: "#00000000"
            opacity: normalDrop? 1.0 : 0.4

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
            }

            Text {
                id: drop_text
                anchors.centerIn: parent
                font.family: AsemanApp.globalFont.family
                font.pixelSize: Math.floor(12*Devices.fontDensity)
                color: Cutegram.currentTheme.masterColor
            }
        }

        Rectangle {
            id: drop_doc_rect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 6*Devices.density
            height: am_dropfile.height<100*Devices.density? 0 : 100*Devices.density
            border.color: Cutegram.currentTheme.masterColor
            border.width: 2*Devices.density
            radius: 3*Devices.density
            color: "#00000000"
            opacity: normalDrop? 0.4 : 1.0
            visible: forwardDrop == typeFileSendDrop
            clip: true

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
            }

            Text {
                anchors.centerIn: parent
                font.family: AsemanApp.globalFont.family
                font.pixelSize: Math.floor(12*Devices.fontDensity)
                color: Cutegram.currentTheme.masterColor
                text: qsTr("Drop to send as Document")
            }
        }
    }

    DropArea {
        id: drop_area
        anchors.fill: parent
        onEntered: {
            if( drag.formats.indexOf("land.aseman.cutegram/messageId") != -1 )
            {
                forwardDrop = typeForwardDrop
                if(currentDialog == dialogItem)
                    drop_text.text = qsTr("<<< Drop to dialogs list to forward")
                else
                    drop_text.text = qsTr("Drop to forward")
            }
            else
            if( drag.formats.indexOf("land.aseman.cutegram/contactId") != -1 )
            {
                if(isChat) {
                    forwardDrop = typeAddPatricipants
                    drop_text.text = qsTr("Drop to add participant")
                } else {
                    forwardDrop = typeAddChat
                    drop_text.text = qsTr("Drop to add new chat")
                }
            }
            else
            {
                forwardDrop = typeFileSendDrop
                drop_text.text = qsTr("Drop to send")
            }
        }

        onDropped: {
            if( dialogItem == telegramObject.nullDialog )
                return

            var dId = isChat? dialogItem.peer.chatId : dialogItem.peer.userId
            if( drop.formats.indexOf("land.aseman.cutegram/messageId") != -1 ) {
                if(currentDialog == dialogItem)
                    return

                var msgId = drop.getDataAsString("land.aseman.cutegram/messageId")
                telegramObject.forwardMessages([msgId], dId)
                am_dropfile.dropped()
            }
            else
            if( drop.formats.indexOf("land.aseman.cutegram/contactId") != -1 ) {
                if(currentDialog == telegramObject.nullDialog)
                    return

                var userId = drop.getDataAsString("land.aseman.cutegram/contactId")
                if(isChat) {
                    telegramObject.messagesAddChatUser(dialogItem.peer.chatId, userId)
                } else {
                    if(userId == telegramObject.me || userId == dialogItem.peer.userId)
                        return

                    var newName = Desktop.getText(View, qsTr("New Group"), qsTr("Please enter new group name"))
                    if(newName.length != 0) {
                        var usersIds = [telegramObject.me, dialogItem.peer.userId, userId]
                        telegramObject.messagesCreateChat( Cutegram.variantListToIntList(usersIds), newName)
                    }

                }
            }
            else
            if( drop.hasUrls ) {
                var urls = drop.urls
                for( var i=0; i<urls.length; i++ ) {
                    var url = urls[i]
                    if(url.slice(0,7) == "file://")
                        telegramObject.sendFile(dId, url, !normalDrop)
                    else
                        telegramObject.sendMessage(dId, url)
                }

                am_dropfile.dropped()
            }
            else
            if( drop.hasText ) {
                if(normalDrop)
                    telegramObject.sendMessage(dId, drop.text)
                else
                    telegramObject.sendMessageAsDocument(dId, drop.text)

                am_dropfile.dropped()
            }
        }
    }
}
