import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: acc_view
    width: 100
    height: 62
    color: "#222222"

    property alias telegramObject: dialogs.telegramObject
    property color framesColor: "#aaffffff"
    property alias currentDialog: dialogs.currentDialog
    property bool cutegramDialog: telegramObject.cutegramDialog

    Component.onCompleted: {
        telegramObject.cutegramDialog = Cutegram.cutegramSubscribe
    }

    Connections {
        target: telegramObject
        onCutegramDialogChanged: Cutegram.cutegramSubscribe = telegramObject.cutegramDialog
    }

    LineEdit {
        id: search_frame
        anchors.left: dialogs.left
        anchors.top: parent.top
        anchors.right: dialogs.right
        anchors.margins: 8*Devices.density
        height: 40*Devices.density
        color: "#333333"
        textColor: "#ffffff"
        placeholder: qsTr("Search")
        pickerEnable: Devices.isTouchDevice
    }

    AccountDialogList {
        id: dialogs
        anchors.left: parent.left
        anchors.top: search_frame.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 4*Devices.density
        clip: true
    }

    Item {
        id: properties_frame
        anchors.left: dialogs.right
        anchors.right: parent.right
        height: parent.height
        clip: true
    }

    Item {
        id: message_box
        height: parent.height
        y: header.properties && header.properties.inited? header.properties.height : 0
        anchors.left: dialogs.right
        anchors.right: parent.right
        clip: true

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        AccountMessageList {
            id: messages
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            topMargin: header.height
            bottomMargin: send_msg.height
            telegramObject: dialogs.telegramObject
            currentDialog: dialogs.currentDialog
            onForwardRequest: forward_component.createObject(message_box, {"forwardMessage":message})
        }

        Item {
            id: header_blur
            anchors.fill: header
            clip: true
            visible: Cutegram.visualEffects

            FastBlur {
                anchors.top: parent.top
                width: messages.width
                height: messages.height
                source: messages
                radius: Cutegram.visualEffects?64:0
            }
        }

        Item {
            id: send_msg_blur
            anchors.fill: send_msg
            clip: true
            visible: Cutegram.visualEffects

            FastBlur {
                anchors.bottom: parent.bottom
                width: messages.width
                height: messages.height
                source: messages
                radius: Cutegram.visualEffects?64:0
            }
        }

        AccountDialogHeader {
            id: header
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            currentDialog: dialogs.currentDialog
            refreshing: messages.refreshing
            color: {
                if(!Cutegram.visualEffects)
                    return "#fafafa"
                else
                if(currentDialog.encrypted)
                    return "#aa000000"
                else
                    return framesColor
            }
            onClicked: {
                if( properties )
                    properties.end()
                else
                if( currentDialog != telegramObject.nullDialog )
                    properties = user_prp_component.createObject(properties_frame)
            }

            property UserProperties properties
        }

        AccountSendMessage {
            id: send_msg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: Cutegram.visualEffects?framesColor:"#fafafa"
            currentDialog: dialogs.currentDialog
            onAccepted: messages.sendMessage(text)
            trash: messages.messageDraging
            onEmojiRequest: {
                var item = emoticons_component.createObject(message_box)
                var w = 260*Devices.density
                var h = w

                pointerDialog.pointerLeftMargin = w*0.6
                main.showPointDialog(item, x-w*0.6-20*Devices.density, y, w, h)
            }
        }

        Item {
            id: drop_file_blur
            anchors.fill: drop_file
            clip: true
            opacity: drop_file.visibleRatio
            visible: opacity != 0 && Cutegram.visualEffects

            FastBlur {
                anchors.top: parent.top
                anchors.topMargin: -messages.topMargin
                width: messages.width
                height: messages.height
                source: messages
                radius: Cutegram.visualEffects?32:0
            }
        }

        DialogDropFile {
            id: drop_file
            anchors.left: parent.left
            anchors.top: header.bottom
            anchors.right: parent.right
            anchors.bottom: send_msg.top
            dialogItem: dialogs.currentDialog
            currentDialog: dialogs.currentDialog
        }

        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
            opacity: header.properties && header.properties.inited? 0.5 : 0
            visible: header.properties? true : false

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                hoverEnabled: true
                onWheel: wheel.accepted = true
                onClicked: BackHandler.back()
            }
        }
    }

    Component {
        id: emoticons_component
        Emoticons {
            id: emoticons
            anchors.right: parent.right
            anchors.bottom: send_msg.top
            anchors.top: header.bottom
            width: 200*Devices.density
            onSelected: send_msg.insertText(code)
        }
    }

    Component {
        id: user_prp_component
        UserProperties {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            currentDialog: acc_view.currentDialog
            color: Desktop.titleBarColor
        }
    }

    Component {
        id: forward_component
        Item {
            id: forward_item
            anchors.fill: messages
            clip: true

            property alias forwardMessage: forward_page.forwardMessage
            property alias forwardDialog: forward_page.forwardDialog

            FastBlur {
                anchors.fill: parent
                source: messages
                radius: Cutegram.visualEffects?64:0
                visible: Cutegram.visualEffects
            }

            ForwardPage {
                id: forward_page
                anchors.fill: parent
                color: Cutegram.visualEffects?"#66ffffff":"#ddffffff"
                onCloseRequest: forward_item.destroy()
            }

            Connections {
                target: acc_view
                onCurrentDialogChanged: forwardDialog = acc_view.currentDialog
            }
        }
    }
}
