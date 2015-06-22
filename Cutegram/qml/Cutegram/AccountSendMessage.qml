import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0 as Styles
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: smsg
//    clip: true
    height: {
        if(txt_frame.height+4*Devices.density<minimumHeight)
            return minimumHeight
        else
            return txt_frame.height+4*Devices.density
    }

    property Dialog currentDialog
    property real minimumHeight: Cutegram.currentTheme.sendFrameHeight*Devices.density

    property color color: "#ffffff"
    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false

    property alias trash: trash_item.visible

    signal accepted( string text, int inReplyTo )
    signal emojiRequest(real x, real y)
    signal copyRequest()

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
        property variant suggestionItem
    }

    Timer {
        id: typing_timer
        interval: 3000
        onTriggered: finishTyping()

        function finishTyping() {
            var peerId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
            if(peerId != 0)
                telegramObject.messagesSetTyping(peerId, false)
            typing_update_timer.stop()
        }
    }

    Timer {
        id: typing_update_timer
        interval: 3000
        triggeredOnStart: true
        onTriggered: {
            var peerId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
            if(peerId != 0)
                telegramObject.messagesSetTyping(peerId, true)
        }

        function startTyping() {
            typing_timer.restart()
            if(running)
                return

            typing_update_timer.restart()
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

    MouseArea {
        anchors.fill: parent
        onWheel: wheel.accepted = true
    }

    Item {
        id: msd_send_frame
        anchors.fill: parent
        visible: currentDialog.peer.userId!=telegram.cutegramId

        MouseArea {
            anchors.fill: parent
            onClicked: txt.focus = true
        }

        Rectangle {
            anchors.fill: parent
            color: smsg.color
        }

        Controls.Frame {
            id: txt_frame
            anchors.left: attach_box.right
            anchors.right: send_btn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 4*Devices.density
            height: logicalHeight>200*Devices.density? 200*Devices.density : logicalHeight
            backgroundColor: smsg.color
            shadowColor: Cutegram.currentTheme.sendFrameShadowColor
            shadowSize: Cutegram.currentTheme.sendFrameShadowSize

            property real logicalHeight: txt.height+8*Devices.density<34*Devices.density? 34*Devices.density : txt.height+8*Devices.density

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: width
                contentHeight: txt_scene.height
                flickableDirection: Flickable.VerticalFlick
                topMargin: txt.height<height? (height-txt.height)/2 : 8*Devices.density
                bottomMargin: topMargin
                clip: true

                function ensureVisible(r)
                {
                    if (contentX >= r.x)
                        contentX = r.x;
                    else if (contentX+width <= r.x+r.width)
                        contentX = r.x+r.width-width;
                    if (contentY >= r.y)
                        contentY = r.y;
                    else if (contentY+height <= r.y+r.height)
                        contentY = r.y+r.height-height;
                }

                Item {
                    id: txt_scene
                    width: parent.width
                    height: txt.height<flick.height? flick.height : txt.height

                    TextAreaCore {
                        id: txt
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 10*Devices.density
                        anchors.rightMargin: 5*Devices.density+emoji_btn.width
                        anchors.verticalCenter: parent.verticalCenter
                        selectByMouse: true
                        selectionColor: Cutegram.currentTheme.masterColor
                        selectedTextColor: masterPalette.highlightedText
                        pickerEnable: Devices.isTouchDevice
                        color: Cutegram.currentTheme.sendFrameFontColor
                        font.family: Cutegram.currentTheme.sendFrameFont.family
                        font.pixelSize: Cutegram.currentTheme.sendFrameFont.pointSize*Devices.fontDensity
                        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                        clip: true
                        visible: !trash
                        placeholder: qsTr("Write a message...")

                        onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                        onTextChanged: {
                            if( text.trim().length == 0 )
                                text = ""

                            typing_update_timer.startTyping()
                        }
                        Keys.onPressed: {
                            if((event.key == Qt.Key_Enter || event.key == Qt.Key_Return) && privates.suggestionItem)
                            {
                                var result
                                if(privates.suggestionItem.isTagSuggestion) {
                                    result = privates.suggestionItem.currentTag()
                                } else {
                                    var uId = privates.suggestionItem.currentUserId()
                                    if(!uId) {
                                        if( event.modifiers == Qt.NoModifier )
                                            smsg.send()

                                        typing_timer.finishTyping()
                                        return
                                    }

                                    var userObj = telegramObject.user(uId)
                                    var userName = userObj.username
                                    result = userName
                                }

                                txt.selectWord()
                                txt.remove(txt.selectionStart, txt.selectionEnd)
                                txt.insert(txt.cursorPosition, result)

                                last_line_remover.restart()
                                privates.suggestionItem.destroy()
                                event.accepted = false
                            }
                            else
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
                            else
                            if(event.modifiers == Qt.ControlModifier && event.key == Qt.Key_C)
                            {
                                if(txt.selectedText.length == 0) {
                                    smsg.copyRequest()
                                    event.accepted = false
                                }
                            }
                            else
                            if(event.key == Qt.Key_At || event.key == Qt.Key_NumberSign)
                            {
                                if(!privates.suggestionItem) {
                                    if(event.key == Qt.Key_At)
                                        privates.suggestionItem = username_sgs_component.createObject(mainFrame)
                                    else
                                    if(event.key == Qt.Key_NumberSign)
                                        privates.suggestionItem = tags_sgs_component.createObject(mainFrame)

                                    var pnt = smsg.mapToItem(mainFrame, 0, 0)
                                    var pntY = pnt.y
                                    var pntX = pnt.x + txt.positionToRectangle(txt.cursorPosition).x + txt_frame.x

                                    privates.suggestionItem.x = pntX
                                    privates.suggestionItem.y = pntY - privates.suggestionItem.height
                                } else {
                                    privates.suggestionItem.keyword = ""
                                }
                            }
                            else
                            if(event.key == Qt.Key_Space || event.key == Qt.Key_Escape || event.key == Qt.Key_Delete)
                            {
                                if(privates.suggestionItem)
                                    privates.suggestionItem.destroy()
                            }
                            else
                            if(event.key == Qt.Key_Up && privates.suggestionItem)
                            {
                                privates.suggestionItem.up()
                                event.accepted = false
                            }
                            else
                            if(event.key == Qt.Key_Down && privates.suggestionItem)
                            {
                                privates.suggestionItem.down()
                                event.accepted = false
                            }
                            else
                            if((event.modifiers == Qt.NoModifier || event.modifiers == Qt.ShiftModifier) && privates.suggestionItem &&
                               event.key != Qt.Key_Left && event.key != Qt.Key_Right)
                            {
                                check_suggestion.restart()
                            }
                        }

                        Timer {
                            id: last_line_remover
                            interval: 1
                            onTriggered: {
                                var cpos = txt.cursorPosition
                                txt.text = txt.text.slice(0, cpos-1) + " " + txt.text.slice(cpos+1, txt.length)
                                txt.cursorPosition = cpos
                            }
                        }
                    }
                }
            }

            ScrollBar {
                scrollArea: flick; height: flick.height; width: 6*Devices.density
                anchors.right: flick.right; anchors.top: flick.top; color: "#888888"
            }
        }

        MouseArea {
            anchors.fill: txt_frame
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.IBeamCursor
            onPressed: {
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

        Item {
            id: attach_box
            anchors.left: parent.left
            anchors.verticalCenter: txt_frame.verticalCenter
            height: 40*Devices.density
            width: attach_box_marea.containsMouse || attach_box_timer.running? 100*Devices.density : 40*Devices.density
            clip: true

            Behavior on width {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }

            Timer {
                id: attach_box_timer
                interval: 500
            }

            MouseArea {
                id: attach_box_marea
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: if(!containsMouse) attach_box_timer.restart()
            }

            Button {
                id: attach_btn
                anchors.left: parent.left
                height: 40*Devices.density
                width: 40*Devices.density
                hoverEnabled: false
                opacity: Cutegram.currentTheme.sendFrameLightIcon? 1 : 0.6
                highlightColor: "#220d80ec"
                normalColor: "#00000000"
                cursorShape: Qt.PointingHandCursor
                iconHeight: height*0.5
                icon: Cutegram.currentTheme.sendFrameLightIcon? "files/attach-light.png" : "files/attach.png"
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
                height: 40*Devices.density
                width: 30*Devices.density
                hoverEnabled: false
                opacity: Cutegram.currentTheme.sendFrameLightIcon? 1 : 0.6
                highlightColor: "#220d80ec"
                normalColor: "#00000000"
                cursorShape: Qt.PointingHandCursor
                iconHeight: height*0.5
                icon: Cutegram.currentTheme.sendFrameLightIcon? "files/camera-light.png" : "files/camera.png"
                onClicked: captureImage()
            }

            Button {
                id: microphone_btn
                anchors.left: camera_btn.right
                height: 40*Devices.density
                width: 30*Devices.density
                hoverEnabled: false
                opacity: Cutegram.currentTheme.sendFrameLightIcon? 1 : 0.7
                highlightColor: "#220d80ec"
                normalColor: "#00000000"
                cursorShape: Qt.PointingHandCursor
                iconHeight: height*0.6
                icon: Cutegram.currentTheme.sendFrameLightIcon? "files/microphone-light.png" : "files/microphone.png"
                onClicked: recordAudio()
            }
        }

        DropTrashArea {
            id: trash_item
            anchors.left: attach_box.right
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
            opacity: Cutegram.currentTheme.sendFrameLightIcon? 1 : 0.6
            highlightColor: "#220d80ec"
            normalColor: "#00000000"
            cursorShape: Qt.PointingHandCursor
            iconHeight: height*0.55
            icon: Cutegram.currentTheme.sendFrameLightIcon? "files/emoji-light.png" : "files/emoji.png"
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

        if(Cutegram.autoEmojis)
            msg = emojis.convertSmiliesToEmoji(msg)
        if(privates.suggestionItem)
            privates.suggestionItem.destroy()

        smsg.accepted(msg, messageReply.replyMessage? messageReply.replyMessage.id : 0)
        messageReply.discard()
        txt.text = ""
    }

    function captureImage() {
        if( currentDialog == telegramObject.nullDialog )
            return

        camera_camponent.createObject(smsg, {"dialog": currentDialog})
    }

    function recordAudio() {
        if( currentDialog == telegramObject.nullDialog )
            return

        recorder_camponent.createObject(smsg, {"dialog": currentDialog})
    }

    function setFocus() {
        txt.focus = true
    }

    function replyTo(msgId) {
        messageReply.replyMessage = telegramObject.message(msgId)
    }

    Timer {
        id: check_suggestion
        interval: 20
        onTriggered: {
            txt.selectWord()
            privates.suggestionItem.keyword = txt.selectedText
            txt.deselect()
        }
    }

    Item {
        width: parent.width
        height: messageReply.height
        anchors.bottom: parent.top
        visible: messageReply.replyMessage? true : false

        Rectangle {
            anchors.fill: parent
            color: smsg.color
            opacity: 0.8
        }

        MessageReplyItem {
            id: messageReply
            telegram: telegramObject

            function discard() {
                messageReply.replyMessage = messageReply.message
            }
        }

        Controls.Button {
            width: height
            anchors.right: parent.right
            anchors.rightMargin: 4*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            iconSource: "files/close.png"
            onClicked: messageReply.discard()
        }
    }

    Component {
        id: camera_camponent
        CameraDialog{
            visible: true
            onVisibleChanged: if(!visible) destroy()
            title: qsTr("Camera")

            property Dialog dialog

            onSelected: {
                var dId = dialog.peer.chatId
                if(dId == 0)
                    dId = dialog.peer.userId

                telegramObject.sendFile(dId, path)
                visible = false
            }
        }
    }

    Component {
        id: recorder_camponent
        RecorderDialog {
            visible: true
            onVisibleChanged: if(!visible) destroy()
            title: qsTr("Audio Recorder")

            property Dialog dialog

            onSelected: {
                var dId = dialog.peer.chatId
                if(dId == 0)
                    dId = dialog.peer.userId

                telegramObject.sendFile(dId, path, false, true)
                visible = false
            }
        }
    }

    Component {
        id: username_sgs_component
        UserNameSuggestionMenu {
            telegram: telegramObject
            dialog: currentDialog
            property bool isTagSuggestion: false
        }
    }

    Component {
        id: tags_sgs_component
        TagSuggestionMenu {
            telegram: telegramObject
            property bool isTagSuggestion: true
        }
    }
}
