import QtQuick 2.4
import TelegramQml 2.0 as Telegram

AbstractMessage {
    id: autoMsg
    width: msgItem? msgItem.width : 0
    height: msgItem? msgItem.height : 0

    property AbstractMessage msgItem

    property string fileName
    property string fileMimeType
    property string fileTitle
    property string filePerformer
    property int fileDuration
    property bool fileIsVoice
    property int fileSize


    onClickRequest: if(msgItem) msgItem.clickRequest()
    onCopyRequest: if(msgItem) msgItem.copyRequest()

    onMessageTypeChanged: {
        if(msgItem)
            msgItem.destroy()

        switch(messageType) {
        case Telegram.Enums.TypeTextMessage:
            msgItem = message_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypePhotoMessage:
            msgItem = photo_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeDocumentMessage:
            msgItem = document_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeStickerMessage:
            msgItem = sticker_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeVideoMessage:
            msgItem = video_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeAudioMessage:
            msgItem = audio_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeAnimatedMessage:
            msgItem = animated_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeContactMessage:
            msgItem = contact_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeWebPageMessage:
            msgItem = webpage_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeVenueMessage:
        case Telegram.Enums.TypeGeoMessage:
            msgItem = geo_component.createObject(autoMsg)
            break;
        case Telegram.Enums.TypeActionMessage:
            msgItem = action_component.createObject(autoMsg)
            break
        case Telegram.Enums.TypeUnsupportedMessage:
        default:
            msgItem = unsupport_component.createObject(autoMsg)
            break
        }
    }

    Component {
        id: message_component
        TextMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth*0.8
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: photo_component
        PhotoMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: geo_component
        GeoMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: webpage_component
        WebpageMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: video_component
        VideoMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            fileDuration: autoMsg.fileDuration
            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: animated_component
        AnimatedMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            fileDuration: autoMsg.fileDuration
            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: sticker_component
        StickerMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: document_component
        DocumentMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
            fileName: autoMsg.fileName
            fileMimeType: autoMsg.fileMimeType
            fileDuration: autoMsg.fileDuration
            fileSize: autoMsg.fileSize
        }
    }
    Component {
        id: audio_component
        AudioMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user
            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            fileName: autoMsg.fileName
            fileMimeType: autoMsg.fileMimeType
            fileTitle: autoMsg.fileTitle
            filePerformer: autoMsg.filePerformer
            fileDuration: autoMsg.fileDuration
            fileSize: autoMsg.fileSize
        }
    }
    Component {
        id: contact_component
        ContactMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: action_component
        ActionMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
    Component {
        id: unsupport_component
        UnsupportedMessage {
            anchors.centerIn: parent
            maximumWidth: autoMsg.maximumWidth
            maximumHeight: autoMsg.maximumHeight
            user: autoMsg.user

            downloadable: autoMsg.downloadable
            uploading: autoMsg.uploading
            downloading: autoMsg.downloading
            transfaring: autoMsg.transfaring
            transfared: autoMsg.transfared
            transfaredSize: autoMsg.transfaredSize
            totalSize: autoMsg.totalSize
            filePath: autoMsg.filePath
            thumbPath: autoMsg.thumbPath

            message: autoMsg.message
            engine: autoMsg.engine
            margins: autoMsg.margins
            messageType: autoMsg.messageType
        }
    }
}

