import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    height: flick.height

    property real minimumHeight: 44*Devices.density
    property real maximumHeight: 150*Devices.density

    property Engine engine
    property InputPeer currentPeer
    property MessageListModel messagesModel

    property alias text: txt.text
    property alias split: splitCheck.checked

    onCurrentPeerChanged: {
        if(cache.lastPeer)
            cache.insert(cache.lastPeer, txt.text)

        txt.text = ""
        if(cache.contains(currentPeer)) {
            txt.text = cache.value(currentPeer)
            txt.cursorPosition = txt.length
        }
        txt.forceActiveFocus()
        cache.lastPeer = currentPeer
    }

    signal sendMessage(string text)

    HashObject {
        id: cache
        property InputPeer lastPeer
    }

    Flickable {
        id: flick
        width: parent.width - (splitCheck.visible? splitCheck.width : 0)
        height: {
            var res = txt_frame.height
            if(res > maximumHeight)
                res = maximumHeight
            return res
        }
        clip: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: txt_frame.height
        contentWidth: txt_frame.width

        function ensureVisible(r)
        {
            if(txt_frame.height <= maximumHeight)
                return

            var ry = r.y + 10*Devices.density
            var rx = r.x
            var rheight = r.height + 10*Devices.density
            var rwidth = r.width

            if (contentX >= rx)
                contentX = rx;
            else if (contentX+width <= rx+rwidth)
                contentX = rx+rwidth-width;
            if (contentY >= ry)
                contentY = ry;
            else if (contentY+height <= ry+rheight)
                contentY = ry+rheight-height;
        }

        Item {
            id: txt_frame
            width: flick.width
            height: {
                var res = txt.height + 20*Devices.density
                if(res < minimumHeight)
                    res = minimumHeight
                return res
            }

            TextEdit {
                id: txt
                width: parent.width - 20*Devices.density
                anchors.centerIn: parent
                font.pixelSize: 10*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: "#111111"
                clip: true
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                readOnly: !messagesModel || (messagesModel.currentPeer == null) ||
                          !messagesModel.editable

                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                Keys.onPressed: {
                    if (event.modifiers == Qt.NoModifier) {
                        switch(event.key) {
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                            sendMessage(txt.text.trim())
                            txt.text = ""
                            event.accepted = true
                            break;
                        }
                    }
                    else
                    if(event.modifiers == Qt.ShiftModifier)
                    {
                        switch(event.key) {
                        case 8204:
                            if(txt.selectedText.length!=0)
                                txt.remove(txt.selectionStart, txt.selectionEnd)

                            var npos = txt.cursorPosition+1
                            txt.insert(txt.cursorPosition,"‌") //! Persian mid space character. you can't see it
                            txt.cursorPosition = npos

                            event.accepted = true
                            break;
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    text: qsTr("Your message...")
                    color: "#888888"
                    font: parent.font
                    visible: parent.text.length == 0
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onPressed: {
            txt.forceActiveFocus()
            mouse.accepted = false
        }
    }

    ToolKit.CheckBox {
        id: splitCheck
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        textFont.pixelSize: 10*Devices.fontDensity
        visible: txt.text.indexOf("\n\n") != -1
        text: qsTr("Split message")
    }

    function insert(emoji) {
        if(txt.selectedText.length)
            txt.remove(txt.selectionStart, txt.selectionEnd)
        txt.insert(txt.cursorPosition, emoji)
    }
}

