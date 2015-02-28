import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls
import Cutegram 1.0
import CutegramTypes 1.0

Rectangle {
    id: smsg
    clip: true
    color: backColor2
    height: {
        if(txt_frame.height+4*Devices.density<minimumHeight)
            return minimumHeight
        else
            return txt_frame.height+4*Devices.density
    }

    property Dialog currentDialog
    property real minimumHeight: 40*Devices.density

    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false

    property alias trash: trash_item.visible

    signal accepted( string text )
    signal emojiRequest(real x, real y)

    onCurrentDialogChanged: {
        temp_hash.remove(privates.lastDialog)
        temp_hash.insert(privates.lastDialog, txt.text)

        var text = temp_hash.value(currentDialog)
        txt.text = text? text : ""
        txt.cursorPosition = txt.length
        txt.focus = true

        privates.lastDialog = currentDialog
    }

    HashObject {
        id: temp_hash
    }

    QtObject {
        id: privates
        property Dialog lastDialog: telegramObject.nullDialog
    }

    Timer {
        id: typing_timer
        interval: 3000
        onTriggered: finishTyping()
        function finishTyping() {
            var peerId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
            telegramObject.messagesSetTyping(peerId, false)
        }
    }

    Timer {
        id: typing_update_timer
        interval: 1000

        function startTyping() {
            typing_timer.restart()
            if(running)
                return

            var peerId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
            telegramObject.messagesSetTyping(peerId, true)
        }
    }

    Text {
        anchors.centerIn: parent
        visible: currentDialog.peer.userId==telegram.cutegramId
        horizontalAlignment: Text.AlignHCenter
        font: AsemanApp.globalFont
        color: "#333333"
        text: qsTr("It's Cutegram news about new releases and solutions.\n"+
                   "It's not a telegram contact. It's just a virtual contact. ")
    }

    Item {
        id: msd_send_frame
        anchors.fill: parent
        visible: currentDialog.peer.userId!=telegram.cutegramId

        MouseArea {
            anchors.fill: parent
            onClicked: txt.focus = true
        }

        Controls.Frame {
            id: txt_frame
            anchors.left: camera_btn.right
            anchors.right: send_btn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 4*Devices.density
            height: txt.height+8*Devices.density<34*Devices.density? 34*Devices.density : txt.height+8*Devices.density
            backgroundColor: "#f5f5f5"

            TextAreaCore {
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10*Devices.density
                anchors.rightMargin: 5*Devices.density+emoji_btn.width
                anchors.verticalCenter: parent.verticalCenter
                selectByMouse: true
                selectionColor: Cutegram.highlightColor
                selectedTextColor: masterPalette.highlightedText
                pickerEnable: Devices.isTouchDevice
                color: textColor0
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                clip: true
                visible: !trash

                onTextChanged: {
                    if( text.trim().length == 0 )
                        text = ""

                    typing_update_timer.startTyping()
                }
                Keys.onPressed: {
                    if( event.key == Qt.Key_Return || event.key == Qt.Key_Enter )
                    {
                        if( event.modifiers == Qt.NoModifier )
                            smsg.send()

                        typing_timer.finishTyping()
                    }
                    else
                    if(event.key == 8204 && event.modifiers == Qt.ShiftModifier)
                    {
                        if(txt.selectedText.length!=0)
                            txt.remove(txt.selectionStart, txt.selectionEnd)

                        var npos = txt.cursorPosition+1
                        txt.insert(txt.cursorPosition,"‌") //! Persian mid space character. you can't see it
                        txt.cursorPosition = npos

                        event.accepted = false
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: txt_frame
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.IBeamCursor
            onClicked: {
                if( mouse.button == Qt.RightButton ) {
                    var actions = [qsTr("Copy"),qsTr("Paste"),qsTr("Delete")]
                    var res = Desktop.showMenu(actions)
                    switch(res) {
                    case 0:
                        txt.copy()
                        break;

                    case 1:txt
                        txt.paste()
                        break;

                    case 2:
                        txt.remove(txt.selectionStart, txt.selectionEnd)
                        break;
                    }
                } else {
                    mouse.accepted = false
                }
            }
        }

        Button {
            id: attach_btn
            anchors.left: parent.left
            anchors.verticalCenter: txt_frame.verticalCenter
            height: 40*Devices.density
            width: 40*Devices.density
            opacity: 0.6
            highlightColor: "#220d80ec"
            normalColor: "#00000000"
            cursorShape: Qt.PointingHandCursor
            iconHeight: height*0.5
            icon: "files/attach.png"
            onClicked: {
                if( currentDialog == telegramObject.nullDialog )
                    return
                var file = Desktop.getOpenFileName(View)
                if( file.length == 0 )
                    return

                var dId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
                telegramObject.sendFile(dId, file)
            }
        }

        Button {
            id: camera_btn
            anchors.left: attach_btn.right
            anchors.verticalCenter: txt_frame.verticalCenter
            height: 40*Devices.density
            width: 30*Devices.density
            opacity: 0.6
            highlightColor: "#220d80ec"
            normalColor: "#00000000"
            cursorShape: Qt.PointingHandCursor
            iconHeight: height*0.5
            icon: "files/camera.png"
            onClicked: captureImage()
        }

        DropTrashArea {
            id: trash_item
            anchors.left: camera_btn.right
            anchors.verticalCenter: txt_frame.verticalCenter
            height: 30*Devices.density
            width: height
            dialogItem: currentDialog
        }

        Button {
            id: emoji_btn
            anchors.right: txt_frame.right
            anchors.verticalCenter: txt_frame.verticalCenter
            height: 30*Devices.density
            width: height
            opacity: 0.6
            highlightColor: "#220d80ec"
            normalColor: "#00000000"
            cursorShape: Qt.PointingHandCursor
            iconHeight: height*0.55
            icon: "files/emoji.png"
            onClicked: {
                var pnt = smsg.mapFromItem(emoji_btn,0,0)
                smsg.emojiRequest(pnt.x + width/2, pnt.y + height*0.2)
            }
        }

        Controls.Button {
            id: send_btn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4*Devices.density
            width: 70*Devices.density
            text: qsTr("Send")
//            enabled: txt.length != 0
            onClicked: smsg.send()
        }
    }

    function insertText( str ) {
        if( txt.selectedText.length != 0 )
            txt.remove(txt.selectionStart, txt.selectionEnd)

        txt.insert( txt.cursorPosition, str )
    }

    function send() {
        if( currentDialog == telegramObject.nullDialog )
            return
        var msg = txt.text.trim()
        if( msg == "" )
            return

        smsg.accepted(msg)
        txt.text = ""
    }

    function captureImage() {
        if( currentDialog == telegramObject.nullDialog )
            return

        camera_camponent.createObject(smsg)
    }

    function setFocus() {
        txt.focus = true
    }

    Component {
        id: camera_camponent
        CameraDialog{
            visible: true
            onVisibleChanged: if(!visible) destroy()
            title: qsTr("Camera")
            onSelected: {
                var dId = currentDialog.peer.chatId
                if(dId == 0)
                    dId = currentDialog.peer.userId

                telegramObject.sendFile(dId, path)
                visible = false
            }
        }
    }
}
