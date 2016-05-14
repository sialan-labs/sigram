import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

ToolKit.TgRectangle {
    id: msgInput
    color: "#fefefe"
    height: textFrame.height + replyInputFrame.height

    property alias messagesModel: textFrame.messagesModel
    property alias forwarding: forward_area.visible

    onCurrentPeerChanged: {
        checkPanels()
        replyInput.messageId = 0
        replyInput.currentPeer = null
    }

    signal forward()

    Button {
        id: attach_btn
        anchors.top: textFrame.top
        anchors.bottom: parent.bottom
        width: textFrame.minimumHeight
        text: Awesome.fa_paperclip
        textColor: "#959595"
        highlightColor: "#eeeeee"
        textFont.family: Awesome.family
        textFont.pixelSize: 14*Devices.fontDensity
    }

    Rectangle {
        id: left_splitter
        anchors.left: attach_btn.right
        anchors.top: textFrame.top
        anchors.bottom: parent.bottom
        width: 1*Devices.density
        color: "#eeeeee"
    }

    Item {
        id: replyInputFrame
        width: parent.width
        height: replyInput.messageId? replyInput.height : 0
        visible: height != 0
        clip: true

        Behavior on height {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
        }

        MessageInputReply {
            id: replyInput
            width: parent.width
            engine: msgInput.engine

            onMessageIdChanged: {
                if(messageId)
                    BackHandler.pushHandler(replyInput, function(){
                        messageId = 0
                        currentPeer = null
                    })
                else
                    BackHandler.removeHandler(replyInput)
            }
        }


        Rectangle {
            width: parent.width
            anchors.bottom: parent.bottom
            height: 1*Devices.density
            color: "#eeeeee"
        }
    }

    MessageTextFrame {
        id: textFrame
        anchors.top: replyInputFrame.bottom
        anchors.left: left_splitter.right
        anchors.right: emoji_btn.left
        engine: msgInput.engine
        currentPeer: msgInput.currentPeer
        onSendMessage: {
            queue = [text]
            if(split)
                queue = text.split("\n\n")

            queueIdx = 0
            queueSendNext()
            replyInput.messageId = 0
            replyInput.currentPeer = null
            split = false
        }

        property variant queue
        property int queueIdx: 0

        function queueSendNext() {
            if(queueIdx == queue.length)
                return

            messagesModel.sendMessage(queue[queueIdx], replyInput.replyMessage, 0, queueSendNext)
            queueIdx++
        }
    }

    Button {
        id: emoji_btn
        anchors.top: textFrame.top
        anchors.bottom: parent.bottom
        width: textFrame.minimumHeight
        anchors.right: right_splitter.left
        text: Awesome.fa_smile_o
        textColor: "#959595"
        highlightColor: "#eeeeee"
        textFont.family: Awesome.family
        textFont.pixelSize: 14*Devices.fontDensity
        onContainsMouseChanged: checkPanels()
    }

    Rectangle {
        id: right_splitter
        anchors.right: sticker_btn.left
        anchors.top: textFrame.top
        anchors.bottom: parent.bottom
        width: 1*Devices.density
        color: "#eeeeee"

        NullMouseArea {
            anchors.fill: parent
        }
    }

    Button {
        id: sticker_btn
        anchors.top: textFrame.top
        anchors.bottom: parent.bottom
        width: textFrame.minimumHeight
        anchors.right: parent.right
        highlightColor: "#eeeeee"
        icon: "images/Salvador.png"
        iconHeight: 20*Devices.density
        onContainsMouseChanged: checkPanels()
    }

    ToolKit.MenuPanel {
        id: stickersPanel
        width: 380*Devices.density
        height: 334*Devices.density
        anchors.right: parent.right
        anchors.bottom: parent.top
        transformOrigin: Item.BottomRight
        onContainsMouseChanged: checkPanels()

        delegate: ToolKit.StickersList {
            anchors.fill: parent
            anchors.margins: 8*Devices.density
            engine: msgInput.engine
            radius: 3*Devices.density
            onStickerSelected: messagesModel.sendSticker(document)
        }
    }

    ToolKit.MenuPanel {
        id: emoticonsPanel
        width: 380*Devices.density
        height: 334*Devices.density
        anchors.right: parent.right
        anchors.bottom: parent.top
        transformOrigin: Item.BottomRight
        onContainsMouseChanged: checkPanels()

        delegate: ToolKit.EmojisList {
            anchors.fill: parent
            anchors.margins: 8*Devices.density
            radius: 3*Devices.density
            onEmojiSelected: textFrame.insert(" " + emoji)
        }
    }

    Rectangle {
        id: forward_area
        anchors.fill: parent
        color: parent.color
        visible: false

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: forward()
        }

        Text {
            anchors.centerIn: parent
            font.pixelSize: 11*Devices.fontDensity
            font.bold: true
            color: CutegramGlobals.highlightColors
            text: qsTr("Forward")
        }
    }

    function checkPanels() {
        if(!msgInput.currentPeer) {
            stickersPanel.opened = false
            emoticonsPanel.opened = false
            return
        }

        if(stickersPanel.containsMouse || sticker_btn.containsMouse) {
            stickersPanel.opened = true
            emoticonsPanel.opened = false
        } else {
            Tools.jsDelayCall(300, function(){
                if(!stickersPanel.containsMouse && !sticker_btn.containsMouse)
                    stickersPanel.opened = false
            })
        }

        if(emoticonsPanel.containsMouse || emoji_btn.containsMouse) {
            stickersPanel.opened = false
            emoticonsPanel.opened = true
        } else {
            Tools.jsDelayCall(300, function(){
                if(!emoticonsPanel.containsMouse && !emoji_btn.containsMouse)
                    emoticonsPanel.opened = false
            })
        }
    }

    function reply(peer, message) {
        replyInput.currentPeer = peer
        replyInput.messageId = message.id
    }
}

