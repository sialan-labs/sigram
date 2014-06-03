import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    width: 100
    height: 62
    clip: true

    property alias current: contact_list.current

    property alias contactList: contact_list
    property alias chatView: chat_view

    ContactList {
        id: contact_list
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 250
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

    FastBlur {
        id: chat_view_blur
        anchors.fill: chat_view
        source: chat_view
        radius: 64
        cached: true
        opacity: forwarding==0? 0 : 1
        visible: opacity != 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            hoverEnabled: true
            onWheel: wheel.accepted = true
        }

        ForwardingPage {
            anchors.fill: parent
        }
    }
}
