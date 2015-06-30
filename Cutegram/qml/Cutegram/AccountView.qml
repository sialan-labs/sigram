import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import AsemanTools.Controls.Styles 1.0
import Cutegram 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import QtQuick.Window 2.0

Rectangle {
    id: acc_view
    width: 100
    height: 62
    color: Cutegram.currentTheme.dialogListBackground

    property alias telegramObject: dialogs.telegramObject
    property color framesColor: "#aaffffff"
    property alias currentDialog: dialogs.currentDialog
    property variant cutegramDialog: telegramObject.newsLetterDialog

    property alias windowsCount: windoweds_hash.count
    property alias emojis: emojis_obj

    signal addParticianRequest()

    Emojis {
        id: emojis_obj
        currentTheme: "twitter"
        userData: telegramObject.userData
        autoEmojis: Cutegram.autoEmojis
        replacements: {":)"   : "😀",
                       ":|"   : "😐",
                       ":("   : "😟",
                       ":d"   : "😁",
                       ":*"   : "😘",
                       ":s"   : "😖",
                       "^_^"  : "😊",
                       ":/"   : "😕",
                       "B)"   : "😎",
                       ":p"   : "😋",
                       ":o"   : "😯",
                       ":x"   : "😍",
                       ";)"   : "😉",
                       ">:)"  : "😈",
                       "o:)"  : "😇",
                       ":(("  : "😢",
                       ":(((" : "😭",
                       ":))"  : "😄",
                       ":)))" : "😆",
                       ":))))": "😂"}
    }

    HashObject {
        id: windoweds_hash
    }

    Connections {
        target: telegramObject
        onNewsLetterDialogChanged: Cutegram.cutegramSubscribe = telegramObject.newsLetterDialog? true : false
    }

    Rectangle {
        anchors.bottom: parent.top
        anchors.right: dialogs.right
        transformOrigin: Item.BottomRight
        rotation: -90
        width: parent.height
        height: Cutegram.currentTheme.dialogListShadowWidth*Devices.density
        opacity: 0.4
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: Cutegram.currentTheme.dialogListShadowColor }
        }
    }

    TextField {
        id: search_frame
        style: Cutegram.currentTheme.searchTextFieldStyle
        anchors.left: dialogs.left
        anchors.top: parent.top
        anchors.right: dialogs.right
        anchors.margins: 10*Devices.density
        placeholderText: qsTr("Search")
        textColor: Cutegram.currentTheme.searchBarTextColor
        font.family: Cutegram.currentTheme.searchBarFont.family
        font.pixelSize: Cutegram.currentTheme.searchBarFont.pointSize*Devices.fontDensity
        Button {
            x: search_frame.horizontalAlignment==TextInput.AlignRight? 6*Devices.density : parent.width-6*Devices.density-width
            anchors.verticalCenter: parent.verticalCenter
            width: 22*Devices.density
            height: width
            iconSource: "files/close.png"
            visible: search_frame.text.length != 0
            onClicked: search_frame.text = ""
        }
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
        onWindowRequest: {
            var dId = dialog.peer.chatId
            if(dId == 0)
                dId = dialog.peer.userId
            if(windoweds_hash.containt(dId)) {
                var window = windoweds_hash.value(dId)
                window.visible = true
                window.show()
                window.requestActivate()
                return
            }

            windowed_msg_box.createObject(acc_view, {"currentDialog": dialog})
        }
        onCurrentDialogChanged: {
            msg_box.maxId = 0
            if(currentDialog != telegramObject.nullDialog )
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
        onTagSearchRequest: search_frame.text = "#" + tag
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
            width: 800*Devices.density
            height: 500*Devices.density
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
                onTagSearchRequest: {
                    search_frame.text = "#" + tag
                    View.show()
                    View.requestActivate()
                }
            }

            Component.onCompleted: {
                windoweds_hash.insert(dId, msg_window )
                x = View.x + View.width/2 - width/2
                y = View.y + View.height/2 - height/2
                width = 800*Devices.density
                height = 500*Devices.density
            }
        }
    }

    function nextDialog() {
        dialogs.next()
    }

    function previousDialog() {
        dialogs.previous()
    }

    function showNull() {
        dialogs.currentDialog = telegramObject.nullDialog
    }
}
