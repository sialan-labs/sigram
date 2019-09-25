import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import QtPositioning 5.2
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit
import "../../../awesome"

AbstractMessage {
    id: geoMsg
    width: column.width
    height: column.height

    readonly property string textMessage: {
        if(media && media.caption.length != 0)
            return media.caption
        else
        if(message && message.message.length != 0)
            return message.message
        else
            return ""
    }

//    onClickRequest: if(img.downloaded) Qt.openUrlExternally( mapDownloader.webLinkOf(mapDownloader.point) )

    onCopyRequest: {
        if(message_txt.selectedText.length)
            Devices.clipboard = message_txt.selectedText
        else
            Devices.clipboardUrl = [img.source]
    }

//    MapDownloader {
//        id: mapDownloader
//        destination: engine.configDirectory + "/downloads"
//        size: Qt.size(img.width, img.height)

//        property point point: {
//            if(!message) return Qt.point(0, 0)
//            var latitude = message.media.geo.lat
//            var longitude = message.media.geo.longValue
//            return Qt.point(latitude, longitude)
//        }

//        onPointChanged: mapDownloader.download(point)
//    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 4*Devices.density

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300*Devices.density
            height: 220*Devices.density
//            source: mapDownloader.image

            Image {
                width: 64*Devices.density
                height: width
                sourceSize: Qt.size(width, height)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                source: "icons/map-pin.png"
            }

            Text {
                font.family: Awesome.family
                font.pixelSize: 30*Devices.density
                color: "#db2424"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                text: Awesome.fa_map_pin
                visible: false
            }
        }

        TextEdit {
            id: message_txt
            anchors.horizontalCenter: parent.horizontalCenter
            width: img.width - geoMsg.margins*2
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

