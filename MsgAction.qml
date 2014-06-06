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
