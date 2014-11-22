import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: acc_view
    width: 100
    height: 62
    color: backColor2

    property alias telegramObject: dialogs.telegramObject
    property color framesColor: "#aaffffff"
    property alias currentDialog: dialogs.currentDialog

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
        onClicked: {
            if( properties )
                properties.end()
            else
            if( currentDialog != telegramObject.nullDialog )
                properties = user_prp_component.createObject(acc_view)
        }

        property UserProperties properties
    }

    AccountSendMessage {
        id: send_msg
        anchors.left: dialogs.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: framesColor
        currentDialog: dialogs.currentDialog
        onAccepted: messages.sendMessage(text)
        onEmojiRequest: {
            var item = emoticons_component.createObject(acc_view)
            var w = 260*physicalPlatformScale
            var h = w

            pointerDialog.pointerLeftMargin = w*0.6
            main.showPointDialog(item, x-w*0.6-20*physicalPlatformScale, y, w, h)
        }
    }

    Item {
        id: drop_file_blur
        anchors.fill: drop_file
        clip: true
        opacity: drop_file.visibleRatio
        visible: opacity != 0

        FastBlur {
            anchors.top: parent.top
            anchors.topMargin: -messages.topMargin
            width: messages.width
            height: messages.height
            source: messages
            radius: 32
        }
    }

    DialogDropFile {
        id: drop_file
        anchors.left: dialogs.right
        anchors.top: header.bottom
        anchors.right: parent.right
        anchors.bottom: send_msg.top
        currentDialog: dialogs.currentDialog
    }

    Component {
        id: emoticons_component

        Emoticons {
            id: emoticons
            anchors.right: parent.right
            anchors.bottom: send_msg.top
            anchors.top: header.bottom
            width: 200*physicalPlatformScale
            onSelected: send_msg.insertText(code)
        }
    }

    Component {
        id: user_prp_component
        UserProperties {
            anchors.left: dialogs.right
            anchors.top: header.bottom
            anchors.right: parent.right
            anchors.bottom: send_msg.top
            currentDialog: acc_view.currentDialog
            blurSource: messages
            blurTopMargin: -messages.topMargin
            color: "#66ffffff"

            Component.onCompleted: inited = true
        }
    }
}
