import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit
import "../../../awesome"

AbstractMessage {
    id: docMsg
    width: {
        var res = 356*Devices.density
        if(res > maximumWidth)
            res = maximumWidth
        return res
    }
    height: column.height

    property string fileName
    property string fileMimeType
    property int fileDuration
    property int fileSize

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

    Column {
        id: column
        width: parent.width
        anchors.centerIn: parent
        spacing: 4*Devices.density

        Item {
            width: parent.width
            height: 92*Devices.density

            ToolKit.MessageImage {
                id: img
                x: y
                anchors.verticalCenter: parent.verticalCenter
                width: 64*Devices.density
                height: width
                engine: docMsg.engine
                message: docMsg.message
                fillMode: 2
                blur: false

                Text {
                    anchors.centerIn: parent
                    color: "#555555"
                    font.pixelSize: 35*Devices.fontDensity
                    font.family: Awesome.family
                    text: Awesome.fa_paperclip
                    visible: !img.imageAvailable
                }
            }

            Item {
                anchors.left: img.right
                anchors.top: img.top
                anchors.bottom: img.bottom
                anchors.right: downloadBtn.left
                anchors.leftMargin: 8*Devices.density

                Text {
                    id: fileNameText
                    width: parent.width
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#333333"
                    text: docMsg.fileName
                }

                Text {
                    id: mimeTxt
                    width: parent.width
                    anchors.top: fileNameText.bottom
                    anchors.topMargin: 6*Devices.density
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#666666"
                    text: docMsg.fileMimeType
                }

                Item {
                    width: parent.width
                    anchors.top: mimeTxt.bottom
                    anchors.bottom: sizeTxt.top

                    ProgressBar {
                        width: parent.width
                        radius: 0
                        height: 3*Devices.density
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#00000000"
                        topColor: CutegramGlobals.highlightColors
                        percent: 100*docMsg.transfaredSize/docMsg.totalSize
                        visible: docMsg.transfaring
                    }
                }

                Text {
                    id: sizeTxt
                    width: parent.width
                    anchors.bottom: parent.bottom
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#666666"
                    text: {
                        if(docMsg.transfaring) return ("%1/%2").arg(trSize(docMsg.transfaredSize)).arg(trSize(docMsg.totalSize))
                        return trSize(img.fileSize)
                    }

                    function trSize(size){
                        var res = size
                        if(res < 1000)
                            return res + "B"
                        if(res < 1000*1000)
                            return Math.floor(10*res/1000)/10 + "KB"
                        if(res < 1000*1000*1000)
                            return Math.floor(10*res/(1000*1000))/10 + "MB"
                        if(res < 1000*1000*1000*1000)
                            return Math.floor(10*res/(1000*1000*1000))/10 + "GB"
                        return res
                    }
                }
            }

            Button {
                id: downloadBtn
                anchors.right: parent.right
                anchors.rightMargin: y
                anchors.verticalCenter: parent.verticalCenter
                width: img.width
                height: width
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                radius: 3*Devices.density
                textColor: img.downloading? "#db2424" : "#888888"
                textFont.family: Awesome.family
                textFont.pixelSize: 25*Devices.fontDensity
                text: {
                    if(img.downloaded) return Awesome.fa_ellipsis_v
                    if(img.downloading) return Awesome.fa_remove
                    return Awesome.fa_download
                }
                onClicked: {
                    if(img.downloaded) Qt.openUrlExternally(img.destination)
                    else
                    if(img.downloading) img.stop()
                    else
                        img.download()
                }
            }
        }

        TextEdit {
            id: message_txt
            anchors.horizontalCenter: parent.horizontalCenter
            width: column.width - docMsg.margins*2
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

