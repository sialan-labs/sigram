import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtQuick.Window 2.0

Rectangle {
    id: acc_view
    width: 100
    height: 62
    color: "#222222"

    property alias telegramObject: dialogs.telegramObject
    property color framesColor: "#aaffffff"
    property alias currentDialog: dialogs.currentDialog
    property bool cutegramDialog: telegramObject.cutegramDialog

    signal addParticianRequest()

    Component.onCompleted: {
        telegramObject.cutegramDialog = Cutegram.cutegramSubscribe
    }

    HashObject {
        id: windoweds_hash
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
        anchors.margins: 10*Devices.density
        height: 36*Devices.density
        color: "#333333"
        textColor: "#ffffff"
        clearButton: true
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
        visible: search_frame.text.length == 0
        forceUnminimum: search_frame.lineFocus || search_frame.text.length != 0
        onWindowRequest: windowed_msg_box.createObject(acc_view, {"currentDialog": dialog})
        onCurrentDialogChanged: {
            msg_box.maxId = 0
            View.visible = true
        }
    }

    AccountSearchList {
        id: search_list
        anchors.fill: dialogs
        clip: true
        keyword: search_frame.text
        telegramObject: dialogs.telegramObject
        onCurrentMessageChanged: {
            if(currentMessage == telegramObject.nullMessage)
                return

            var dialogId = telegramObject.messageDialogId(currentMessage.id)
            currentDialog = telegramObject.dialog(dialogId)
            msg_box.maxId = currentMessage.id + 40
            msg_box.focusOn(currentMessage.id)
        }
    }

    AccountMessageBox {
        id: msg_box
        height: parent.height
        anchors.left: dialogs.right
        anchors.right: parent.right
        currentDialog: dialogs.currentDialog
        telegramObject: dialogs.telegramObject
    }

    function showDialog(dialog) {
        var dId = dialog.peer.chatId
        if(dId == 0)
            dId = dialog.peer.userId

        if(windoweds_hash.containt(dId)) {
            var window = windoweds_hash.value(dId)
            window.visible = true
            window.show()
            window.requestActivate()
        } else {
            currentDialog = dialog
            acc_frame.activeRequest()
            Cutegram.active()
        }

        telegramObject.messagesReadHistory(dId)
    }

    function windowOf(dId) {
        return windoweds_hash.value(dId)
    }

    Component {
        id: windowed_msg_box
        Window {
            id: msg_window
            width: msg_box.width
            height: msg_box.width/1.61
            x: View.x + View.width/2 - width/2
            y: View.y + View.height/2 - height/2
            visible: true
            onVisibleChanged: {
                if(visible)
                    return

                windoweds_hash.remove(dId)
                destroy()
            }

            property alias currentDialog: wmbox.currentDialog
            property int dId: {
                var dId = currentDialog.peer.chatId
                if(dId == 0)
                    dId = currentDialog.peer.userId

                return dId
            }

            Rectangle {
                anchors.fill: parent
                color: Desktop.titleBarColor
            }

            AccountMessageBox {
                id: wmbox
                anchors.fill: parent
                telegramObject: dialogs.telegramObject
            }

            Component.onCompleted: windoweds_hash.insert(dId, msg_window )
        }
    }
}
