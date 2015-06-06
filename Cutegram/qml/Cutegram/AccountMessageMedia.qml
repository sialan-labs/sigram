import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: msg_media

    property MessageMedia media
    property bool hasMedia: media.classType != typeMessageMediaEmpty

    property real maximumMediaHeight: 300*Devices.density
    property real maximumMediaWidth: width*0.75
    property real maximumMediaRatio: maximumMediaWidth/maximumMediaHeight

    property variant msgDate: CalendarConv.fromTime_t(message.date)

    property real typeMessageMediaDocument: 0x2fda2204
    property real typeMessageMediaContact: 0x5e7d2f39
    property real typeMessageMediaEmpty: 0x3ded6320
    property real typeMessageMediaVideo: 0xa2d24290
    property real typeMessageMediaUnsupported: 0x9f84f49e
    property real typeMessageMediaAudio: 0xc6b68300
    property real typeMessageMediaPhoto: 0xc8c45a2a
    property real typeMessageMediaGeo: 0x56e0d474

    property real typeInputVideoFileLocation: 0x3d0364ec
    property real typeInputEncryptedFileLocation: 0xf5235d55
    property real typeInputFileLocation: 0x14637196
    property real typeInputAudioFileLocation: 0x74dc404d
    property real typeInputDocumentFileLocation: 0x4e45abe9

    property bool isSticker: media.classType == typeMessageMediaDocument? telegramObject.documentIsSticker(media.document) : false

    property variant mediaPlayer
    property bool mediaPlayerState: media.classType == typeMessageMediaAudio
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

    property FileLocation locationObj: {
        var result
        switch( media.classType )
        {
        case typeMessageMediaPhoto:
            result = media.photo.sizes.last.location
            break;

        case typeMessageMediaVideo:
            result = telegramObject.locationOfVideo(media.video)
            telegramObject.getFileJustCheck(result)
            break;

        case typeMessageMediaDocument:
            result = telegramObject.locationOfDocument(media.document)
            if(isSticker)
                telegramObject.getFile(result, typeInputDocumentFileLocation, media.document.size)
            else
                telegramObject.getFileJustCheck(result)
            break;

        case typeMessageMediaAudio:
            result = telegramObject.locationOfAudio(media.audio)
            telegramObject.getFileJustCheck(result)
            break;

        case typeMessageMediaGeo:
            mapDownloader.addToQueue(Qt.point(media.geo.lat, media.geo.longitude), media_img.setImage)
            result = telegramObject.nullLocation
            break;

        case typeMessageMediaUnsupported:
        default:
            result = telegramObject.nullLocation
            break;
        }

        return result
    }

    onHasMediaChanged: {
        if( !hasMedia )
            return

        switch( media.classType )
        {
        case typeMessageMediaPhoto:
            telegramObject.getFile(media.photo.sizes.last.location)
            break;

        case typeMessageMediaVideo:
            telegramObject.getFile(media.video.thumb.location)
            break;

        case typeMessageMediaDocument:
            telegramObject.getFile(media.document.thumb.location)
            break;

        default:
            break;
        }
    }

    width: {
        var result
        if(mediaPlayer)
            return mediaPlayer.width

        switch( media.classType )
        {
        case typeMessageMediaPhoto:
            result = media.photo.sizes.last.w/media.photo.sizes.last.h<maximumMediaRatio?
                        maximumMediaHeight*media.photo.sizes.last.w/media.photo.sizes.last.h
                      : maximumMediaWidth
            break;

        case typeMessageMediaVideo:
            result = media.video.w/media.video.h<maximumMediaRatio?
                        maximumMediaHeight*media.video.w/media.video.h
                      : maximumMediaWidth
            break;

        case typeMessageMediaUnsupported:
        case typeMessageMediaAudio:
        case typeMessageMediaDocument:
            result = isSticker? 220*Devices.density : 168*Devices.density
            break;

        case typeMessageMediaGeo:
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

        switch( media.classType )
        {
        case typeMessageMediaPhoto:
            result = media.photo.sizes.last.w/media.photo.sizes.last.h<maximumMediaRatio?
                        maximumMediaHeight
                      : maximumMediaWidth*media.photo.sizes.last.h/media.photo.sizes.last.w
            break;

        case typeMessageMediaVideo:
            result = media.video.w/media.video.h<maximumMediaRatio?
                        maximumMediaHeight
                      : maximumMediaWidth*media.video.h/media.video.w
            break;

        case typeMessageMediaUnsupported:
        case typeMessageMediaAudio:
        case typeMessageMediaDocument:
            result = isSticker? width*media_img.imageSize.height/media_img.imageSize.width : width
            break;

        case typeMessageMediaGeo:
            result = mapDownloader.size.height
            break;

        default:
            result = 0
            break;
        }

        return result
    }

    property string fileLocation: locationObj.download.location

    Image {
        id: media_img
        anchors.fill: parent
        fillMode: isSticker? Image.PreserveAspectFit : Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        visible: media.classType != typeMessageMediaVideo || fileLocation.length != 0

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
            var result
            if(mediaPlayer)
                return ""

            switch( media.classType )
            {
            case typeMessageMediaPhoto:
                result = media.photo.sizes.last.location.download.location;
                break;

            case typeMessageMediaVideo:
                if(fileLocation.length != 0)
                    result = telegramObject.videoThumbLocation(fileLocation)
                else
                    result = media.video.thumb.location.download.location;
                break;

            case typeMessageMediaAudio:
                result = "files/audio.png"
                break;

            case typeMessageMediaUnsupported:
                result = "files/document.png"
                break;

            case typeMessageMediaDocument:
                if(isSticker) {
                    result = locationObj.download.location
                    if(result.length==0)
                        result = media.document.thumb.location.download.location
                    if(result.length==0)
                        result = ""
                }
                else
                if(Cutegram.filsIsImage(fileLocation))
                    result = fileLocation
                else {
                    result = media.document.thumb.location.download.location
                    if(result.length==0)
                        result = "files/document.png"
                }
                break;

            case typeMessageMediaGeo:
                result = customImage
                break;

            default:
                result = ""
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
        radius: 64
        visible: !media_img.visible
    }

    Rectangle {
        id: video_frame
        color: "#44000000"
        visible: media.classType == typeMessageMediaVideo && fileLocation.length != 0
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
        visible: fileLocation.length == 0 && media.classType != typeMessageMediaPhoto && !isSticker && media.classType != typeMessageMediaGeo
        radius: 3*Devices.density

        Text {
            anchors.centerIn: parent
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            color: "#ffffff"
            text: media.classType==typeMessageMediaUnsupported? qsTr("Unsupported Media") : qsTr("Click to Download")
            visible: !indicator.active
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 2*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            color: "#ffffff"
            text: {
                if(indicator.active)
                    return Math.floor(locationObj.download.downloaded/(1024*10.24))/100 + "MB/" +
                           Math.floor(size/(1024*10.24))/100 + "MB"
                else
                    Math.floor(size/(1024*10.24))/100 + "MB"
            }

            property int size: {
                var result = 0
                switch( media.classType )
                {
                case typeMessageMediaPhoto:
                    break;

                case typeMessageMediaVideo:
                    result = media.video.size
                    break;

                case typeMessageMediaDocument:
                    result = media.document.size
                    break;

                case typeMessageMediaAudio:
                    result = media.audio.size
                    break;

                case typeMessageMediaUnsupported:
                    break;

                default:
                    break;
                }

                return result
            }
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
        percent: 100*locationObj.download.downloaded/locationObj.download.total
        visible: indicator.active
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: !isSticker
        modern: true
        indicatorSize: 22*Devices.density
        property bool active: locationObj.download.fileId!=0? fileLocation.length==0 : false

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
        source: media.classType == typeMessageMediaGeo? "files/map-pin.png" : ""
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectFit
        width: 92*Devices.density
        height: 92*Devices.density
        visible: media.classType == typeMessageMediaGeo
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
        visible: indicator.active && media.classType != typeMessageMediaPhoto && !isSticker
        onClicked: telegramObject.cancelDownload(locationObj.download)
    }

    function click() {
        if( fileLocation.length != 0 )
            Qt.openUrlExternally(fileLocation)
        else
        {
            switch( media.classType )
            {
            case typeMessageMediaPhoto:
                telegramObject.getFile(locationObj)
                break;

            case typeMessageMediaVideo:
                telegramObject.getFile(locationObj, typeInputVideoFileLocation, media.video.size)
                break;

            case typeMessageMediaDocument:
                telegramObject.getFile(locationObj, typeInputDocumentFileLocation, media.document.size)
                break;

            case typeMessageMediaAudio:
                telegramObject.getFile(locationObj, typeInputAudioFileLocation, media.audio.size)
                break;

            case typeMessageMediaGeo:
                Qt.openUrlExternally( mapDownloader.webLinkOf(Qt.point(media.geo.lat, media.geo.longitude)) )
                break;

            case typeMessageMediaUnsupported:
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
