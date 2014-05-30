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

    signal clicked()

    MouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: item.clicked()
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
            width: row.width - img.width - row.spacing - 4
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Item {
                anchors.left: parent.left
                width: parent.width
                height: txt.height

                Text {
                    id: txt
                    text: item.isDialog ? Telegram.dialogTitle(dialog_id) : Telegram.contactTitle(item.uid)
                    anchors.left: parent.left
                    width: parent.width - date.width
                    font.pointSize: 10
                    font.weight: Font.DemiBold
                    font.family: globalNormalFontFamily
                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAnywhere
                    color: marea.pressed || item.selected? "#ffffff" : "#333333"
                }

                Text {
                    id: date
                    anchors.right: parent.right
                    font.pointSize: 9
                    font.weight: Font.Normal
                    font.family: globalNormalFontFamily
                    color: marea.pressed || item.selected? "#dddddd" : "#555555"
                    text: item.isDialog ? Telegram.convertDateToString(Telegram.dialogMsgDate(dialog_id)) : " "
                }
            }

            Item {
                anchors.left: parent.left
                width: parent.width
                height: last_msg.height

                Text {
                    id: last_msg
                    text: Telegram.dialogMsgLast(dialog_id)
                    anchors.left: parent.left
                    width: parent.width
                    font.pointSize: 9
                    font.weight: Font.Normal
                    font.family: globalTextFontFamily
                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAnywhere
                    color: marea.pressed || item.selected? "#dddddd" : "#555555"
                }
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
