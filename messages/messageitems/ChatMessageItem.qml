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
    height: column.height + 8*Devices.density

    readonly property bool isSticker: (messageType == Telegram.Enums.TypeStickerMessage)
    readonly property bool isAction: (messageType == Telegram.Enums.TypeActionMessage)

    property real messageMargins: 4*Devices.density

    Column {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 8*Devices.density

        ToolKit.ReplyMessage {
            x: {
                var pad = status_column.x + main_row.x
                if(out)
                    return pad + status_column.width - width - 10*Devices.density
                else
                    return pad + 10*Devices.density
            }
            color: CutegramGlobals.highlightColors
            engine: item.engine
            message: item.replyMessage
            mediaType: item.replyType
            chat: item.replyPeer && item.replyPeer.title? item.replyPeer : null
            user: item.replyPeer && item.replyPeer.firstName? item.replyPeer : null
            fontsColor: "#ffffff"
            visible: replyMsgId && !isAction
            onFocusRequest: item.focusRequest(message)

            Rectangle {
                anchors.top: parent.bottom
                x: out? parent.width - width - 10*Devices.density : 10*Devices.density
                width: 2*Devices.density
                height: 8*Devices.density
                color: parent.color
            }
        }

        Row {
            id: main_row
            x: {
                if(isAction)
                    return parent.width/2 - width/2
                else
                if(item.out)
                    return parent.width - width - messageMargins
                else
                    return messageMargins
            }
            layoutDirection: item.out? Qt.RightToLeft : Qt.LeftToRight

            Column {
                id: status_column
                spacing: 4*Devices.density
                width: 42*Devices.density
                visible: !isAction

                ToolKit.ProfileImage {
                    id: user_img
                    width: 32*Devices.density
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    engine: item.engine
                    source: item.fromUserItem
                }

                Text {
                    font.family: Awesome.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#777777"
                    anchors.horizontalCenter: parent.horizontalCenter
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

                Text {
                    font.family: Awesome.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#777777"
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: item.views
                    text: {
                        var res = ""
                        if(item.views < 1000)
                            res += item.views + " " + Awesome.fa_eye
                        else
                            res += Math.floor(item.views/1000) + "k " + Awesome.fa_eye
                    }
                }
            }

            Column {
                id: msg_column
                spacing: 4*Devices.density

                Row {
                    x: out? parent.width - width : 0
                    layoutDirection: item.out? Qt.RightToLeft : Qt.LeftToRight
                    spacing: 4*Devices.density
                    visible: !isAction

                    Text {
                        font.pixelSize: 9*Devices.fontDensity
                        color: "#777777"
                        text: item.dateTime
                    }

                    Text {
                        font.pixelSize: 9*Devices.fontDensity
                        color: "#777777"
                        text: "|"
                    }

                    Text {
                        font.pixelSize: 9*Devices.fontDensity
                        color: "#777777"
                        text: fromUserItem? (fromUserItem.firstName + " " + fromUserItem.lastName).trim() : qsTr("Unknown User")
                    }
                }

                Rectangle {
                    id: message_frame
                    x: out? parent.width - width : 0
                    height: msg_core_column.height + 24*Devices.density
                    radius: CutegramSettings.messageItemRadius
                    color: isSticker || isAction? "#00000000" : "#ffffff"
                    width: msg_core_column.width

                    Rectangle {
                        anchors.fill: parent
                        color: CutegramGlobals.baseColor
                        opacity: 0.2
                        visible: CutegramSettings.minimalMode && out && !(isSticker || isAction)
                        radius: parent.radius
                    }

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
                            maximumWidth: item.maximumWidth
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
            }
        }
    }
}

