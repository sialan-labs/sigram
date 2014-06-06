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
import org.sialan.telegram 1.0

Item {
    id: msg_action
    width: parent.width
    height: frame.height

    property int msg_id: 0

    onMsg_idChanged: {
        var act = Telegram.messageAction(msg_id)
        var text = ""

        switch (act) {
        case Enums.MessageActionEmpty:
          break;

        case Enums.MessageActionGeoChatCreate:
        case Enums.MessageActionGeoChatCheckin:
          break;

        case Enums.MessageActionChatCreate:
            text = qsTr("Chat created by " ) + Telegram.messageFromName(msg_id)
          break;

        case Enums.MessageActionChatEditTitle:
            text = qsTr("Chat renamed to ") + Telegram.messageActionNewTitle(msg_id) + qsTr(" by " ) + Telegram.messageFromName(msg_id)
          break;

        case Enums.MessageActionChatEditPhoto:
            text = qsTr("Chat photo edited by " ) + Telegram.messageFromName(msg_id)
          break;

        case Enums.MessageActionChatDeletePhoto:
            text = qsTr("Chat photo deleted by " ) + Telegram.messageFromName(msg_id)
          break;

        case Enums.MessageActionChatAddUser:
            text = Telegram.messageFromName(msg_id) + qsTr(" added " ) + Telegram.title(Telegram.messageActionUser(msg_id)) + qsTr("to group")
          break;

        case Enums.MessageActionChatDeleteUser:
            text = Telegram.messageFromName(msg_id) + qsTr(" deleted " ) + Telegram.title(Telegram.messageActionUser(msg_id)) + qsTr("from group")
          break;
        }

        txt.text = text
    }

    Rectangle {
        id: frame
        anchors.top: txt.top
        anchors.bottom: txt.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: -4
        color: "#44000000"
    }

    Text {
        id: txt
        anchors.centerIn: parent
        font.pointSize: 9
        font.family: globalTextFontFamily
        color: "#cccccc"
    }
}
