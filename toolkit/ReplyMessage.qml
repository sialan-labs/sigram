import QtQuick 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0
import "../globals"

Rectangle {
    id: item
    width: column.width*column.scale + 2*margins
    height: column.height*column.scale + 2*margins
    radius: CutegramSettings.messageItemRadius

    property Message message
    property User user
    property Chat chat
    property Engine engine
    property int mediaType: -1

    property color fontsColor
    property real maximumWidth: 150*Devices.density
    property real margins: 8*Devices.density

    signal focusRequest(variant message)

    readonly property string text: {
        if(!message) return ""

        var media = ""
        switch(mediaType) {
        case Enums.TypeTextMessage:
            break
        case Enums.TypeDocumentMessage:
            media = qsTr("Document")
            break
        case Enums.TypeVideoMessage:
            media = qsTr("Video")
            break
        case Enums.TypeAudioMessage:
            media = qsTr("Audio")
            break
        case Enums.TypeVenueMessage:
            media = qsTr("Venue")
            break
        case Enums.TypeWebPageMessage:
            media = qsTr("WebPage")
            break
        case Enums.TypeGeoMessage:
            media = qsTr("Geo")
            break
        case Enums.TypeContactMessage:
            media = qsTr("Contact")
            break
        case Enums.TypeActionMessage:
            media = qsTr("Action")
            break
        case Enums.TypePhotoMessage:
            media = qsTr("Photo")
            break
        case Enums.TypeStickerMessage:
            media = qsTr("Sticker")
            break
        case Enums.TypeAnimatedMessage:
            media = qsTr("Animated")
            break
        case Enums.TypeUnsupportedMessage:
            break
        }

        var text = ""
        if(message.message.length != 0) text = message.message
        else
        if(message.media.caption.length != 0) text = message.media.caption

        if(media.length == 0 && text.length != 0)
            return text
        if(media.length != 0 && text.length == 0)
            return "[%1]".arg(media)
        if(media.length != 0 && text.length != 0)
            return "[%1]\n%2".arg(media).arg(text)
        return ""
    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 4*Devices.density
        scale: 0.9

        Text {
            font.pixelSize: 11*Devices.fontDensity
            color: fontsColor
            text: {
                if(user) return (user.firstName + " " + user.lastName).trim()
                if(chat) return chat.title
                return ""
            }
        }

        Text {
            width: {
                var res = TextTools.htmlWidth(text)
                if(res > maximumWidth - 2*margins)
                    res = maximumWidth - 2*margins
                return res
            }
            font.pixelSize: 9*Devices.fontDensity
            color: fontsColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            clip: true
            textFormat: Text.StyledText
            text: {
                var text = CutegramGlobals.fontHandler.textToHtml(item.text)
                text = CutegramEmojis.parse(text)
                return text
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: focusRequest(message)
    }
}

