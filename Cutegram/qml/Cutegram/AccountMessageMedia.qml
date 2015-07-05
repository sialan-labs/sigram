import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: msg_media

    property Message message
    property MessageMedia media: message.media
    property bool hasMedia: file_handler.targetType != FileHandler.TypeTargetUnknown &&
                            file_handler.progressType != FileHandler.TypeProgressUpload

    property real maximumMediaHeight: 300*Devices.density
    property real maximumMediaWidth: width*0.75
    property real maximumMediaRatio: maximumMediaWidth/maximumMediaHeight

    property variant msgDate: CalendarConv.fromTime_t(message.date)
    property alias location: file_handler.filePath

    property alias isSticker: file_handler.isSticker

    property variant mediaPlayer
    property bool mediaPlayerState: file_handler.targetType == FileHandler.TypeTargetMediaAudio
    onMediaPlayerStateChanged: {
        if(mediaPlayerState) {
            if(mediaPlayer)
                mediaPlayer.destroy()
            mediaPlayer = media_player_component.createObject(msg_media)
        } else {
            if(mediaPlayer)
                mediaPlayer.destroy()
            mediaPlayer = 0
        }
    }

    width: {
        var result
        if(mediaPlayer)
            return mediaPlayer.width
        if(file_handler.progressType == FileHandler.TypeProgressUpload)
            return 0

        switch( file_handler.targetType )
        {
        case FileHandler.TypeTargetMediaVideo:
        case FileHandler.TypeTargetMediaPhoto:
            result = file_handler.imageSize.width/file_handler.imageSize.height<maximumMediaRatio?
                        maximumMediaHeight*file_handler.imageSize.width/file_handler.imageSize.height
                      : maximumMediaWidth
            break;

        case FileHandler.TypeTargetUnknown:
        case FileHandler.TypeTargetMediaAudio:
        case FileHandler.TypeTargetMediaDocument:
            result = isSticker? 220*Devices.density : 168*Devices.density
            break;

        case FileHandler.TypeTargetMediaGeoPoint:
            result = mapDownloader.size.width
            break;

        default:
            result = 0
            break;
        }

        return result
    }

    height: {
        var result
        if(mediaPlayer)
            return mediaPlayer.height
        if(file_handler.progressType == FileHandler.TypeProgressUpload)
            return 0

        switch( file_handler.targetType )
        {
        case FileHandler.TypeTargetMediaVideo:
        case FileHandler.TypeTargetMediaPhoto:
            result = file_handler.imageSize.width/file_handler.imageSize.height<maximumMediaRatio?
                        maximumMediaHeight
                      : maximumMediaWidth*file_handler.imageSize.height/file_handler.imageSize.width
            break;

        case FileHandler.TypeTargetUnknown:
        case FileHandler.TypeTargetMediaAudio:
        case FileHandler.TypeTargetMediaDocument:
            result = isSticker? width*media_img.imageSize.height/media_img.imageSize.width : width
            break;

        case FileHandler.TypeTargetMediaGeoPoint:
            result = mapDownloader.size.height
            break;

        default:
            result = 0
            break;
        }

        return result
    }

    property string fileLocation: file_handler.filePath

    FileHandler {
        id: file_handler
        telegram: telegramObject
        target: message
        defaultThumbnail: "files/document.png"
        onTargetTypeChanged: {
            switch(targetType)
            {
            case FileHandler.TypeTargetMediaDocument:
                if(isSticker)
                    download()
                break;

            case FileHandler.TypeTargetMediaPhoto:
                download()
                break;

            case FileHandler.TypeTargetMediaGeoPoint:
                mapDownloader.addToQueue(Qt.point(message.media.geo.lat, message.media.geo.longitude), media_img.setImage )
            }
        }
    }

    Image {
        id: media_img
        anchors.fill: parent
        fillMode: isSticker? Image.PreserveAspectFit : Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        visible: file_handler.targetType == FileHandler.TypeTargetMediaDocument || fileLocation.length != 0

        property size imageSize: Cutegram.imageSize(source)
        property string customImage

        sourceSize: {
            var ratio = imageSize.width/imageSize.height
            if(ratio>1)
                return Qt.size( height*ratio, height)
            else
                return Qt.size( width, width/ratio)
        }

        source: {
            var result = ""
            switch( file_handler.targetType )
            {
            case FileHandler.TypeTargetMediaPhoto:
                result = fileLocation
                if(result.length==0 && file_handler.thumbPath != file_handler.defaultThumbnail)
                    result = file_handler.thumbPath
                break;

            case FileHandler.TypeTargetMediaVideo:
                result = file_handler.thumbPath
                break;

            case FileHandler.TypeTargetUnknown:
            case FileHandler.TypeTargetMediaAudio:
                break;

            case FileHandler.TypeTargetMediaDocument:
                if(isSticker) {
                    result = fileLocation
                    if(result.length==0)
                        result = file_handler.thumbPath
                }
                else
                if(Cutegram.filsIsImage(file_handler.filePath))
                    result = fileLocation
                else
                    result = file_handler.thumbPath
                break;

            case FileHandler.TypeTargetMediaGeoPoint:
                result = customImage
                break;
            }

            return result
        }

        function setImage(img) {
            customImage = img
        }
    }

    FastBlur {
        anchors.fill: media_img
        source: media_img
        radius: 32
        visible: !media_img.visible
    }

    Rectangle {
        id: video_frame
        color: "#44000000"
        visible: file_handler.targetType == FileHandler.TypeTargetMediaVideo && fileLocation.length != 0
        anchors.fill: media_img

        Image {
            width: 92*Devices.density
            height: width
            sourceSize: Qt.size(width,height)
            source: video_frame.visible? "files/play.png" : ""
            anchors.centerIn: parent
        }
    }

    Rectangle {
        id: download_frame
        anchors.fill: parent
        color: "#88000000"
        visible: fileLocation.length == 0 && file_handler.targetType != FileHandler.TypeTargetMediaPhoto && !isSticker && file_handler.targetType != FileHandler.TypeTargetMediaGeoPoint
        radius: 3*Devices.density

        Text {
            anchors.centerIn: parent
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            color: "#ffffff"
            text: file_handler.targetType == FileHandler.TypeTargetUnknown? qsTr("Unsupported Media") : qsTr("Click to Download")
            visible: !indicator.active
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8*Devices.density
            anchors.left: parent.left
            anchors.margins: 2*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            color: "#ffffff"
            text: {
                if(indicator.active)
                    return Math.floor(file_handler.progressCurrentByte/(1024*10.24))/100 + "MB/" +
                           Math.floor(size/(1024*10.24))/100 + "MB"
                else
                    Math.floor(size/(1024*10.24))/100 + "MB"
            }

            property int size: file_handler.fileSize
        }
    }

    ProgressBar {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4*Devices.density
        height: 3*Devices.density
        topColor: Cutegram.currentTheme.masterColor
        color: masterPalette.highlightedText
        radius: 0
        percent: file_handler.progressPercent
        visible: indicator.active
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: !isSticker
        modern: true
        indicatorSize: 22*Devices.density
        property bool active: file_handler.progressType != FileHandler.TypeProgressEmpty

        onActiveChanged: {
            if( active )
                start()
            else
                stop()
        }
    }

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        source: file_handler.targetType == FileHandler.TypeTargetMediaOther? "files/map-pin.png" : ""
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectFit
        width: 92*Devices.density
        height: 92*Devices.density
        visible: file_handler.targetType == FileHandler.TypeTargetMediaOther
        asynchronous: true
        smooth: true
    }

    Button {
        anchors.top: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20*Devices.density
        textFont.family: AsemanApp.globalFont.family
        textFont.pixelSize: Math.floor(9*Devices.fontDensity)
        highlightColor: Qt.darker(normalColor)
        normalColor: "#C81414"
        textColor: "#ffffff"
        height: 36*Devices.density
        width: 2*height
        text: qsTr("Cancel")
        radius: 4*Devices.density
        cursorShape: Qt.PointingHandCursor
        visible: indicator.active && file_handler.targetType != FileHandler.TypeTargetMediaPhoto && !isSticker
        onClicked: file_handler.cancelProgress()
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 2*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(9*Devices.fontDensity)
        wrapMode: Text.WrapAnywhere
        elide: Text.ElideRight
        color: "#ffffff"
        text: file_handler.fileName
        visible: !file_handler.isSticker
    }

    function click() {
        if( fileLocation.length != 0 )
            Qt.openUrlExternally(fileLocation)
        else
        {
            switch( file_handler.targetType )
            {
            case FileHandler.TypeTargetMediaVideo:
            case FileHandler.TypeTargetMediaPhoto:
            case FileHandler.TypeTargetMediaDocument:
            case FileHandler.TypeTargetMediaAudio:
                file_handler.download()
                break;

            case FileHandler.TypeTargetMediaGeoPoint:
                Qt.openUrlExternally( mapDownloader.webLinkOf(Qt.point(media.geo.lat, media.geo.longitude)) )
                break;

            case FileHandler.TypeTargetUnknown:
            default:
                return false
                break;
            }
        }

        return true
    }

    Component {
        id: media_player_component
        MediaPlayerItem {
            width: 180*Devices.density
            height: 40*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            filePath: fileLocation
            z: fileLocation.length == 0? -1 : 0

            MouseArea {
                anchors.fill: parent
                visible: fileLocation.length == 0
                onClicked: msg_media.click()
            }
        }
    }
}
