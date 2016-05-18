import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"
import "../thirdparty"

Item {
    id: item
    height: CutegramSettings.minimalMode? 56*Devices.density : 64*Devices.density

    property alias engine: img.engine
    property alias showButtons: buttons.visible

    signal active()
    signal forwardRequest(variant inputPeer, int msgId)

    Row {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6*Devices.density

        Item {
            id: buttons
            width: 12*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            height: 40*Devices.density

            Item {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: parent.height/2

                Text {
                    anchors.centerIn: parent
                    font.family: Awesome.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: {
                        if(model.category == CutegramEnums.dialogsCategoryEmpty)
                            return "#00000000"
                        else
                        if(model.category == CutegramEnums.dialogsCategoryFavorite)
                            return "#e3cf2a"
                        else
                        if(model.category == CutegramEnums.dialogsCategoryLove)
                            return "#db2424"
                        else
                            return "#00000000"
                    }
                    text: {
                        if(model.category == CutegramEnums.dialogsCategoryEmpty)
                            return ""
                        else
                        if(model.category == CutegramEnums.dialogsCategoryFavorite)
                            return Awesome.fa_star
                        else
                        if(model.category == CutegramEnums.dialogsCategoryLove)
                            return Awesome.fa_heart
                        else
                            return ""
                    }
                }
            }

            MouseArea {
                id: mute_marea
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: parent.height/2
                onClicked: model.mute = !model.mute

                Text {
                    font.family: Awesome.family
                    anchors.centerIn: parent
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#888888"
                    text: model.mute? Awesome.fa_bell_slash_o : Awesome.fa_bell_o
                    visible: mute_marea.containsMouse || model.mute
                }
            }
        }

        Rectangle {
            id: avatar
            height: item.height - 16*Devices.density
            width: height
            anchors.verticalCenter: parent.verticalCenter
            color: "#00000000"
            radius: width/2
            border.width: 1*Devices.density
            border.color: model.isOnline? "#75CB46" : "#00000000"

            ToolKit.ProfileImage {
                id: img
                anchors.fill: parent
                anchors.margins: 3*Devices.density
                source: model.user? model.user : model.chat
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            width: row.width - avatar.width - row.spacing - (buttons.visible? buttons.width + row.spacing : 0)
            height: 24*Devices.density
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.left: parent.left
                anchors.right: msg_state_txt.left
                anchors.rightMargin: 10*Devices.density
                anchors.verticalCenter: CutegramSettings.minimalMode? parent.verticalCenter : parent.top
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: 9*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                color: "#333333"
                text: CutegramEmojis.parse(model.title)
            }

            Text {
                id: date_txt
                anchors.right: parent.right
                anchors.verticalCenter: parent.top
                font.pixelSize: 9*Devices.fontDensity
                color: "#666666"
                visible: !CutegramSettings.minimalMode
                text: model.messageDate
            }

            Text {
                id: msg_state_txt
                anchors.right: date_txt.left
                anchors.rightMargin: 10*Devices.density
                anchors.verticalCenter: parent.top
                font.family: Awesome.family
                font.pixelSize: 9*Devices.fontDensity
                font.letterSpacing: -7*Devices.density
                color: "#75CB46"
                visible: !CutegramSettings.minimalMode
                text: {
                    if(!model.messageOut)
                        return ""
                    else
                        if(model.messageUnread)
                            return Awesome.fa_check
                        else
                            return Awesome.fa_check + Awesome.fa_check
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: unread_rect.left
                anchors.rightMargin: 6*Devices.density
                anchors.verticalCenter: parent.bottom
                font.pixelSize: 9*Devices.fontDensity
                color: "#666666"
                visible: !CutegramSettings.minimalMode
                text: {
                    if(model.typing.length == 0) {
                        return CutegramEmojis.parse(model.message)
                    } else {
                        return qsTr("Typing...")
                    }
                }
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Rectangle {
                id: unread_rect
                height: 14*Devices.density
                width: unread_txt.width + 8*Devices.density
                anchors.verticalCenter: CutegramSettings.minimalMode? parent.verticalCenter : parent.bottom
                anchors.right: parent.right
                color: model.mute? "#959595" : "#db2424"
                radius: 2*Devices.density
                visible: model.unreadCount

                Text {
                    id: unread_txt
                    anchors.centerIn: parent
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#ffffff"
                    text: model.unreadCount
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#cc000000"
        visible: dropArea.containsDrag

        Text {
            anchors.centerIn: parent
            font.family: Awesome.family
            font.pixelSize: 14*Devices.fontDensity
            color: "#ffffff"
            text: Awesome.fa_mail_forward
        }
    }

    Telegram.InputPeer {
        id: inputPeer
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: {
            var formats = drop.formats
            var type = drop.getDataAsString("cutegram/dragType")
            switch(Math.floor(type)) {
            case CutegramEnums.dragDataTypeMessage:
                inputPeer.classType = drop.getDataAsString(CutegramEnums.dragDataMessageClassType)
                inputPeer.channelId = drop.getDataAsString(CutegramEnums.dragDataMessageChannelId)
                inputPeer.chatId = drop.getDataAsString(CutegramEnums.dragDataMessageChatId)
                inputPeer.userId = drop.getDataAsString(CutegramEnums.dragDataMessageUserId)
                inputPeer.accessHash = Math.floor(drop.getDataAsString(CutegramEnums.dragDataMessageAccessHash))
                forwardRequest(inputPeer, drop.getDataAsString(CutegramEnums.dragDataMessageMsgId))
                break;
            case CutegramEnums.dragDataTypeExternal:
                break;
            case CutegramEnums.dragDataTypeContact:
                break;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.RightButton) {
                var loved = (model.category == CutegramEnums.dialogsCategoryLove)
                var favorited = (model.category == CutegramEnums.dialogsCategoryFavorite)
                var act = Desktop.showMenu([qsTr("Mark as read"),
                                            loved?qsTr("Unlove"):qsTr("Love"),
                                            favorited?qsTr("Unfavorite"):qsTr("Favorite")])
                switch(act) {
                case 0:
                    model.unreadCount = 0
                    break
                case 1:
                    model.category = loved? CutegramEnums.dialogsCategoryEmpty : CutegramEnums.dialogsCategoryLove
                    break
                case 2:
                    model.category = favorited? CutegramEnums.dialogsCategoryEmpty : CutegramEnums.dialogsCategoryFavorite
                    break
                }
            } else {
                active()
            }
        }
        z: -1
    }
}

