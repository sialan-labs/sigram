import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit

AbstractMessage {
    id: photoMsg
    width: column.width
    height: column.height

    property string textMessage: {
        if(media && media.caption.length != 0)
            return media.caption
        else
        if(message && message.message.length != 0)
            return message.message
        else
            return ""
    }

    onCopyRequest: {
        if(message_txt.selectedText.length)
            Devices.clipboard = message_txt.selectedText
        else
            Devices.clipboardUrl = [img.destination]
    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 4*Devices.density

        ToolKit.MessageImage {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            engine: photoMsg.engine
            message: photoMsg.message
            blur: false
            isSticker: (messageType == Telegram.Enums.TypeStickerMessage)
        }

        TextEdit {
            id: message_txt
            anchors.horizontalCenter: parent.horizontalCenter
            width: img.width - photoMsg.margins*2
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
}

