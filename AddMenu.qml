import QtQuick 2.0

Item {
    id: add_menu
    width: 100
    height: 62

    signal selected( int uid )

    Item {
        id: add_menu_header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 42

        Button {
            id: secret_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            normalColor: "#00000000"
            highlightColor: "#00000000"
            text: qsTr("Add Secret chat")
            textColor: press? "#0d80ec" : "#333333"
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
        }
    }

    ContactDialog {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: add_menu_header.bottom
        anchors.bottom: parent.bottom
        onSelected: add_menu.selected(uid)
    }
}
