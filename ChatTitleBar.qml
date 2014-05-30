import QtQuick 2.0

Rectangle {
    id: titlebar
    width: 100
    height: 53
    color: "#403F3A"

    property int current
    property bool isChat: Telegram.dialogIsChat(current)

    Connections {
        target: Telegram
        onUserIsTyping: {
            if( chat_id != titlebar.current )
                return

            is_typing.user = user_id
            typing_timer.restart()
        }
    }

    Timer {
        id: typing_timer
        interval: 5000
        repeat: false
        onTriggered: is_typing.user = 0
    }

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
            font.pointSize: 15
            anchors.horizontalCenter: column.horizontalCenter
            color: "#bbbbbb"
            font.family: globalNormalFontFamily
            text: Telegram.title(titlebar.current)
        }

        Text {
            id: last_time
            font.pointSize: 10
            font.family: globalNormalFontFamily
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#bbbbbb"
            visible: !is_typing.visible
            text: titlebar.isChat? qsTr("Chat Room") :
                      qsTr("Last seen") + " " + Telegram.convertDateToString( Telegram.dialogUserLastTime(titlebar.current) )
        }

        Text {
            id: is_typing
            font.pointSize: 10
            font.family: globalNormalFontFamily
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#bbbbbb"
            text: user==0? "" : Telegram.dialogTitle(user) + qsTr("is typing...")
            visible: user!=0

            property int user
        }
    }
}
