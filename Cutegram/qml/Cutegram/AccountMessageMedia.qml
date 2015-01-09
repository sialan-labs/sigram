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
    property real typeMessageMediaUnsupported: 0x29632a36
    property real typeMessageMediaAudio: 0xc6b68300
    property real typeMessageMediaPhoto: 0xc8c45a2a
    property real typeMessageMediaGeo: 0x56e0d474

    property real typeInputVideoFileLocation: 0x3d0364ec
    property real typeInputEncryptedFileLocation: 0xf5235d55
    property real typeInputFileLocation: 0x14637196
    property real typeInputAudioFileLocation: 0x74dc404d
    property real typeInputDocumentFileLocation: 0x4e45abe9

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
            telegramObject.getFileJustCheck(result)
            break;

        case typeMessageMediaAudio:
            result = telegramObject.locationOfAudio(media.audio)
            telegramObject.getFileJustCheck(result)
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
            result = 168*Devices.density
            break;

        default:
            result = 0
            break;
        }

        return result
    }

    height: {
        var result
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
            result = width
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
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width,height)
        asynchronous: true
        smooth: true
        visible: media.classType != typeMessageMediaVideo

        source: {
            var result
            switch( media.classType )
            {
            case typeMessageMediaPhoto:
                result = media.photo.sizes.last.location.download.location;
                break;

            case typeMessageMediaVideo:
                result = media.video.thumb.location.download.location;
                break;

            case typeMessageMediaAudio:
                result = "files/audio.png"
                break;

            case typeMessageMediaUnsupported:
                result = "files/document.png"
                break;

            case typeMessageMediaDocument:
                result = media.document.thumb.location.download.location
                if(result.length==0)
                    result = "files/document.png"
                break;

            default:
                result = ""
                break;
            }

            return result
        }
    }

    FastBlur {
        anchors.fill: media_img
        source: media_img
        radius: 64
        visible: !media_img.visible
    }

    Rectangle {
        id: download_frame
        anchors.fill: parent
        color: "#88000000"
        visible: fileLocation.length == 0 && media.classType != typeMessageMediaPhoto

        Text {
            anchors.centerIn: parent
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 9*Devices.fontDensity
            color: "#ffffff"
            text: qsTr("Click to Download")
            visible: !indicator.active
        }
    }

    ProgressBar {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4*Devices.density
        height: 3*Devices.density
        topColor: Cutegram.highlightColor
        color: masterPalette.highlightedText
        radius: 0
        percent: 100*locationObj.download.downloaded/locationObj.download.total
        visible: indicator.active
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: download_frame.visible
        modern: true
        indicatorSize: 22*Devices.density
        property bool active: locationObj.download.fileId!=0? locationObj.download.location.length==0 : false

        onActiveChanged: {
            if( active )
                start()
            else
                stop()
        }
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

            case typeMessageMediaUnsupported:
                break;

            default:
                break;
            }
        }
    }
}
