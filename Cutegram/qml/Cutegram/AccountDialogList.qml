import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    width: 100
    height: 62

    property alias telegramObject: dialogs_model.telegram
    property Dialog currentDialog: telegramObject.dialog(0)

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
        light: false
        modern: true
        indicatorSize: 20*Devices.density
    }

    ListView {
        id: dlist
        anchors.fill: parent
        anchors.rightMargin: 6*Devices.density
        clip: true
        model: dialogs_model
        delegate: Rectangle {
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

            Rectangle {
                anchors.fill: parent
                color: marea.pressed || selected? masterPalette.highlight : "#00000000"
                opacity: marea.pressed? 0.3 : (selected? 0.2 : 0)
            }

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
                color: textColor0
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                text: isChat? chat.title : user.firstName + " " + user.lastName
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
                color: textColor2
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                clip: true
                text: {
                    var list = dItem.typingUsers
                    if( list.length )
                        return qsTr("Typing...")
                    else
                        return emojis.textToEmojiText(message.message)
                }
            }

            Text {
                id: time_txt
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4*Devices.density
                font.family: AsemanApp.globalFontFamily
                font.pixelSize: 9*Devices.fontDensity
                color: textColor1
                text: Cutegram.getTimeString(msgDate)
            }

            UnreadItem {
                unread: dItem.unreadCount
                visible: unread != 0 && !selected
            }

            MouseArea {
                id: marea
                hoverEnabled: true
                anchors.fill: parent
                onClicked: currentDialog = list_item.dItem
            }

            DialogItemTools {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                height: 22*Devices.density
                dialog: dItem
                show: marea.containsMouse
            }

            DialogDropFile {
                anchors.fill: parent
                currentDialog: dItem
                color: "#ddffffff"
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

    NormalWheelScroll {
        flick: dlist
    }

    PhysicalScrollBar {
        scrollArea: dlist; height: dlist.height; width: 6*Devices.density
        anchors.left: dlist.right; anchors.top: dlist.top; color: textColor0
    }
}
