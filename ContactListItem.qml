import QtQuick 2.0

Rectangle {
    id: item
    width: 100
    height: 62
    color: marea.pressed || selected? "#E65245" : "#ffffff"

    property int uid
    property bool selected: realId == contact_list.current
    property bool isDialog: item.uid == 0
    property int realId: item.isDialog? dialog_id : item.uid
    property int onlineState: isDialog? Telegram.contactState(dialog_id) : Telegram.contactState(item.uid)

    MouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: contact_list.current = item.isDialog? dialog_id : item.uid
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        ContactImage {
            id: img
            anchors.top: row.top
            anchors.bottom: row.bottom
            width: height
            smooth: true
            uid: item.realId
            borderColor: "#ffffff"
            onlineState: item.onlineState == 1
        }

        Column {
            id: column
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                id: txt
                text: item.isDialog ? Telegram.dialogTitle(dialog_id) : Telegram.contactTitle(item.uid)
                anchors.left: parent.left
                font.pointSize: 10
                color: marea.pressed || item.selected? "#ffffff" : "#333333"
            }

            Text {
                id: date
                anchors.left: parent.left
                font.pointSize: 9
                color: marea.pressed || item.selected? "#dddddd" : "#555555"
                text: item.isDialog ? Telegram.convertDateToString(Telegram.dialogMsgDate(dialog_id)) : " "
            }
        }
    }

    UnreadItem {
        anchors.verticalCenter: item.verticalCenter
        anchors.right: item.right
        anchors.margins: 5
        unread: item.isDialog? Telegram.dialogUnreadCount(dialog_id) : 0
        visible: unread != 0 && !item.selected
    }

    ContactListTools {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        height: 22
        width: 60
        uid: item.realId
        show: marea.containsMouse
    }
}
