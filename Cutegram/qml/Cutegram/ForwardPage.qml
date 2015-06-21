/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Rectangle {
    id: forward_page
    width: 100
    height: 62
    color: "#66ffffff"

    property variant forwardMessages
    property Message forwardMessage: forwardMessages[0]
    property Dialog forwardDialog: telegramObject.nullDialog

    property User fromUser: telegramObject.user(forwardMessage.fromId)

    property bool toIsChat: forwardDialog.peer.chatId != 0
    property User toUser: telegramObject.user(forwardDialog.peer.userId)
    property Chat toChat: telegramObject.chat(forwardDialog.peer.chatId)

    signal closeRequest()

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*Devices.density

        Image {
            id: fwd_contact
            width: 92*Devices.density
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: imgPath.length==0? "files/user.png" : imgPath

            property string imgPath: fromUser.photo.photoSmall.download.location
        }

        Text {
            id: fwd_txt
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Math.floor(11*Devices.fontDensity)
            font.family: AsemanApp.globalFont.family
            color: "#333333"
            maximumLineCount: 2
            elide: Text.ElideRight
            text: emojis.textToEmojiText(forwardMessage.message)
        }

        Text {
            id: fwd_info
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Math.floor(10*Devices.fontDensity)
            font.weight: Font.Normal
            font.family: AsemanApp.globalFont.family
            color: "#333333"
            text: qsTr("Please select a contact...")
            visible: forwardDialog!=telegramObject.nullDialog? false : true
        }

        Item {
            id: fwd_to_frame
            anchors.left: parent.left
            anchors.right: parent.right
            height: forwardDialog!=telegramObject.nullDialog? fwd_to_column.height + 30 : 0
            opacity: forwardDialog!=telegramObject.nullDialog? 1 : 0
            visible: opacity != 0
            clip: true

            Behavior on height {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Column {
                id: fwd_to_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10*Devices.density

                Text {
                    wrapMode: Text.WordWrap
                    font.pixelSize: Math.floor(18*Devices.fontDensity)
                    font.weight: Font.Normal
                    font.family: AsemanApp.globalFont.family
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("To")
                }

                Image {
                    id: fwd_to_contact
                    width: 92*Devices.density
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: imgPath.length==0? (toIsChat?"files/group.png":"files/user.png") : imgPath

                    property string imgPath: toIsChat? toChat.photo.photoSmall.download.location : toUser.photo.photoSmall.download.location
                }

                Text {
                    wrapMode: Text.WordWrap
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    font.weight: Font.Normal
                    font.family: AsemanApp.globalFont.family
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: toIsChat? toChat.title : toUser.firstName + " " + toUser.lastName
                }
            }
        }
    }

    Button {
        anchors.right: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        height: 40*Devices.density
        width: 100*Devices.density
        normalColor: "#ff5532"
        highlightColor: "#D04528"
        textColor: "#ffffff"
        text: qsTr("Cancel")
        radius: 4*Devices.density
        onClicked: {
            forward_page.closeRequest()
        }
    }

    Button {
        anchors.left: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        height: 40*Devices.density
        width: 100*Devices.density
        normalColor: forwardDialog!=telegramObject.nullDialog? "#0d80ec" : "#888888"
        highlightColor: forwardDialog!=telegramObject.nullDialog? Qt.darker(normalColor) : "#888888"
        textColor: "#ffffff"
        text: qsTr("Forward")
        radius: 4*Devices.density
        onClicked: {
            if( forwardDialog==telegramObject.nullDialog )
                return

            var dId = toIsChat? forwardDialog.peer.chatId : forwardDialog.peer.userId
            var ids = new Array
            for(var i=0; i<forwardMessages.length; i++)
                ids[i] = forwardMessages[i].id

            telegramObject.forwardMessages(ids, dId)
            forward_page.closeRequest()
        }
    }
}
