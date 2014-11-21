import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    height: row.height

    property Dialog currentDialog
    property bool isChat: currentDialog.peer.chatId != 0
    property User user: telegramObject.user(currentDialog.peer.userId)
    property Chat chat: telegramObject.chat(currentDialog.peer.chatId)
    property variant dId: isChat? currentDialog.peer.chatId : currentDialog.peer.userId

    property bool signalBlocker: false
    property real frameMargins: 8*physicalPlatformScale

    onDIdChanged: {
        if( dId == 0 )
            return
        if( signalBlocker )
            return

        signalBlocker = true
        favorite_check.checked = telegramObject.userData.isFavorited(dId)
        mute_check.checked = telegramObject.userData.isMuted(dId)
        love_check.checked = (telegramObject.userData.value("love")==dId)
        signalBlocker = false
    }

    onChatChanged: {
        if(chat==telegramObject.nullChat)
            return

        telegramObject.getFile(chat.photo.photoBig)
    }

    onUserChanged: {
        if(user==telegram.nullUserg)
            return

        telegramObject.getFile(user.photo.photoBig)
    }

    Connections {
        target: telegramObject.userData
        onFavoriteChanged: {
            if( id != dId )
                return

            favorite_check.checked = telegramObject.userData.isFavorited(dId)
        }
        onMuteChanged: {
            if( id != dId )
                return

            mute_check.checked = telegramObject.userData.isMuted(dId)
        }
        onValueChanged: {
            if( key != "love" )
                return

            love_check.checked = (telegramObject.userData.value("love")==dId)
        }
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: frameMargins
        spacing: 8*physicalPlatformScale

        Image {
            width: 192*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            smooth: true
            asynchronous: true
            source: {
                var res = ""
                if( isChat ) {
                    res = chat.photo.photoBig.download.location
                    if( res.length == 0 ) {
                        res = chat.photo.photoSmall.download.location
                    }
                } else {
                    res = user.photo.photoBig.download.location
                    if( res.length == 0 ) {
                        res = user.photo.photoSmall.download.location
                    }
                }

                if( res.length == 0 )
                    res = "files/user.png"

                return res
            }
        }

        Item { width: 20*physicalPlatformScale; height: 1 }

        Column {
            anchors.top: parent.top
            anchors.margins: 20*physicalPlatformScale

            Text {
                id: phone_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Phone Number")
                visible: !isChat
            }

            Text {
                id: favorite_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Favorite")
            }

            Text {
                id: love_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Love")
            }

            Text {
                id: mute_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Mute")
            }
        }

        Column {
            anchors.top: parent.top
            anchors.margins: 20*physicalPlatformScale

            Text {
                height: phone_lbl.height
                font.family: SApp.globalFontFamily
                font.pixelSize: 11*fontsScale
                verticalAlignment: Text.AlignVCenter
                color: "#333333"
                text: user.phone
                visible: !isChat
            }

            Item {
                height: favorite_lbl.height
                width: favorite_check.width

                CheckBox {
                    id: favorite_check
                    height: 20*physicalPlatformScale
                    width: 30*physicalPlatformScale
                    color: checked? masterPalette.highlight : "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    labels: false
                    onCheckedChanged: {
                        if( signalBlocker )
                            return
                        if( checked )
                            telegramObject.userData.addFavorite(dId)
                        else
                            telegramObject.userData.removeFavorite(dId)
                    }
                }
            }

            Item {
                height: love_lbl.height
                width: love_check.width

                CheckBox {
                    id: love_check
                    height: 20*physicalPlatformScale
                    width: 30*physicalPlatformScale
                    color: checked? masterPalette.highlight : "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    labels: false
                    onCheckedChanged: {
                        if( signalBlocker )
                            return
                        telegramObject.userData.setValue("love", checked?dId:"")
                    }
                }
            }

            Item {
                height: mute_lbl.height
                width: mute_check.width

                CheckBox {
                    id: mute_check
                    height: 20*physicalPlatformScale
                    width: 30*physicalPlatformScale
                    color: checked? masterPalette.highlight : "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    labels: false
                    onCheckedChanged: {
                        if( signalBlocker )
                            return
                        if( checked )
                            telegramObject.userData.addMute(dId)
                        else
                            telegramObject.userData.removeMute(dId)
                    }
                }
            }
        }
    }
}
