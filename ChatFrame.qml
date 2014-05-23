import QtQuick 2.0

Rectangle {
    width: 100
    height: 62

    property alias current: contact_list.current

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
        color: "#555555"
        current: contact_list.current
    }
}
