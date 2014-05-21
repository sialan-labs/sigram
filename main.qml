import QtQuick 2.2
import QtQuick.Window 2.1

Window {
    visible: true
    width: 1024
    height: 600

    property real physicalPlatformScale: 1
    property real fontsScale: 1
    property string globalFontFamily

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
