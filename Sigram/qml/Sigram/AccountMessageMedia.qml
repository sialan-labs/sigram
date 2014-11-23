import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: msg_media

    property MessageMedia media
    property bool hasMedia: media.classType != typeMessageMediaEmpty

    property real maximumMediaHeight: 300*physicalPlatformScale
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

    property FileLocation locationObj

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
        case typeMessageMediaDocument:
            result = 168*physicalPlatformScale
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
        case typeMessageMediaDocument:
            result = width
            break;

        default:
            result = 0
            break;
        }

        return result
    }

    property string fileLocation: {
        var result = ""
        switch( media.classType )
        {
        case typeMessageMediaPhoto:
            result = media.photo.sizes.last.location.download.location;
            break;

        case typeMessageMediaVideo:
        case typeMessageMediaDocument:
        case typeMessageMediaAudio:
            result = locationObj && locationObj.download? locationObj.download.location : ""
            break;

        case typeMessageMediaUnsupported:
        default:
            result = ""
            break;
        }

        return result
    }

    Image {
        id: media_img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width,height)
        asynchronous: true
        smooth: true
        visible: media.classType != typeMessageMediaVideo

        source:  {
            var result
            switch( media.classType )
            {
            case typeMessageMediaPhoto:
                result = media.photo.sizes.last.location.download.location;
                break;

            case typeMessageMediaVideo:
                result = media.video.thumb.location.download.location;
                break;

            case typeMessageMediaUnsupported:
                result = "files/document.png"
                break;

            case typeMessageMediaDocument:
                result = media.document.thumb.location.download.location
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

    Indicator {
        anchors.centerIn: parent
        light: false
        modern: true
        indicatorSize: 22*physicalPlatformScale
        property bool active: {
            var result
            switch( media.classType )
            {
            case typeMessageMediaPhoto:
            case typeMessageMediaVideo:
            case typeMessageMediaUnsupported:
            case typeMessageMediaDocument:
                result = media_img.status != Image.Ready
                break;

            case typeMessageMediaPhoto:
            default:
                result = false
                break;
            }

            return result
        }

        onActiveChanged: {
            if( active )
                start()
            else
                stop()
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if( fileLocation.length != 0 )
                Qt.openUrlExternally(fileLocation)
            else
            {
                switch( media.classType )
                {
                case typeMessageMediaPhoto:
                    telegramObject.getFile(media.photo.sizes.last.location)
                    break;

//                case typeMessageMediaVideo:
//                    locationObj = telegramObject.locationOf(media.video.accessHash)
//                    telegramObject.getFile(locationObj)
//                    break;

//                case typeMessageMediaDocument:
//                    locationObj = telegramObject.locationOf(media.document.accessHash)
//                    telegramObject.getFile(locationObj)
//                    break;

//                case typeMessageMediaAudio:
//                    locationObj = telegramObject.locationOf(media.audio.accessHash)
//                    telegramObject.getFile(locationObj)
//                    break;

                case typeMessageMediaUnsupported:
                    break;

                default:
                    break;
                }
            }
        }
    }
}
