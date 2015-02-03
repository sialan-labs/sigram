import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: ad_list
    width: minimum? 80*Devices.density : 275*Devices.density

    property alias telegramObject: dialogs_model.telegram
    property Dialog currentDialog: telegramObject.dialog(0)

    property bool unminimumForce: false
    property bool minimum: Cutegram.minimumDialogs && !unminimumForce && !forceUnminimum
    property bool forceUnminimum: false

    property bool showLastMessage: Cutegram.showLastMessage

    Behavior on width {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    DialogsModel {
        id: dialogs_model
        onInitializingChanged: {
            if( initializing )
                indicator.start()
            else
                indicator.stop()
        }
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: true
        modern: true
        indicatorSize: 20*Devices.density
    }

    Rectangle {
        anchors.bottom: parent.top
        anchors.right: parent.right
        transformOrigin: Item.BottomRight
        rotation: -90
        width: parent.height
        height: 5*Devices.density
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#000000" }
        }
    }

    ListView {
        id: dlist
        width: 275*Devices.density - ad_list.x
        height: parent.height
        x: 6*Devices.density
        clip: true
        model: dialogs_model

        currentIndex: -1
        highlightMoveDuration: 0
        highlight: Item {
            width: dlist.width
            height: showLastMessage? 60*Devices.density : 54*Devices.density

            Rectangle {
                anchors.fill: parent
                opacity: 0.2
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                color: Cutegram.highlightColor
            }

            Rectangle {
                x: ad_list.width - width/2 - dlist.x
                anchors.verticalCenter: parent.verticalCenter
                transformOrigin: Item.Center
                rotation: 45
                width: 16*Devices.density
                height: width
                color: "#E4E9EC"
            }
        }

        delegate: Item {
            id: list_item
            width: dlist.width
            height: showLastMessage? 60*Devices.density : 54*Devices.density
            clip: true

            property Dialog dItem: item

            property bool isChat: dItem.peer.chatId != 0
            property User user: telegramObject.user(dItem.encrypted?enChatUid:dItem.peer.userId)
            property Chat chat: telegramObject.chat(dItem.peer.chatId)

            property EncryptedChat enchat: telegramObject.encryptedChat(dItem.peer.userId)
            property int enChatUid: enchat.adminId==telegramObject.me? enchat.participantId : enchat.adminId

            property Message message: telegramObject.message(dItem.topMessage)
            property variant msgDate: CalendarConv.fromTime_t(message.date)

            property bool selected: currentDialog==dItem
            property real itemOpacities: minimum? 0 : 1

            onSelectedChanged: if(selected) dlist.currentIndex = index

            Behavior on itemOpacities {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Rectangle {
                anchors.fill: parent
                opacity: marea.pressed && !selected? 0.3 : 0
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                color: Cutegram.highlightColor
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                anchors.leftMargin: 5*Devices.density
                anchors.rightMargin: 12*Devices.density

                ContactImage {
                    id: profile_img
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 4*Devices.density
                    width: height
                    dialog: dItem
                    circleMode: false

                    Image {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: -4*Devices.density
                        source: "files/online.png"
                        sourceSize: Qt.size(width,height)
                        width: 14*Devices.density
                        height: 14*Devices.density
                        visible: isChat? false : (user.status.classType == profile_img.typeUserStatusOnline)
                    }
                }

                Text {
                    id: title_txt
                    anchors.top: parent.top
                    anchors.bottom: showLastMessage? parent.verticalCenter : parent.bottom
                    anchors.left: profile_img.right
                    anchors.right: time_txt.left
                    anchors.margins: 4*Devices.density
                    font.pixelSize: 11*Devices.fontDensity
                    font.family: AsemanApp.globalFont.family
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    color: "#ffffff"
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    text: isChat? chat.title : user.firstName + " " + user.lastName
                    opacity: itemOpacities
                }

                Image {
                    x: title_txt.x + title_txt.paintedWidth + 4*Devices.density
                    anchors.verticalCenter: parent.verticalCenter
                    source: "files/lock.png"
                    sourceSize: Qt.size(width, height)
                    visible: dItem.encrypted
                    width: 14*Devices.density
                    height: width
                }

                Text {
                    id: msg_txt
                    anchors.top: parent.verticalCenter
                    anchors.bottom: parent.bottom
                    anchors.left: profile_img.right
                    anchors.right: parent.right
                    anchors.margins: 4*Devices.density
                    anchors.topMargin: 0
                    font.pixelSize: 9*Devices.fontDensity
                    font.family: AsemanApp.globalFont.family
                    color: "#bbbbbb"
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    clip: true
                    opacity: itemOpacities
                    visible: showLastMessage
                    text: {
                        if(!visible)
                            return ""
                        var list = dItem.typingUsers
                        if( list.length )
                            return qsTr("Typing...")
                        else
                            return emojis.textToEmojiText(message.message,16,true)
                    }
                }

                Text {
                    id: time_txt
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4*Devices.density
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#999999"
                    text: Cutegram.getTimeString(msgDate)
                    opacity: itemOpacities
                    visible: showLastMessage
                }

                UnreadItem {
                    unread: dItem.unreadCount
                    visible: unread != 0 && !selected
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onContainsMouseChanged: toggleMinimum(containsMouse)
                onClicked: {
                    if( mouse.button == Qt.RightButton ) {
                        var actions, res
                        if(dItem.encrypted) {
                            actions = [qsTr("Delete")]
                            res = Cutegram.showMenu(actions)
                            switch(res) {
                            case 0:
                                if( Desktop.yesOrNo(View, qsTr("Delete secret chat"), qsTr("Are you sure about deleting this secret chat?")) )
                                    telegramObject.messagesDiscardEncryptedChat(dItem.peer.userId)
                                break;
                            }
                        } else if(user.id == telegramObject.cutegramId) {
                            actions = [qsTr("Delete")]
                            res = Cutegram.showMenu(actions)
                            switch(res) {
                            case 0:
                                telegramObject.deleteCutegramDialog()
                                break;
                            }
                        } else if(isChat) {
                            actions = [qsTr("Leave"), qsTr("Delete History")]
                            res = Cutegram.showMenu(actions)
                            switch(res) {
                            case 0:
                                if( Desktop.yesOrNo(View, qsTr("Leave the group"), qsTr("Are you sure about leaving this group?")) )
                                    telegramObject.messagesDeleteChatUser(dItem.peer.chatId, telegramObject.me)
                                break;

                            case 1:
                                if( Desktop.yesOrNo(View, qsTr("Delete History"), qsTr("Are you sure about deleting history?")) )
                                    telegramObject.messagesDeleteHistory(dItem.peer.chatId)
                                break;
                            }
                        } else {
                            actions = [qsTr("Delete History")]
                            res = Cutegram.showMenu(actions)
                            switch(res) {
                            case 0:
                                if( Desktop.yesOrNo(View, qsTr("Delete History"), qsTr("Are you sure about deleting history?")) )
                                    telegramObject.messagesDeleteHistory(dItem.peer.userId)
                                break;
                            }
                        }
                    } else {
                        currentDialog = list_item.dItem
                        dlist.currentIndex = index
                    }
                }
            }

            DialogItemTools {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12*Devices.density
                height: 22*Devices.density
                dialog: dItem
                show: marea.containsMouse
                opacity: itemOpacities
            }

            DialogDropFile {
                anchors.fill: parent
                dialogItem: dItem
                color: "#dd222222"
                onDropped: switch_dialog_timer.restart()
                onContainsDragChanged: toggleMinimum(containsDrag)
            }

            Timer {
                id: switch_dialog_timer
                interval: 100
                onTriggered: {
                    currentDialog = list_item.dItem
                    dlist.currentIndex = index
                }
            }
        }

        section.property: "section"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels
        section.delegate: Item {
            height: 30*Devices.density
            width: dlist.width

            Image {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 4*Devices.density
                width: 12*Devices.density
                height: width
                sourceSize: Qt.size(width,height)
                smooth: true
                source: {
                    if( section == 0 )
                        return "files/contact.png"
                    else
                    if( section == 1 )
                        return "files/favorite.png"
                    else
                    if( section == 2 )
                        return "files/love.png"
                    else
                        return ""
                }
            }
        }
    }

    MouseArea {
        anchors.left: parent.right
        anchors.right: dlist.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        hoverEnabled: true
    }

    NormalWheelScroll {
        flick: dlist
    }

    Timer {
        id: restore_minimum_timer
        interval: 500
        onTriggered: unminimumForce = false
    }

    Timer {
        id: restore_unminimum_timer
        interval: 50
        onTriggered: unminimumForce = true
    }

    PhysicalScrollBar {
        scrollArea: dlist; height: dlist.height; width: 6*Devices.density
        anchors.right: dlist.left; anchors.top: dlist.top; color: "#777777"
    }

    Button {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 50*Devices.density
        width: 10*Devices.density
        normalColor: enter? "#88ffffff" : "#44ffffff"
        highlightColor: "#aaffffff"
        onClicked: Cutegram.minimumDialogs = !Cutegram.minimumDialogs
        cursorShape: Qt.PointingHandCursor
        icon: Cutegram.minimumDialogs? "files/arrow-right.png" : "files/arrow-left.png"
        iconHeight: 8*Devices.density

        Behavior on color {
            ColorAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    function toggleMinimum(stt) {
        if(!Cutegram.minimumDialogs)
            return
        if(stt) {
            restore_minimum_timer.stop()
            restore_unminimum_timer.restart()
        } else {
            restore_unminimum_timer.stop()
            restore_minimum_timer.restart()
        }
    }
}
