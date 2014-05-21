import QtQuick 2.0

Rectangle {
    id: titlebar
    width: 100
    height: 53
    color: "#403F3A"

    property int current
    property bool isChat: Telegram.dialogIsChat(current)

    MouseArea {
        anchors.fill: parent
    }

    Column {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: title
            font.pointSize: 14
            anchors.horizontalCenter: column.horizontalCenter
            color: "#bbbbbb"
            text: Telegram.dialogTitle(titlebar.current)
        }

        Text {
            id: last_time
            font.pointSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#bbbbbb"
            text: titlebar.isChat? qsTr("Chat Room") :
                      qsTr("Last seen") + " " + Telegram.convertDateToString( Telegram.dialogUserLastTime(titlebar.current) )
        }
    }
}
