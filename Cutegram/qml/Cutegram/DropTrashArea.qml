import QtQuick 2.0
import AsemanTools 1.0
import TelegramQmlLib 1.0
// import CutegramTypes 1.0

Item {
    width: 100
    height: 62

    property Dialog dialogItem
    property bool isChat: dialogItem? dialogItem.peer.chatId != 0 : false

    Image {
        anchors.centerIn: parent
        width: Math.min(parent.width,parent.height)
        height: width
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
        smooth: true
        source: "files/trash.png"
        scale: drop_area.containsDrag? 0.8 : 0.55

        Behavior on scale {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    Timer {
        id: delete_msg_timer
        interval: 300
        onTriggered: telegramObject.deleteMessages([msgId])

        property real msgId

        function start(mid) {
            msgId = mid
            restart()
        }
    }

    DropArea {
        id: drop_area
        anchors.fill: parent

        onDropped: {
            if( dialogItem == telegramObject.nullDialog )
                return

            var dId = isChat? dialogItem.peer.chatId : dialogItem.peer.userId
            if( drop.formats.indexOf("land.aseman.cutegram/messageId") != -1 ) {
                var msgId = drop.getDataAsString("land.aseman.cutegram/messageId")
                delete_msg_timer.start(msgId)
            }
        }
    }
}

