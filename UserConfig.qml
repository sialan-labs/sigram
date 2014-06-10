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
    id: u_conf
    width: 100
    height: 62

    property int userId
    property bool isChat: Telegram.dialogIsChat(userId)

    signal backRequest()
    signal chatRequest( string uid )

    Keys.onEscapePressed: backRequest()

    onUserIdChanged: {
        notify.checked = Gui.isMuted(u_conf.userId)
    }

    Connections {
        target: Gui
        onMuted: {
            if( id != u_conf.userId )
                return

            notify.checked = Gui.isMuted(u_conf.userId)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: -200
        height: 53
        color: imageBack? "#88cccccc" : "#555555"

        Button {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            height: parent.height
            icon: "files/back.png"
            text: qsTr("Back to conversation")
            normalColor: "#00000000"
            highlightColor: "#00000000"
            textColor: press? "#4098bf" : (imageBack? "#333333" : "#cccccc")
            iconHeight: 22
            fontSize: 11
            textFont.weight: Font.Light
            onClicked: u_conf.backRequest()
        }
    }

    ContactImage {
        id: cimg
        width: 128
        height: width
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.leftMargin: 50
        anchors.topMargin: 60
        uid: u_conf.userId
        onlineState: true
        borderColor: "#333333"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if( cimg.source.length == 0 )
                    return

                var obj = flipMenu.show(limoo_component)
                obj.source = cimg.source
                mainFrame.focus = true
            }
        }
    }

    Text {
        id: name
        anchors.top: cimg.top
        anchors.left: cimg.right
        anchors.leftMargin: 50
        font.pointSize: 18
        font.weight: Font.DemiBold
        font.family: globalNormalFontFamily
        color: "#333333"
        text: Telegram.title(u_conf.userId).trim()
    }

    Rectangle {
        id: name_splitter
        anchors.top: name.bottom
        anchors.left: name.left
        anchors.right: name.right
        anchors.topMargin: 4
        height: 1
        color: "#4098bf"
    }

    Text {
        id: last_seen
        anchors.top: name_splitter.bottom
        anchors.left: name.left
        anchors.topMargin: 4
        font.pointSize: 10
        font.weight: Font.Normal
        font.family: globalNormalFontFamily
        color: "#777777"
        text: Telegram.contactLastSeenText(u_conf.userId)
    }

    ChatUsers {
        id: c_users
        anchors.top: last_seen.bottom
        anchors.left: name.left
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.topMargin: 60
        height: 237
        chatId: u_conf.isChat? u_conf.userId : 0
        visible: u_conf.isChat
        onSelected: {
            u_conf.chatRequest(uid)
            u_conf.backRequest()
        }
    }

    Button {
        id: chat_btn
        anchors.top: last_seen.bottom
        anchors.left: name.left
        anchors.topMargin: 60
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: press? "#337fa2" : "#4098bf"
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: qsTr("Send Message")
        visible: !u_conf.isChat
        onClicked: {
            u_conf.chatRequest(u_conf.userId)
            u_conf.backRequest()
        }
    }

    Button {
        id: secret_btn
        anchors.top: chat_btn.bottom
        anchors.left: name.left
        anchors.topMargin: 10
        normalColor: "#00000000"
        highlightColor: "#00000000"
//        textColor: press? "#50ab99" : "#33ccad"
        textColor: press? "#D04528" : "#ff5532"
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: qsTr("Start Secret Chat (not working yet, we working on it)")
        visible: !u_conf.isChat
    }

    Text {
        id: phone_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.top: phone.top
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#555555"
        text: qsTr("Mobile Phone:")
        visible: !u_conf.isChat
    }

    Text {
        id: phone
        anchors.top: secret_btn.bottom
        anchors.left: name.left
        anchors.topMargin: 60
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#333333"
        text: Telegram.contactPhone(u_conf.userId)
        visible: !u_conf.isChat
    }

    Text {
        id: notify_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.verticalCenter: notify.verticalCenter
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#555555"
        text: qsTr("Notification:")
    }

    CheckBox {
        id: notify
        anchors.top: u_conf.isChat? c_users.bottom : phone.bottom
        anchors.left: name.left
        anchors.topMargin: 10
        onCheckedChanged: Gui.setMute( u_conf.userId, checked )
    }

    Text {
        id: language_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.verticalCenter: lang_combo.verticalCenter
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#555555"
        text: qsTr("Language:")
    }

    ControlCombo {
        id: lang_combo
        anchors.top: notify.bottom
        anchors.left: name.left
        anchors.topMargin: 10
        visible: u_conf.userId == Telegram.me
        height: 30
        width: 200
        onCurrentTextChanged: if(inited) Gui.language = currentText
        Component.onCompleted: {
            var lang = Gui.language
            model = Gui.languages()
            currentIndex = find(lang)
            inited = true
        }

        property bool inited: false
    }

    Button {
        id: background_btn
        anchors.top: lang_combo.bottom
        anchors.left: name.left
        anchors.topMargin: 50
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: Gui.background.length==0? (press? "#50ab99" : "#33ccad") : ( press? "#D04528" : "#ff5532" )
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: Gui.background.length==0? qsTr("Change Background") : qsTr("Remove Background")
        visible: u_conf.userId == Telegram.me
        onClicked: {
            if( Gui.background.length != 0 ) {
                Gui.background = ""
                return
            }

            var path = Gui.getOpenFile()
            if( path.length == 0 )
                return

            Gui.background = path
        }
    }

    Button {
        id: logout_btn
        anchors.top: background_btn.bottom
        anchors.left: name.left
        anchors.topMargin: 20
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: press? "#D04528" : "#ff5532"
        textFont.weight: Font.Normal
        textFont.pointSize: 11
        textFont.underline: true
        text: qsTr("Logout")
        visible: u_conf.userId == Telegram.me
        onClicked: Gui.logout()
    }

    Component {
        id: limoo_component
        LimooImageComponent {
            width: chatFrame.chatView.width*3/4
        }
    }
}
