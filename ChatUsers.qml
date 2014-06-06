/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Item {
    id: chat_users
    width: 100
    height: 62
    clip: true

    property int chatId
    signal selected( int uid )

    onChatIdChanged: clist.refresh()

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: clist.top
        height: 1
        color: "#888888"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: clist.bottom
        height: 1
        color: "#888888"
    }

    ListView {
        id: clist
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: add_btn.top
        anchors.margins: 4
        model: ListModel{}
        clip: true

        delegate: Rectangle {
            id: item
            height: 57
            width: clist.width
            color: marea.pressed? "#E65245" : "#00000000"

            ContactImage {
                id: contact_image
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 4
                uid: user_id
                width: height
                borderColor: "#ffffff"
                onlineState: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: contact_image.right
                anchors.leftMargin: 8
                font.pointSize: 10
                font.family: globalNormalFontFamily
                text: Telegram.contactTitle(user_id)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    if( !Telegram.contactContains(user_id) )
                        return

                    chat_users.selected(user_id)
                }
            }

            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 4
                normalColor: "#00000000"
                highlightColor: "#00000000"
                textColor: press? "#D04528" : "#ff5532"
                visible: Telegram.dialogChatUsersInviter(chat_users.chatId,user_id) == Telegram.me
                text: qsTr("Delete")
                onClicked: Telegram.chatDelUser(chat_users.chatId,user_id)
            }
        }

        function refresh() {
            indicator.stop()
            model.clear()
            var contacts = Telegram.dialogChatUsers(chat_users.chatId)
            for( var i=0; i<contacts.length; i++ ) {
                model.append( {"user_id":contacts[i]} )
                Telegram.loadUserInfo(contacts[i])
            }
        }

        Component.onCompleted: refresh()
    }

    Button {
        id: add_btn
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: press? "#337fa2" : "#4098bf"
        text: qsTr("Add User")
        onClicked: flipMenu.show(add_user_dialog)

    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#ffffff"
    }

    Component {
        id: add_user_dialog
        Item {
            width: 237

            ContactDialog {
                id: c_dialog
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: ac_btn.top
                multiSelectMode: true
                color: "#00000000"
                Component.onCompleted: showFullContacts()
            }

            Button {
                id: ac_btn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                normalColor: "#4098bf"
                highlightColor: "#337fa2"
                textColor: "#ffffff"
                height: 42
                text: qsTr("Add")
                onClicked: {
                    var users = c_dialog.selectedContacts()
                    for( var i=0; i<users.length; i++ )
                        Telegram.chatAddUser( chat_users.chatId, users[i] )

                    flipMenu.hide()
                    chatFrame.chatView.userConfig = false
                }
            }
        }
    }
}
