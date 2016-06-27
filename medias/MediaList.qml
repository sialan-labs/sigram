import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

AsemanGridView {
    id: gview
    model: mlmodel

    property alias engine: mlmodel.engine
    property alias filter: mlmodel.messageFilter
    property alias currentPeer: mlmodel.currentPeer

    cellWidth: width/Math.floor(width/(128*Devices.density))
    cellHeight: cellWidth

    property real scrollY: gview.visibleArea.yPosition*gview.contentHeight
    property bool proximateEnd: (scrollY<gview.height && gview.contentHeight>gview.height*2 && gview.height>0)
    property bool proximateBegin: (scrollY>(gview.contentHeight-gview.height*1.5) && gview.contentHeight>gview.height*2 && gview.height>0)

    onProximateBeginChanged: if(proximateBegin && mlmodel.count && mlmodel.count%mlmodel.limit == 0) mlmodel.loadBack()

    signal forwardRequest(variant inputPeer, variant msgIds)

    Telegram.MediaListModel {
        id: mlmodel
        messageFilter: Telegram.MessagesFilter.TypeInputMessagesFilterPhotos
    }

    delegate: Item {
        width: gview.cellWidth
        height: gview.cellHeight

        ToolKit.MessageImage {
            id: img
            engine: mlmodel.engine
            message: model.item
            anchors.fill: parent
            anchors.margins: 2*Devices.density
            fillMode: Image.PreserveAspectCrop
            blur: !downloaded
        }

        MouseArea {
            id: marea
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            onClicked: {
                switch(mouse.button)
                {
                case Qt.RightButton:
                    var act = Desktop.showMenu([qsTr("Copy"), qsTr("Forward"), qsTr("Delete")])
                    switch(act) {
                    case 0:
                        Devices.clipboardUrl = [img.destination]
                        break
                    case 1:
                        forwardRequest(model.toPeerItem, [model.item.id])
                        break
                    case 2:
                        if(Desktop.yesOrNo(CutegramGlobals.mainWindow, qsTr("Delete Messages?"), qsTr("Are you sure about deleting these messages?")))
                            mlmodel.deleteMessages([model.item.id])
                        break
                    }
                    break
                case Qt.LeftButton:
                    if(img.downloaded) Qt.openUrlExternally(img.destination)
                    else
                    if(img.downloading) img.stop()
                    else img.download()
                    break
                }
            }
        }

        Text {
            id: btn
            anchors.centerIn: parent
            color: {
                switch(model.messageType) {
                case Telegram.Enums.TypeAudioMessage:
                case Telegram.Enums.TypeDocumentMessage:
                case Telegram.Enums.TypeVideoMessage:
                case Telegram.Enums.TypeWebPageMessage:
                case Telegram.Enums.TypeAnimatedMessage:
                case Telegram.Enums.TypePhotoMessage:
                default:
                    return img.downloading? "#db2424" : "#333333"
                }
            }
            font.family: Awesome.family
            font.pixelSize: 25*Devices.fontDensity
            visible: {
                switch(model.messageType) {
                case Telegram.Enums.TypeVideoMessage:
                case Telegram.Enums.TypeDocumentMessage:
                case Telegram.Enums.TypeWebPageMessage:
                case Telegram.Enums.TypeAnimatedMessage:
                    return true
                case Telegram.Enums.TypeAudioMessage:
                case Telegram.Enums.TypePhotoMessage:
                default:
                    return !img.downloaded
                }
            }
            text: {
                if(img.downloaded) {
                    switch(model.messageType) {
                    case Telegram.Enums.TypeVideoMessage:
                        return Awesome.fa_play
                    case Telegram.Enums.TypeDocumentMessage:
                    case Telegram.Enums.TypeAudioMessage:
                    case Telegram.Enums.TypeWebPageMessage:
                    case Telegram.Enums.TypeAnimatedMessage:
                    case Telegram.Enums.TypePhotoMessage:
                    default:
                        return ""//fileTypeIcon.text
                    }
                }
                if(img.downloading) return Awesome.fa_remove
                return Awesome.fa_download
            }
        }

        ProgressBar {
            anchors.left: img.left
            anchors.right: img.right
            radius: 0
            height: 3*Devices.density
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 35*Devices.density
            color: "#ffffff"
            topColor: CutegramGlobals.highlightColors
            percent: 100*model.transfaredSize/model.totalSize
            visible: model.transfaring
        }

        Text {
            id: fileTypeIcon
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 8*Devices.density
            color: "#333333"
            font.family: Awesome.family
            font.pixelSize: 11*Devices.fontDensity
            style: Text.Raised
            styleColor: "#aaffffff"
            text: {
                switch(model.messageType) {
                case Telegram.Enums.TypeDocumentMessage:
                    return Awesome.fa_files_o
                case Telegram.Enums.TypeVideoMessage:
                    return Awesome.fa_video_camera
                case Telegram.Enums.TypeAudioMessage:
                    return Awesome.fa_music
                case Telegram.Enums.TypeWebPageMessage:
                    return Awesome.fa_link
                case Telegram.Enums.TypePhotoMessage:
                    return Awesome.fa_photo
                case Telegram.Enums.TypeAnimatedMessage:
                    return Awesome.fa_video_camera
                default:
                    return ""
                }
            }
        }

        Column {
            anchors.left: img.left
            anchors.right: img.right
            anchors.bottom: parent.bottom
            anchors.margins: 8*Devices.density

            Text {
                anchors.right: parent.right
                color: "#333333"
                font.pixelSize: 9*Devices.fontDensity
                style: Text.Raised
                styleColor: "#aaffffff"
                text: getTimeString(model.fileDuration)
                visible: {
                    switch(model.messageType) {
                    case Telegram.Enums.TypeVideoMessage:
                        return true
                    case Telegram.Enums.TypeDocumentMessage:
                    case Telegram.Enums.TypeAudioMessage:
                    case Telegram.Enums.TypeWebPageMessage:
                    case Telegram.Enums.TypePhotoMessage:
                    case Telegram.Enums.TypeAnimatedMessage:
                    default:
                        return false
                    }
                }
            }

            Text {
                width: parent.width
                maximumLineCount: 1
                elide: Text.ElideRight
                wrapMode: Text.WrapAnywhere
                text: model.fileTitle.length != 0? model.fileTitle : model.fileName
                color: "#333333"
            }
        }

        Rectangle {
            anchors.fill: parent
            color: marea.containsMouse? "#220d80ec" : "#00000000"
            radius: 3*Devices.density
        }
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
