import QtQuick 2.0
import AsemanTools.Controls 1.0 as Controls
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    id: up_base
    height: main_page.height + 2*frameMargins + 10

    property Dialog currentDialog
    property bool isChat: currentDialog.peer.chatId != 0
    property User user: telegramObject.user(currentDialog.peer.userId)
    property Chat chat: telegramObject.chat(currentDialog.peer.chatId)
    property variant dId: isChat? currentDialog.peer.chatId : currentDialog.peer.userId

    property bool signalBlocker: false
    property real frameMargins: 20*Devices.density

    property bool particianMode: false

    signal addParticianRequest()

    onParticianModeChanged: {
        if( particianMode )
            BackHandler.pushHandler(particians_frame, particians_frame.back)
        else
            BackHandler.removeHandler(particians_frame)
    }

    onDIdChanged: {
        if( dId == 0 )
            return
        if( signalBlocker )
            return

        signalBlocker = true
        favorite_check.checked = telegramObject.userData.isFavorited(dId)
        mute_check.checked = telegramObject.userData.isMuted(dId)
        love_check.checked = (telegramObject.userData.value("love")==dId)
        badge_check.checked = !(telegramObject.userData.notify(dId) & UserData.DisableBadges)
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

    Item {
        id: particians_frame
        width: parent.width - 20*Devices.density
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: frameMargins
        anchors.left: main_page.right
        visible: isChat

        Button {
            id: pback_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 30*Devices.density
            icon: "files/back.png"
            iconHeight: 22*Devices.density
            radius: 4*Devices.density
            onClicked: BackHandler.back()
        }

        UserPropertiesChatParticipants {
            id: participants
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: pback_btn.right
            anchors.right: parent.right
            currentDialog: up_base.currentDialog
        }

        function back() {
            particianMode = false
        }
    }

    Item {
        id: main_page
        anchors.top: parent.top
        anchors.margins: frameMargins
        height: row.height
        width: parent.width-10*Devices.density
        x: particianMode? -width : 10*Devices.density

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Row {
            id: row
            width: parent.width
            spacing: 8*Devices.density

            Item {
                width: 140*Devices.density
                height: 160*Devices.density

                ClickableContactImage {
                    width: 128*Devices.density
                    height: width
                    anchors.centerIn: parent
                    dialog: up_base.currentDialog
                }
            }

            Item { width: 20*Devices.density; height: 1 }

            Column {
                id: col1
                anchors.top: parent.top
                anchors.margins: 20*Devices.density
                spacing: 12*Devices.density

                Text {
                    id: phone_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    color: Desktop.titleBarTextColor
                    text: qsTr("Phone Number")
                    visible: !isChat
                }

                Text {
                    id: username_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    color: Desktop.titleBarTextColor
                    text: qsTr("Username")
                    visible: !isChat && user.username.length != 0
                }

                Text {
                    id: favorite_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    color: Desktop.titleBarTextColor
                    text: qsTr("Favorite")
                }

                Text {
                    id: love_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    color: Desktop.titleBarTextColor
                    text: qsTr("Love")
                }

                Text {
                    id: mute_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    color: Desktop.titleBarTextColor
                    text: qsTr("Mute")
                }

                Text {
                    id: badge_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    color: Desktop.titleBarTextColor
                    text: qsTr("Show Badges")
                }

                Text {
                    id: participants_lbl
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    verticalAlignment: Text.AlignVCenter
                    height: 40*Devices.density
                    color: Desktop.titleBarTextColor
                    text: qsTr("Participants")
                    visible: isChat
                }
            }

            Column {
                id: col2
                anchors.top: parent.top
                anchors.margins: 20*Devices.density
                spacing: 12*Devices.density

                Text {
                    height: phone_lbl.height
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    verticalAlignment: Text.AlignVCenter
                    color: Desktop.titleBarTextColor
                    text: user.phone + " "
                    visible: !isChat
                }

                Text {
                    height: username_lbl.height
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    verticalAlignment: Text.AlignVCenter
                    color: Desktop.titleBarTextColor
                    text: "@" + user.username
                    visible: username_lbl.visible
                }

                Item {
                    height: favorite_lbl.height
                    width: favorite_check.width

                    Controls.Switch {
                        id: favorite_check
                        anchors.verticalCenter: parent.verticalCenter
                        style: Cutegram.currentTheme.switchStyle
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

                    Controls.Switch {
                        id: love_check
                        anchors.verticalCenter: parent.verticalCenter
                        style: Cutegram.currentTheme.switchStyle
                        onCheckedChanged: {
                            if( signalBlocker )
                                return
                            telegramObject.userData.setValue("love", checked?dId:"-1")
                        }
                    }
                }

                Item {
                    height: mute_lbl.height
                    width: mute_check.width

                    Controls.Switch {
                        id: mute_check
                        anchors.verticalCenter: parent.verticalCenter
                        style: Cutegram.currentTheme.switchStyle
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

                Item {
                    height: badge_lbl.height
                    width: badge_check.width

                    Controls.Switch {
                        id: badge_check
                        anchors.verticalCenter: parent.verticalCenter
                        style: Cutegram.currentTheme.switchStyle
                        onCheckedChanged: {
                            if( signalBlocker )
                                return

                            var attrValue = telegramObject.userData.notify(dId)
                            var badgesState = attrValue & UserData.DisableBadges
                            var otherState = attrValue - badgesState

                            badgesState = checked? 0 : UserData.DisableBadges
                            telegramObject.userData.setNotify(dId, badgesState|otherState)
                        }
                    }
                }

                Item {
                    height: participants_lbl.height
                    width: particians_row.width
                    visible: isChat

                    Row {
                        id: particians_row
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4*Devices.density

                        Controls.Button {
                            text: qsTr("Show List")
                            style: Cutegram.currentTheme.buttonStyle
                            onClicked: particianMode = true
                        }

                        Controls.Button {
                            text: qsTr("Add Participant")
                            style: Cutegram.currentTheme.buttonStyle
                            onClicked: up_base.addParticianRequest()
                        }

                        Controls.Button {
                            text: qsTr("Leave")
                            style: Cutegram.currentTheme.buttonStyle
                            onClicked: {
                                if( Desktop.yesOrNo(View, qsTr("Leave the group"), qsTr("Are you sure about leaving this group?")) )
                                    telegramObject.messagesDeleteChatUser(chat.id, telegramObject.me)
                            }
                        }
                    }
                }
            }
        }

        Column {
            id: buttons_col
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8*Devices.density

            property color buttonColors: {
                var mclr = Cutegram.currentTheme.masterColor
                return Qt.rgba(mclr.r, mclr.g, mclr.b, 0.3)
            }

            Row {
                anchors.right: parent.right

                Button {
                    height: 32*Devices.density
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "files/delete.png"
                    iconHeight: 26*Devices.density
                    normalColor: "#00000000"
                    highlightColor: buttons_col.buttonColors
                    visible: backgroundManager.background != ""
                    onClicked: backgroundManager.setBackground("")
                }

                Controls.Button {
                    width: 100*Devices.density
                    text: qsTr("Background")
                    style: Cutegram.currentTheme.buttonStyle
                    onClicked: {
                        var newImg = Desktop.getOpenFileName(View, qsTr("Select photo"), "*.jpg *.png *.jpeg")
                        if(newImg.length == 0)
                            return

                        backgroundManager.setBackground(newImg)
                    }
                }
            }

            Row {
                anchors.right: parent.right

                Button {
                    height: 32*Devices.density
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "files/delete.png"
                    iconHeight: 26*Devices.density
                    normalColor: "#00000000"
                    highlightColor: buttons_col.buttonColors
                    visible: headerManager.background != ""
                    onClicked: headerManager.setBackground("")
                }

                Controls.Button {
                    width: 100*Devices.density
                    text: qsTr("Header")
                    style: Cutegram.currentTheme.buttonStyle
                    onClicked: {
                        var newImg = Desktop.getOpenFileName(View, qsTr("Select photo"), "*.jpg *.png *.jpeg")
                        if(newImg.length == 0)
                            return

                        headerManager.setBackground(newImg)
                    }
                }
            }
        }
    }
}
