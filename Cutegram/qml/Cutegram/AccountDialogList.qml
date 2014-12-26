import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: ad_list
    width: minimum? 80*Devices.density : dlist.width

    property alias telegramObject: dialogs_model.telegram
    property Dialog currentDialog: telegramObject.dialog(0)

    property bool unminimumForce: false
    property bool minimum: Cutegram.minimumDialogs && !unminimumForce

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
        width: 275*Devices.density
        height: parent.height
        anchors.leftMargin: 6*Devices.density
        clip: true
        model: dialogs_model

        delegate: Item {
            id: list_item
            width: dlist.width
            height: 60*Devices.density
            clip: true

            property Dialog dItem: item
            property bool isChat: dItem.peer.chatId != 0
            property User user: telegramObject.user(dItem.peer.userId)
            property Chat chat: telegramObject.chat(dItem.peer.chatId)
            property Message message: telegramObject.message(dItem.topMessage)
            property variant msgDate: CalendarConv.fromTime_t(message.date)

            property bool selected: currentDialog==dItem
            property real itemOpacities: minimum? 0 : 1

            Behavior on itemOpacities {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Rectangle {
                anchors.fill: parent
                color: marea.pressed || selected? masterPalette.highlight : "#00000000"
                opacity: marea.pressed? 0.3 : (selected? 0.2 : 0)
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
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
                }

                Text {
                    id: title_txt
                    anchors.top: parent.top
                    anchors.bottom: parent.verticalCenter
                    anchors.left: profile_img.right
                    anchors.right: time_txt.left
                    anchors.margins: 4*Devices.density
                    anchors.bottomMargin: 0
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 11*Devices.fontDensity
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    color: "#ffffff"
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    text: isChat? chat.title : user.firstName + " " + user.lastName
                    opacity: itemOpacities
                }

                Text {
                    id: msg_txt
                    anchors.top: parent.verticalCenter
                    anchors.bottom: parent.bottom
                    anchors.left: profile_img.right
                    anchors.right: parent.right
                    anchors.margins: 4*Devices.density
                    anchors.topMargin: 0
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#bbbbbb"
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    clip: true
                    opacity: itemOpacities
                    text: {
                        var list = dItem.typingUsers
                        if( list.length )
                            return qsTr("Typing...")
                        else
                            return emojis.textToEmojiText(message.message,14)
                    }
                }

                Text {
                    id: time_txt
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4*Devices.density
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#999999"
                    text: Cutegram.getTimeString(msgDate)
                    opacity: itemOpacities
                }

                UnreadItem {
                    unread: dItem.unreadCount
                    visible: unread != 0 && !selected
                }
            }

            MouseArea {
                id: marea
                hoverEnabled: true
                anchors.fill: parent
                onClicked: currentDialog = list_item.dItem
                onContainsMouseChanged: toggleMinimum(containsMouse)
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
                currentDialog: dItem
                color: "#ddffffff"
                onContainsDragChanged: toggleMinimum(containsDrag)
            }

            Rectangle {
                x: ad_list.width - width/2
                anchors.verticalCenter: parent.verticalCenter
                transformOrigin: Item.Center
                rotation: 45
                width: 16*Devices.density
                height: width
                color: "#E4E9EC"
                visible: selected
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
