import QtQuick 2.2
import QtQuick.Window 2.1

Window {
    visible: true
    width: 800
    height: 500

    ContactList {
        id: contact_list
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 213
    }

    ChatView {
        id: chat_view
        anchors.left: contact_list.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#eeeeee"
        current: contact_list.current
    }
}
