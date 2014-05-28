import QtQuick 2.0

Item {
    width: 100
    height: 62

    property bool isPhoto: Telegram.messageIsPhoto(msgId)
    property int msgId

    Text {
        anchors.centerIn: parent
        text: msgId
    }
}
