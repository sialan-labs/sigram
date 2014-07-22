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
    id: add_menu
    width: 100
    height: 62
    clip: true

    signal selected( int uid )
    signal close()

    property bool addGroup: false

    Item {
        id: input_line_frame
        anchors.left: add_menu_header.right
        anchors.top: add_menu_header.top
        width: parent.width
        height: 42

        Item {
            anchors.fill: parent
            anchors.margins: 4

            Text {
                id: input_placeholder
                anchors.fill: input_line
                clip: true
                text: qsTr("Enter name and select contacts")
                font: input_line.font
                elide: Text.ElideRight
                wrapMode: Text.WrapAnywhere
                color: "#888888"
                visible: input_line.text.length == 0
                verticalAlignment: Text.AlignVCenter
            }

            TextInput {
                id: input_line
                anchors.fill: parent
                anchors.rightMargin: create_chat_btn.width
                clip: true
                anchors.margins: 4
                verticalAlignment: Text.AlignVCenter
                onAccepted: input_line_frame.addChat()
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                color: "#dddddd"
                height: 1
            }

            Button {
                id: create_chat_btn
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 1
                normalColor: "#00000000"
                highlightColor: "#660d80ec"
                icon: "files/go.png"
                onClicked: input_line_frame.addChat()
            }
        }

        function addChat() {
            var txt = input_line.text.trim()
            if( txt.length == 0 )
                return

            var cntcts = c_dialog.selectedContacts()
            if( cntcts.length == 0 )
                return

            Telegram.createChatUsers( txt, cntcts )
            add_menu.close()
        }
    }

    Item {
        id: add_menu_header
        x: add_menu.addGroup? -width : 0
        width: parent.width
        anchors.top: parent.top
        height: 42

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 300 }
        }

        Button {
            id: secret_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            normalColor: "#00000000"
            highlightColor: "#00000000"
            text: qsTr("Add Secret chat")
            textColor: press? "#0d80ec" : "#333333"
            visible: false
        }

        Button {
            id: chat_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            normalColor: "#00000000"
            highlightColor: "#00000000"
            text: qsTr("Add Chat")
            textColor: press? "#0d80ec" : "#333333"
            onClicked: {
                add_menu.addGroup = true
                input_line.focus = true
                c_dialog.showFullContacts()
                c_dialog.multiSelectMode = true
            }
        }
    }

    ContactDialog {
        id: c_dialog
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: add_menu_header.bottom
        anchors.bottom: parent.bottom
        onSelected: add_menu.selected(uid)
        Component.onCompleted: showNeededContacts()
    }
}
