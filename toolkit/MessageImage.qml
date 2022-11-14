import QtQuick 2.4 as QtQml
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0
import QtGraphicalEffects 1.0

QtQml.Item {
    id: item
    width: {
        var result
        if(isSticker)
            result = stickerWidth
        else
        if(isAnimated)
            result = stickerHeight*img.imageSize.width/img.imageSize.height
        else
        if(img.imageSize.height == 0 || img.imageSize.width == 0) {
            result = minimumWidth
        } else {
            result = img.imageSize.width/img.imageSize.height<maximumRatio?
                        maximumHeight*img.imageSize.width/img.imageSize.height
                      : maximumWidth
            if(result > img.imageSize.width)
                result = img.imageSize.width
        }
        return result
    }
    height: {
        var result
        if(isSticker || isAnimated)
            result = stickerHeight
        else
        if(img.imageSize.height == 0 || img.imageSize.width == 0) {
            result = minimumHeight
        } else {
            result = img.imageSize.width/img.imageSize.height<maximumRatio?
                        maximumHeight
                      : maximumWidth*img.imageSize.height/img.imageSize.width
            if(result > img.imageSize.height)
                result = img.imageSize.height
        }
        return result
    }

    property Message message
    property Engine engine

    property real maximumWidth: 400*Devices.density
    property real maximumHeight: 400*Devices.density
    readonly property real maximumRatio: maximumWidth/maximumHeight

    property real minimumWidth: 40*Devices.density
    property real minimumHeight: 40*Devices.density

    property real stickerWidth: 192*Devices.density
    property real stickerHeight: 192*Devices.density

    property bool isSticker: false
    property bool isAnimated: false
    property bool blur: true

    property alias fillMode: img.fillMode
    readonly property bool imageAvailable: img.currentImage != ""

    property alias downloaded: img.downloaded
    property alias downloading: img.downloading
    property alias downloadedSize: img.downloadedSize
    property alias fileSize: img.fileSize
    readonly property real downloadPercent: (downloadedSize/fileSize)*100
    property alias destination: img.destination

    FastBlur {
        id: blurObj
        anchors.fill: source
        source: img
        radius: 32
        visible: blur && !isSticker && (img.currentImage != img.destination)
    }

    Image {
        id: img
        anchors.fill: parent
        source: item.message
        engine: item.engine
        mipmap: true
        fillMode: 1
        asynchronous: true
        visible: !blurObj.visible

        property bool mediaIsPhoto: (message && message.media.classType == MessageMedia.TypeMessageMediaPhoto)
        onMediaIsPhotoChanged: refresh()
        QtQml.Component.onCompleted: refresh()

        function refresh() {
            if(mediaIsPhoto || isSticker || check())
                download()
        }
    }

    function download() {
        img.download()
    }

    function stop() {
        img.stop()
    }
}

