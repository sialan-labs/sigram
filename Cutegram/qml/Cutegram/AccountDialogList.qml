import QtQuick 2.0
import AsemanTools.Controls 1.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: ad_list
    width: minimum? 80*Devices.density : Cutegram.currentTheme.dialogListWidth*Devices.density

    property alias telegramObject: dialogs_model.telegram
    property Dialog currentDialog: telegramObject.dialog(0)

    property bool unminimumForce: false
    property bool minimum: Cutegram.minimumDialogs && !unminimumForce && !forceUnminimum
    property bool forceUnminimum: false

    property bool showLastMessage: Cutegram.showLastMessage

    property real typeMessageMediaDocument: 0x2fda2204
    property real typeMessageMediaContact: 0x5e7d2f39
    property real typeMessageMediaVideo: 0xa2d24290
    property real typeMessageMediaEmpty: 0x3ded6320
    property real typeMessageMediaAudio: 0xc6b68300
    property real typeMessageMediaPhoto: 0xc8c45a2a
    property real typeMessageMediaGeo: 0x56e0d474

    property real typeMessageActionEmpty: 0xb6aef7b0
    property real typeMessageActionChatDeletePhoto: 0x95e3fbef
    property real typeMessageActionChatCreate: 0xa6638b9a
    property real typeMessageActionChatEditTitle: 0xb5a1ce5a
    property real typeMessageActionChatEditPhoto: 0x7fcb13a8
    property real typeMessageActionGeoChatCreate: 0x6f038ebc
    property real typeMessageActionChatDeleteUser: 0xb2ae9b0c
    property real typeMessageActionChatAddUser: 0x5e3cfc4b
    property real typeMessageActionGeoChatCheckin: 0xc7d53de

    signal windowRequest(variant dialog)

    onCurrentDialogChanged: {
        dlist.currentIndex = dialogs_model.indexOf(currentDialog)
    }

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

    ListView {
        id: dlist
        width: Cutegram.currentTheme.dialogListWidth*Devices.density - x
        height: parent.height
        x: Cutegram.currentTheme.dialogListScrollWidth*Devices.density
        clip: true
        model: dialogs_model
        maximumFlickVelocity: 2000
        flickDeceleration: 2000

        currentIndex: -1
        highlightMoveDuration: 0
        highlight: Item {
            width: dlist.width
            height: showLastMessage? 60*Devices.density : 54*Devices.density

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                anchors.rightMargin: -radius
                color: Cutegram.currentTheme.dialogListHighlightColor
                radius: 5*Devices.density

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.right
                    anchors.leftMargin: -parent.radius
                    transformOrigin: Item.BottomLeft
                    rotation: -90
                    width: parent.height
                    height: Cutegram.currentTheme.dialogListShadowWidth*Devices.density
                    opacity: 0.4
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: Cutegram.currentTheme.dialogListShadowColor }
                    }
                }
            }

            Item {
                id: pointer_frame
                width: pointer_rct.width*Math.pow(2,0.5)*2
                height: width
                x: ad_list.width - width/2 - dlist.x
                anchors.verticalCenter: parent.verticalCenter
                visible: false

                Rectangle {
                    id: pointer_rct
                    anchors.centerIn: parent
                    transformOrigin: Item.Center
                    rotation: 45
                    width: Cutegram.currentTheme.dialogPointerHeight*Devices.density
                    height: width
                    color: Cutegram.currentTheme.dialogPointerColor
                }
            }

            DropShadow {
                anchors.fill: pointer_frame
                radius: Cutegram.currentTheme.dialogListShadowWidth
                samples: 16
                color: Cutegram.currentTheme.dialogListShadowColor
                source: pointer_frame
            }
        }

