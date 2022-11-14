import QtQuick 2.4
import QtMultimedia 5.5
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"
import "../../../toolkit" as ToolKit
import "../../../awesome"

AbstractMessage {
    id: animMsg
    width: column.width
    height: column.height

    property int fileDuration

    onCopyRequest: {
        if(message_txt.selectedText.length)
            Devices.clipboard = message_txt.selectedText
        else
            Devices.clipboardUrl = [img.destination]
    }

    readonly property string textMessage: {
        if(media && media.caption.length != 0)
            return media.caption
        else
        if(message && message.message.length != 0)
            return message.message
        else
            return ""
    }

    onClickRequest: if(img.downloaded) Qt.openUrlExternally(img.destination)

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 4*Devices.density

        ToolKit.MessageImage {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            engine: animMsg.engine
            message: animMsg.message
            maximumWidth: animMsg.maximumWidth
            maximumHeight: animMsg.maximumHeight
            blur: !img.downloaded

            Video {
                id: video
                anchors.fill: parent
                source: img.destination
                onStopped: play()
            }

            Rectangle {
                anchors.fill: parent
                color: img.blur? "#66000000" : "#00000000"

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
                    visible: video.playbackState != MediaPlayer.PlayingState
                    text: {
                        if(img.downloaded) return Awesome.fa_play
                        if(img.downloading) return Awesome.fa_remove
                        return Awesome.fa_download
                    }
                    onClicked: {
                        if(img.downloaded) video.play()
                        else
                        if(img.downloading) img.stop()
                        else img.download()
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
                    percent: 100*animMsg.transfaredSize/animMsg.totalSize
                    visible: animMsg.transfaring
                }

                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 14*Devices.density
                    color: "#ffffff"
                    font.family: 10*Devices.fontDensity
                    text: {
                        var time = getTimeString(fileDuration)
                        if(animMsg.transfaring) {
                            var fileSize = ("%1/%2").arg(trSize(animMsg.transfaredSize)).arg(trSize(animMsg.totalSize))
                            time = fileSize + ", " + time
                        }

                        return time
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
                    function getTimeString(duration) {
                        var hours = Math.floor(duration/3600)
                        if(hours < 10) hours = "0" + hours
                        var minutes = Math.floor(duration/60)%60
                        if(minutes < 10) minutes = "0" + minutes
                        var seconds = duration%60
                        if(seconds < 10) seconds = "0" + seconds
                        if(hours == "00")
                            return minutes + ":" + seconds
                        else
                            return hours + ":" + minutes + ":" + seconds
                    }
                }
            }
        }

        TextEdit {
            id: message_txt
            anchors.horizontalCenter: parent.horizontalCenter
            width: img.width - animMsg.margins*2
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

