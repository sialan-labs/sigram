import QtQuick 2.0
import AsemanTools.Controls 1.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    width: 100
    height: 62
    visible: smodel.count != 0 || smodel.initializing

    property alias telegramObject: smodel.telegram
    property alias keyword: smodel.keyword

    property Message currentMessage: telegramObject.nullMessage

    SearchModel {
        id: smodel
        onCountChanged: currentMessage = telegramObject.nullMessage
    }

    Indicator {
        anchors.fill: parent
        light: Cutegram.currentTheme.dialogListLightIcon
        modern: true
        indicatorSize: 22*Devices.density
        property bool active: smodel.initializing

        onActiveChanged: {
            if( active )
                start()
            else
                stop()
        }
    }

    ListView {
        id: listv
        anchors.fill: parent
        anchors.leftMargin: 6*Devices.density
        model: smodel
        delegate: Item {
            id: ditem
            width: listv.width
            height: 54*Devices.density
            clip: true

            property Message message: item
            property int dialogId: telegramObject.messageDialogId(message.id)
            property Dialog dialog: telegramObject.dialog(dialogId)
            property User user: telegramObject.user(message.fromId)

            property variant msgDate: CalendarConv.fromTime_t(message.date)

            property bool selected: currentMessage==item

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                anchors.rightMargin: -radius
                radius: 5*Devices.density
                color: {
                    var result = "#00000000"
                    if(marea.pressed || selected) {
                        result = Cutegram.currentTheme.dialogListHighlightColor
                    }

                    return result
                }
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                anchors.leftMargin: 5*Devices.density
                anchors.rightMargin: 12*Devices.density

                Frame {
                    id: img
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: height
                    anchors.margins: 4*Devices.density
                    backgroundColor: selected || marea.pressed? Cutegram.currentTheme.dialogListHighlightColor : Cutegram.currentTheme.dialogListBackground

                    ContactImage {
                        anchors.fill: parent
                        user: ditem.user
                        isChat: false
                        circleMode: false
                    }
                }

                Text {
                    id: time_txt
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4*Devices.density
                    font.family: Cutegram.currentTheme.dialogListDateFont.family
                    font.pixelSize: Math.floor(Cutegram.currentTheme.dialogListDateFont.pointSize*Devices.fontDensity)
                    color: marea.pressed || selected? Cutegram.currentTheme.dialogListHighlightDateColor : Cutegram.currentTheme.dialogListDateColor
                    text: Cutegram.getTimeString(msgDate)
                }

                Text {
                    id: title_txt
                    anchors.top: parent.top
                    anchors.left: img.right
                    anchors.right: parent.right
                    anchors.bottom: parent.verticalCenter
                    anchors.leftMargin: 8*Devices.density
                    anchors.rightMargin: 8*Devices.density
                    font.family: Cutegram.currentTheme.dialogListFont.family
                    font.pixelSize: Math.floor(Cutegram.currentTheme.dialogListFont.pointSize*Devices.fontDensity)
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: marea.pressed || selected? Cutegram.currentTheme.dialogListHighlightTextColor : Cutegram.currentTheme.dialogListFontColor
                    text: {
                        var isChat = dialog.peer.chatId != 0
                        var fromName = user.firstName + " " + user.lastName
                        fromName = fromName.trim()
                        if(message.out)
                            fromName = qsTr("Me")

                        var result
                        if(isChat) {
                            var chat = telegramObject.chat(dialogId)
                            result = qsTr("%1 on %2").arg(fromName).arg(chat.title)
                        } else {
                            var toUser = telegramObject.user(dialogId)
                            var userName = toUser.firstName + " " + toUser.lastName
                            userName = userName.trim()
                            if(!message.out)
                                userName = qsTr("Me")

                            result = qsTr("%1 to %2").arg(fromName).arg(userName)
                        }

                        return result
                    }
                }

                Text {
                    anchors.left: img.right
                    anchors.right: parent.right
                    anchors.top: parent.verticalCenter
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 8*Devices.density
                    anchors.rightMargin: 8*Devices.density
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: message.message
                    font.family: Cutegram.currentTheme.dialogListMessageFont.family
                    font.pixelSize: Math.floor(Cutegram.currentTheme.dialogListMessageFont.pointSize*Devices.fontDensity)
                    color: marea.pressed || selected? Cutegram.currentTheme.dialogListHighlightMessageColor : Cutegram.currentTheme.dialogListMessageColor
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: currentMessage = message
            }

            Rectangle {
                x: listv.width - width/2
                anchors.verticalCenter: parent.verticalCenter
                transformOrigin: Item.Center
                rotation: 45
                width: Cutegram.currentTheme.dialogPointerHeight*Devices.density
                height: width
                color: Cutegram.currentTheme.dialogPointerColor
                visible: selected
            }
        }
    }

    NormalWheelScroll {
        flick: listv
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.right: listv.left; anchors.top: listv.top; color: "#777777"
    }
}

