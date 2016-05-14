import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "types" as Types
import "../../awesome"
import "../../toolkit" as ToolKit
import "../../thirdparty"
import "../../globals"

AbstractMessageItem {
    id: item
    height: column.height + 16*Devices.density

    readonly property bool isSticker: (messageType == Telegram.Enums.TypeStickerMessage)
    readonly property bool isAction: (messageType == Telegram.Enums.TypeActionMessage)

    property real messageMargins: 8*Devices.density

    MimeData {
        id: mime
    }

    DragObject {
        id: drag
        mimeData: mime
    }

    Rectangle {
        width: 2*Devices.density
        height: parent.height
        anchors.centerIn: parent
        color: "#cccccc"
    }

    Column {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 4*Devices.density

        ToolKit.ReplyMessage {
            anchors.left: message_frame.left
            color: CutegramGlobals.highlightColors
            engine: item.engine
            message: item.replyMessage
            mediaType: item.replyType
            chat: item.replyPeer && item.replyPeer.title? item.replyPeer : null
            user: item.replyPeer && item.replyPeer.firstName? item.replyPeer : null
            fontsColor: "#ffffff"
            visible: replyMsgId && !isAction

            Rectangle {
                anchors.top: parent.bottom
                x: out? parent.width - width - 10*Devices.density : 10*Devices.density
                width: 2*Devices.density
                height: 8*Devices.density
                color: parent.color
            }
        }

        Rectangle {
            id: message_frame
            anchors.horizontalCenter: parent.horizontalCenter
            height: msg_core_column.height + 24*Devices.density
            radius: CutegramSettings.messageItemRadius
            color: isSticker || isAction? "#00000000" : "#ffffff"
            width: msg_core_column.width

            ToolKit.MessageMouseArea {
                anchors.fill: parent
                source: message_frame
                message: item.messageItem
                fromPeer: item.messagesModel.currentPeer
                draggable: !item.uploading
                urls: item.filePath
                onClickRequest: autoMsg.clickRequest()
                onContextMenuRequest: {
                    var act = Desktop.showMenu([qsTr("Copy"), "", qsTr("Forward"), qsTr("Reply"), "", qsTr("Delete")])
                    switch(act) {
                    case 0:
                        autoMsg.copyRequest()
                        break
                    case 2:
                        item.forwardRequest()
                        break
                    case 3:
                        item.replyRequest()
                        break
                    case 5:
                        if(Desktop.yesOrNo(CutegramGlobals.mainWindow, qsTr("Delete Messages?"), qsTr("Are you sure about deleting these messages?")))
                            messagesModel.deleteMessages([messageItem.id])
                        break
                    }
                }
            }

            Column {
                id: msg_core_column
                anchors.centerIn: parent
                spacing: 10*Devices.density

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: autoMsg.width - 20*Devices.density
                    color: CutegramGlobals.highlightColors
                    font.pixelSize: 9*Devices.fontDensity
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    visible: text.length != 0 && !isSticker && !isAction
                    text: {
                        if(!forwardFromPeer)
                            return ""
                        else
                        if(forwardFromPeer.firstName)
                            return qsTr("Forwarded From %1").arg( (forwardFromPeer.firstName + " " + forwardFromPeer.lastName).trim() )
                        else
                        if(forwardFromPeer.title)
                            return qsTr("Forwarded From %1").arg(forwardFromPeer.title)
                        else
                            return ""
                    }
                }

                Types.AutoMessage {
                    id: autoMsg
                    message: item.messageItem
                    engine: item.engine
                    maximumWidth: item.view.width*0.8
                    maximumHeight: item.maximumHeight
                    user: item.fromUserItem
                    fileName: item.fileName
                    fileMimeType: item.fileMimeType
                    fileTitle: item.fileTitle
                    filePerformer: item.filePerformer
                    fileDuration: item.fileDuration
                    fileIsVoice: item.fileIsVoice
                    fileSize: item.fileSize

                    downloadable: item.downloadable
                    uploading: item.uploading
                    downloading: item.downloading
                    transfaring: item.transfaring
                    transfared: item.transfared
                    transfaredSize: item.transfaredSize
                    totalSize: item.totalSize
                    filePath: item.filePath
                    thumbPath: item.thumbPath

                    messageType: item.messageType
                }
            }

            Item {
                height: 2*Devices.density
                width: parent.width
                anchors.bottom: parent.bottom
                clip: true

                Rectangle {
                    height: radius*2
                    radius: message_frame.radius
                    width: parent.width
                    anchors.bottom: parent.bottom
                    color: isSticker || isAction? "#00000000" : (item.out? "#c8c8c8" : CutegramGlobals.highlightColors)
                }
            }
        }

        Row {
            id: msg_status
            anchors.right: message_frame.right
            height: 20*Devices.density
            spacing: 1*Devices.density
            visible: !isAction

            Rectangle {
                width: views_txt.width + 8*Devices.density
                height: parent.height
                visible: item.views
                color: "#aaaaaa"
                anchors.verticalCenter: parent.verticalCenter
                radius: 3*Devices.density

                Text {
                    id: views_txt
                    font.family: Awesome.family
                    font.pixelSize: 8*Devices.fontDensity
                    color: "#ffffff"
                    anchors.centerIn: parent
                    text: {
                        var res = ""
                        if(item.views < 1000)
                            res += item.views + " " + Awesome.fa_eye
                        else
                            res += Math.floor(item.views/1000) + "k " + Awesome.fa_eye
                    }
                }
            }

            Rectangle {
                width: date_txt.width + 8*Devices.density
                height: parent.height
                color: "#aaaaaa"
                anchors.verticalCenter: parent.verticalCenter
                radius: 3*Devices.density

                Text {
                    id: date_txt
                    font.pixelSize: 8*Devices.fontDensity
                    color: "#ffffff"
                    anchors.centerIn: parent
                    text: item.dateTime
                }
            }

            Rectangle {
                width: stt_txt.width + 8*Devices.density
                height: parent.height
                visible: item.out
                color: "#aaaaaa"
                anchors.verticalCenter: parent.verticalCenter
                radius: 3*Devices.density

                Text {
                    id: stt_txt
                    font.family: Awesome.family
                    font.pixelSize: 8*Devices.fontDensity
                    color: "#ffffff"
                    anchors.centerIn: parent
                    font.letterSpacing: -7*Devices.density
                    text: {
                        if(!out)
                            return ""
                        else
                        if(!sent)
                            return Awesome.fa_clock_o
                        if(unread)
                            return Awesome.fa_check
                        else
                            return Awesome.fa_check + Awesome.fa_check
                    }
                }
            }
        }
    }
}

