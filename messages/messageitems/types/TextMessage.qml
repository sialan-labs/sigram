import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"

AbstractMessage {
    id: msgItem
    width: message_txt.width + 2*margins
    height: message_txt.height

    property string textMessage: message? message.message : ""

    onCopyRequest: {
        if(message_txt.selectedText.length)
            Devices.clipboard = message_txt.selectedText
        else
            Devices.clipboard = textMessage
    }

    TextEdit {
        id: message_txt
        anchors.centerIn: parent
        width: {
            var res = TextTools.htmlWidth(text)
            if(res > msgItem.maximumWidth - 2*margins)
                res = msgItem.maximumWidth - 2*margins
            return res
        }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: CutegramGlobals.textAlignment(getText(0, length))
        font.pixelSize: 10*Devices.fontDensity
        color: "#111111"
        clip: true
        selectByMouse: true
        selectionColor: CutegramGlobals.baseColor
        selectedTextColor: "#ffffff"
        textFormat: TextEdit.RichText
        readOnly: true
        visible: textMessage.length != 0
        text: {
            var text = CutegramGlobals.fontHandler.textToHtml(textMessage)
            var emoji = CutegramEmojis.parse(text)
            var link = Linkify.linkify(emoji)
            return link
        }
        onLinkActivated: {
            Qt.openUrlExternally(link)
        }
    }
}

