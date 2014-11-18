import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0
import QtGraphicalEffects 1.0

Rectangle {
    width: 100
    height: 62
    color: backColor2

    property alias telegramObject: dialogs.telegramObject
    property color framesColor: "#aaffffff"

    AccountDialogList {
        id: dialogs
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 275*physicalPlatformScale
    }

    AccountMessageList {
        id: messages
        anchors.left: dialogs.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        topMargin: header.height
        bottomMargin: send_msg.height
        telegramObject: dialogs.telegramObject
        currentDialog: dialogs.currentDialog
    }

    Item {
        id: header_blur
        anchors.fill: header
        clip: true

        FastBlur {
            anchors.top: parent.top
            width: messages.width
            height: messages.height
            source: messages
            radius: 64
        }
    }

    Item {
        id: send_msg_blur
        anchors.fill: send_msg
        clip: true

        FastBlur {
            anchors.bottom: parent.bottom
            width: messages.width
            height: messages.height
            source: messages
            radius: 64
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: messages.left
        width: 1*physicalPlatformScale
        color: "#e9e9e9"
    }

    AccountDialogHeader {
        id: header
        anchors.left: dialogs.right
        anchors.top: parent.top
        anchors.right: parent.right
        color: framesColor
        currentDialog: dialogs.currentDialog
        refreshing: messages.refreshing
    }

    AccountSendMessage {
        id: send_msg
        anchors.left: dialogs.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: framesColor
        currentDialog: dialogs.currentDialog
        onAccepted: messages.sendMessage(text)
    }
}
