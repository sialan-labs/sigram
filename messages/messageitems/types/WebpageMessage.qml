import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit
import "../../../awesome"

AbstractMessage {
    id: contactMsg
    width: 320*Devices.density
    height: column.height

    onCopyRequest: {
        if(message_txt.selectedText.length)
            Devices.clipboard = message_txt.selectedText
        else
            Devices.clipboard = message.media.webpage.url
    }

    Column {
        id: column
        width: parent.width - 20*Devices.density
        anchors.centerIn: parent
        spacing: 8*Devices.density

        TextEdit {
            id: message_txt
            width: parent.width - 20*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 10*Devices.fontDensity
            clip: true
            selectByMouse: true
            selectionColor: CutegramGlobals.baseColor
            selectedTextColor: "#ffffff"
            textFormat: TextEdit.RichText
            readOnly: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: CutegramGlobals.textAlignment(getText(0, text.length))
            text: {
                if(!message) return ""
                var text = message.media.caption
                if(text.length == 0) text = message.message
                if(text.length == 0) text = message.media.webpage.url
                text = CutegramGlobals.fontHandler.textToHtml(text)
                var emoji = CutegramEmojis.parse(text)
                var link = Linkify.linkify(emoji)
                return link
            }
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Rectangle {
            width: parent.width
            height: 1*Devices.density
            color: "#e8e8e8"
        }

        Row {
            width: parent.width - 20*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8*Devices.density

            Text {
                id: globeTxt
                anchors.verticalCenter: parent.verticalCenter
                font.family: Awesome.family
                font.pixelSize: 20*Devices.fontDensity
                color: "#666666"
                text: Awesome.fa_globe
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - parent.spacing - globeTxt.width
                spacing: 8*Devices.density

                Text {
                    width: parent.width
                    font.pixelSize: 10*Devices.fontDensity
                    font.bold: true
                    color: "#333333"
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 1
                    text: {
                        if(!message) return ""
                        var text = CutegramGlobals.fontHandler.textToHtml(message.media.webpage.title)
                        var emoji = CutegramEmojis.parse(text)
                        return emoji
                    }
                }
            }
        }

        Text {
            width: parent.width - 20*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 10*Devices.fontDensity
            color: "#666666"
            elide: Text.ElideRight
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 5
            text: {
                if(!message) return ""
                var text = CutegramGlobals.fontHandler.textToHtml(message.media.webpage.description)
                var emoji = CutegramEmojis.parse(text)
                return emoji
            }
        }
    }
}

