import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit
import "../../../awesome"

AbstractMessage {
    id: photoMsg
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

    onClickRequest: if(img.downloaded) engine.openFile(img.destination)

    onCopyRequest: {
        if(message_txt.selectedText.length)
            Devices.clipboard = message_txt.selectedText
        else
            Devices.clipboardUrl = [img.destination]
    }

    onUploadingChanged: if(!uploading) img.download()

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 4*Devices.density

        ToolKit.MessageImage {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            engine: photoMsg.engine
            message: photoMsg.message
            maximumWidth: photoMsg.maximumWidth
            maximumHeight: photoMsg.maximumHeight

            Rectangle {
                anchors.fill: parent
                color: "#66000000"
                visible: !img.downloaded

                Button {
                    anchors.centerIn: parent
                    width: 64*Devices.density
                    height: width
                    highlightColor: "#88000000"
                    hoverColor: "#66000000"
                    radius: 3*Devices.density
                    textColor: img.downloading? "#db2424" : "#ffffff"
                    textFont.family: Awesome.family
                    textFont.pixelSize: 25*Devices.fontDensity
                    text: {
                        if(img.downloaded) ""
                        if(img.downloading) return Awesome.fa_remove
                        return Awesome.fa_download
                    }
                    onClicked: {
                        if(img.downloading) img.stop()
                        else
                            img.download()
                    }
                }

                ProgressBar {
                    width: parent.width
                    radius: 0
                    height: 3*Devices.density
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 35*Devices.density
                    color: "#ffffff"
                    topColor: CutegramGlobals.highlightColors
                    percent: 100*photoMsg.transfaredSize/photoMsg.totalSize
                    visible: photoMsg.transfaring
                }
            }
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