//        move: Transition {
//            NumberAnimation { easing.type: Easing.OutCubic; properties: "y"; duration: 300 }
//        }
//        moveDisplaced: Transition {
//            NumberAnimation { easing.type: Easing.OutCubic; properties: "y"; duration: 300 }
//        }

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

            property bool disableBadges: (telegramObject.userData.notify(isChat? chat.id : user.id) & UserData.DisableBadges)

            onSelectedChanged: if(selected) dlist.currentIndex = index

            Connections {
                target: telegramObject.userData
                onNotifyChanged: {
                    if(isChat && id == chat.id)
                        disableBadges = value
                    else
                    if(!isChat && id == user.id)
                        disableBadges = value
                }
            }

            Behavior on itemOpacities {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Rectangle {
                anchors.fill: parent
                opacity: marea.pressed && !selected? 1 : 0
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                color: Cutegram.currentTheme.dialogListHighlightColor
                radius: 5*Devices.density
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                anchors.leftMargin: 5*Devices.density
                anchors.rightMargin: 12*Devices.density

                Frame {
                    id: profile_img
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 4*Devices.density
                    width: height
                    backgroundColor: selected || marea.pressed? Cutegram.currentTheme.dialogListHighlightColor : Cutegram.currentTheme.dialogListBackground

                    ContactImage {
                        id: contact_img
                        anchors.fill: parent
                        dialog: dItem
                        circleMode: false
                    }
                }

                Image {
                    anchors.bottom: profile_img.bottom
                    anchors.right: profile_img.right
                    anchors.margins: -4*Devices.density
                    source: "files/online.png"
                    sourceSize: Qt.size(width,height)
                    width: 14*Devices.density
                    height: 14*Devices.density
                    visible: isChat? false : (user.status.classType == contact_img.typeUserStatusOnline)
                }

                Text {
                    id: title_txt
                    anchors.top: parent.top
                    anchors.bottom: showLastMessage? parent.verticalCenter : parent.bottom
                    anchors.left: profile_img.right
                    anchors.right: time_txt.left
                    anchors.margins: 4*Devices.density
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    font.family: Cutegram.currentTheme.dialogListFont.family
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    color: selected || marea.pressed? Cutegram.currentTheme.dialogListHighlightTextColor : Cutegram.currentTheme.dialogListFontColor
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.RichText
                    text: emojis.textToEmojiText( isChat? chat.title : user.firstName + " " + user.lastName, 16, true)
                    opacity: itemOpacities
                }

                Image {
                    x: title_txt.x + title_txt.paintedWidth + 4*Devices.density
                    anchors.verticalCenter: parent.verticalCenter
                    source: Cutegram.currentTheme.dialogListLightIcon? "files/lock.png" : "files/lock-dark.png"
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
                    textFormat: Text.RichText
                    font.pixelSize: Math.floor(Cutegram.currentTheme.dialogListMessageFont.pointSize*Devices.fontDensity)
                    font.family: Cutegram.currentTheme.dialogListMessageFont.family
                    color: selected || marea.pressed? Cutegram.currentTheme.dialogListHighlightMessageColor : Cutegram.currentTheme.dialogListMessageColor
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    lineHeight: 100
                    clip: true
                    opacity: itemOpacities
                    visible: showLastMessage
                    text: {
                        if(!visible)
                            return ""
                        var list = dItem.typingUsers
                        if( list.length )
                        {
                            if(!isChat)
                                return qsTr("Typing...")
                            else
                            {
                                var result = ""
                                for( var i=0; i<list.length; i++ ) {
                                    var uid = list[i]
                                    var user = telegramObject.user(list[i])
                                    var uname = user.firstName + " " + user.lastName
                                    result += uname.trim()

                                    if( i < list.length-1 )
                                        result += ", "
                                }

                                return result.trim() + " typing..."
                            }
                        }
                        else
                        {
                            var message_text = ""
                            if(message.media.classType != typeMessageMediaEmpty)
                            {
                                switch(message.media.classType)
                                {
                                    case typeMessageMediaDocument: 
                                        message_text = qsTr("Document") 
                                        break;
                                    case typeMessageMediaContact: 
                                        message_text = qsTr("Contact") 
                                        break;
                                    case typeMessageMediaVideo: 
                                        message_text = qsTr("Video") 
                                        break;
                                    case typeMessageMediaAudio: 
                                        message_text = qsTr("Audio") 
                                        break;
                                    case typeMessageMediaPhoto: 
                                        message_text = qsTr("Photo") 
                                        break;
                                    case typeMessageMediaGeo: 
                                        message_text = qsTr("Location") 
                                        break;
                                    default: 
                                        message_text = qsTr("Unknown") 
                                        break;
                                }
                            }
                            else if(message.action.classType != typeMessageActionEmpty)
                            {
                                var res = ""
                                var userName
                                var fromUserName = telegramObject.user(message.fromId).firstName + " " + telegramObject.user(message.fromId).lastName
                                fromUserName = fromUserName.trim()

                                switch(message.action.classType) {
                                case typeMessageActionChatCreate:
                                    res = qsTr("%1 created the group \"%2\"").arg(fromUserName).arg(message.action.title)
                                    break

                                case typeMessageActionChatAddUser:
                                    userName = telegramObject.user(message.action.userId).firstName + " " + telegramObject.user(message.action.userId).lastName
                                    userName = userName.trim()

                                    res = qsTr("%1 added %2 to group").arg(fromUserName).arg(userName)
                                    break

                                case typeMessageActionChatDeleteUser:
                                    userName = telegramObject.user(message.action.userId).firstName + " " + telegramObject.user(message.action.userId).lastName
                                    userName = userName.trim()

                                    if(telegramObject.user(message.action.userId).id == telegramObject.user(message.fromId).id)
                                        res = qsTr("%1 left the group").arg(userName)
                                    else
                                        res = qsTr("%1 kicked %2").arg(fromUserName).arg(userName)
                                    break;

                                case typeMessageActionChatEditTitle:
                                    res = qsTr("%1 changed group name to \"%2\"").arg(fromUserName).arg(message.action.title)
                                    break

                                case typeMessageActionChatEditPhoto:
                                    res = qsTr("%1 changed group photo.").arg(fromUserName)
                                    break

                                case typeMessageActionChatDeletePhoto:
                                    res = qsTr("%1 deleted group photo").arg(fromUserName)
                                    break

                                default:
                                    break
                                }

                                message_text = emojis.textToEmojiText(res, 16, true)
                            }
                            else
                            {
                                message_text = emojis.textToEmojiText(message.message,16,true)
                            }

                            if(isChat && message.action.classType == typeMessageActionEmpty)
                            {
                                var chat_username = ""
                                if(message.fromId == telegramObject.me)
                                    chat_username = qsTr("You")
                                else
                                    chat_username = telegramObject.user(message.fromId).firstName + " " + telegramObject.user(message.fromId).lastName

                                message_text = chat_username.trim() + ": " + message_text
                            }

                            return message_text
                        }
                    }
                }

                Text {
                    id: time_txt
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4*Devices.density
                    font.family: Cutegram.currentTheme.dialogListDateFont.family
                    font.pixelSize: Math.floor(Cutegram.currentTheme.dialogListDateFont.pointSize*Devices.fontDensity)
                    color: selected || marea.pressed? Cutegram.currentTheme.dialogListHighlightDateColor : Cutegram.currentTheme.dialogListDateColor
                    text: Cutegram.getTimeString(msgDate)
                    opacity: itemOpacities
                    visible: showLastMessage
                }

                UnreadItem {
                    unread: dItem.unreadCount
                    visible: unread != 0 && !selected && !disableBadges
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onContainsMouseChanged: toggleMinimum(containsMouse)
                onDoubleClicked: ad_list.windowRequest(list_item.dItem)
                onPressed: {
                    if( mouse.button == Qt.RightButton ) {
                        var actions, res
                        if(dItem.encrypted) {
                            actions = [qsTr("Open in New Window"), qsTr("Delete")]
                            res = Desktop.showMenu(actions)
                            switch(res) {
                            case 0:
                                ad_list.windowRequest(list_item.dItem)
                                break;
                            case 1:
                                if( Desktop.yesOrNo(View, qsTr("Delete secret chat"), qsTr("Are you sure about deleting this secret chat?")) )
                                    telegramObject.messagesDiscardEncryptedChat(dItem.peer.userId)
                                break;
                            }
                        } else if(user.id == telegramObject.cutegramId) {
                            actions = [qsTr("Delete")]
                            res = Desktop.showMenu(actions)
                            switch(res) {
                            case 0:
                                telegramObject.deleteCutegramDialog()
                                break;
                            }
                        } else if(isChat) {
                            actions = [qsTr("Open in New Window"), qsTr("Delete History")]
                            res = Desktop.showMenu(actions)
                            switch(res) {
                            case 0:
                                ad_list.windowRequest(list_item.dItem)
                                break;
                            case 1:
                                if( Desktop.yesOrNo(View, qsTr("Delete History"), qsTr("Are you sure about deleting history?")) )
                                    telegramObject.messagesDeleteHistory(dItem.peer.chatId)
                                break;
                            }
                        } else {
                            var notifyValue = telegramObject.userData.notify(dItem.peer.userId)
                            var notifyOnline = notifyValue & UserData.NotifyOnline
                            var notifyTyping = notifyValue & UserData.NotifyTyping
                            var notifyMenu = {"text": qsTr("Notify when"),
                                "list":[{"text": qsTr("Go online"), "checkable": true, "checked": notifyOnline}]}
//                                        {"text": qsTr("Start typing"), "checkable": true, "checked": notifyTyping}]}

                            actions = [qsTr("Open in New Window"), qsTr("Delete History"), notifyMenu]
                            res = Desktop.showMenu(actions)
                            switch(res) {
                            case 0:
                                ad_list.windowRequest(list_item.dItem)
                                break;
                            case 1:
                                if( Desktop.yesOrNo(View, qsTr("Delete History"), qsTr("Are you sure about deleting history?")) )
                                    telegramObject.messagesDeleteHistory(dItem.peer.userId)
                                break;
                            case 2:
                                var withoutOnline = (notifyValue-notifyOnline)
                                notifyOnline = notifyOnline? 0 : UserData.NotifyOnline
                                telegramObject.userData.setNotify(dItem.peer.userId, notifyOnline|withoutOnline)
                                break;
                            case 3:
                                var withoutTyping = (notifyValue-notifyTyping)
                                notifyTyping = notifyTyping? 0 : UserData.NotifyTyping
                                telegramObject.userData.setNotify(dItem.peer.userId, notifyTyping|withoutTyping)
                                break;
                            }
                        }
                    }
                }
                onClicked: {
                    if( mouse.button == Qt.LeftButton )
                        currentDialog = list_item.dItem
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
                        return Cutegram.currentTheme.dialogListLightIcon? "files/contact-light.png" : "files/contact.png"
                    else
                    if( section == 1 )
                        return Cutegram.currentTheme.dialogListLightIcon? "files/favorite-light.png" : "files/favorite.png"
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
        animated: Cutegram.smoothScroll
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
        scrollArea: dlist; height: dlist.height; width: Cutegram.currentTheme.dialogListScrollWidth*Devices.density
        anchors.right: dlist.left; anchors.top: dlist.top; color: Cutegram.currentTheme.dialogListScrollColor
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
        visible: false

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

    function next() {
        var dialog = dialogs_model.at(dlist.currentIndex+1)
        if(!dialog)
            return

        currentDialog = dialog
    }

    function previous() {
        var dialog = dialogs_model.at(dlist.currentIndex-1)
        if(!dialog)
            return

        currentDialog = dialog
    }
}
