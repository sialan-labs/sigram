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
        privates.on_init = true
        notify.userMuted = Gui.isMuted(u_conf.userId)
        fave.checked = Gui.isFavorited(u_conf.userId)
        love.checked = (u_conf.userId == Gui.love)
        name.text = Telegram.title(u_conf.userId).trim()
        privates.on_init = false
    }

    Connections {
        target: Gui
        onMuted: {
            if( id != u_conf.userId )
                return

            notify.userMuted = Gui.isMuted(u_conf.userId)
        }
    }

    QtObject {
        id: privates
        property bool on_init: false
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
        x: (name.x-width)/2
        anchors.top: header.bottom
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

    LineEdit {
        id: name
        anchors.top: cimg.top
        anchors.left: parent.left
        anchors.leftMargin: Math.max(notify_label.width+40, 220 )
        font.pointSize: 18
        font.weight: Font.DemiBold
        font.family: globalNormalFontFamily
    }

    Button {
        anchors.verticalCenter: name.verticalCenter
        anchors.left: name.right
        visible: !name.readOnly
        textColor: "#ffffff"
        normalColor: "#4098bf"
        highlightColor: "#337fa2"
        text: qsTr("Rename")
        onClicked: {
            Telegram.renameContact( phone.text, name.text )
            name.readOnly = true
        }
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

    TextInput {
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
        visible: u_conf.userId !== Telegram.me && !u_conf.isChat
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
        visible: u_conf.userId !== Telegram.me && !u_conf.isChat
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
        id: love_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.verticalCenter: love.verticalCenter
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#555555"
        visible: !u_conf.isChat
        text: qsTr("Love:")
    }

    CheckBox {
        id: love
        anchors.top: phone.bottom
        anchors.left: name.left
        anchors.topMargin: 10
        checked: false
        visible: !u_conf.isChat
        onCheckedChanged: {
            if( !checked && Gui.love != u_conf.userId )
                return

            if( checked )
                Gui.love = u_conf.userId
            else
                Gui.love = 0
        }
    }

    Text {
        id: fave_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.verticalCenter: fave.verticalCenter
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#555555"
        text: qsTr("Favorite:")
    }

    CheckBox {
        id: fave
        anchors.top: u_conf.isChat? c_users.bottom : love.bottom
        anchors.left: name.left
        anchors.topMargin: 10
        checked: false
        onCheckedChanged: {
            Gui.setFavorite( u_conf.userId, checked )
        }
    }

    Text {
        id: notify_label
        anchors.right: phone.left
        anchors.rightMargin: 20
        anchors.verticalCenter: notify.verticalCenter
        font.pointSize: 11
        font.family: globalNormalFontFamily
        color: "#555555"
        text: u_conf.userId == Telegram.me? qsTr("Disable all notifies:") : qsTr("Notification:")
    }

    CheckBox {
        id: notify
        anchors.top: fave.bottom
        anchors.left: name.left
        anchors.topMargin: 10
        checked: u_conf.userId == Telegram.me? Gui.muteAll : !userMuted
        onCheckedChanged: {
            if( u_conf.userId == Telegram.me )
                Gui.muteAll = checked
            else
                Gui.setMute( u_conf.userId, !checked )
        }

        property bool userMuted: false
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
        visible: u_conf.userId == Telegram.me
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
            onRightClick: showMenu()
        }
    }

    function showMenu() {
        var acts = [ qsTr("Copy"), qsTr("Save as") ]

        var res = Gui.showMenu( acts )
        switch( res ) {
        case 0:
            Gui.copyFile(cimg.source)
            break;
        case 1:
            Gui.saveFile(cimg.source)
            break;
        }
    }
}
