import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    width: isSticker? 220*Devices.density : height
    height: 200*Devices.density
    visible: uploading

    property Telegram telegram
    property Message message: telegram.nullMessage

    property bool uploading: message.upload.fileId != 0
    property bool isSticker: telegram.documentIsSticker(message.media.document)

    Image {
        id: upload_img
        visible: uploading
        anchors.fill: parent
        smooth: true
        fillMode: isSticker? Image.PreserveAspectFit : Image.PreserveAspectCrop
        source: {
            if(!uploading)
                return ""

            var isImage = Cutegram.filsIsImage(message.upload.location)
            if(isImage)
                return Devices.localFilesPrePath + message.upload.location
            else
                return "files/document.png"
        }

        sourceSize: {
            var ratio = imageSize.width/imageSize.height
            if(ratio>1)
                return Qt.size( height*ratio, height)
            else
                return Qt.size( width, width/ratio)
        }

        property size imageSize: uploading? Cutegram.imageSize(message.upload.location) : Qt.size(0,0)
    }

    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 2*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(9*Devices.fontDensity)
        color: "#333333"
        text: uploadedSize + "/" + totalSize

        property string totalSize: Math.floor(message.upload.totalSize/(1024*10.24))/100 + "MB"
        property string uploadedSize: Math.floor(message.upload.uploaded/(1024*10.24))/100 + "MB"
    }

    Text {
        id: file_txt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: pbar.top
        anchors.margins: 2*Devices.density
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        elide: Text.ElideRight
        maximumLineCount: 1
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(9*Devices.fontDensity)
        color: "#333333"
        text: Tools.fileName(message.upload.location)
    }

    ProgressBar {
        id: pbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4*Devices.density
        height: 3*Devices.density
        topColor: Cutegram.currentTheme.masterColor
        color: masterPalette.highlightedText
        radius: 0
        percent: 100*message.upload.uploaded/message.upload.totalSize
    }
}

