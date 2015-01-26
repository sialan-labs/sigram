import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    width: 100
    height: 62

    property alias telegramObject: smodel.telegram
    property alias keyword: smodel.keyword

    property Message currentMessage: telegramObject.nullMessage

    SearchModel {
        id: smodel
        onCountChanged: currentMessage = telegramObject.nullMessage
    }

    Indicator {
        anchors.fill: parent
        light: true
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
        visible: count != 0
        delegate: Item {
            id: ditem
            width: listv.width
            height: 54*Devices.density
            clip: true

            property Message message: item
            property int dialogId: telegramObject.messageDialogId(message.id)
            property Dialog dialog: telegramObject.dialog(dialogId)
            property User user: telegramObject.user(message.fromId)

            property bool selected: currentMessage==item

            Rectangle {
                anchors.fill: parent
                opacity: marea.pressed? 0.3 : (selected? 0.2 : 0)
                anchors.topMargin: 3*Devices.density
                anchors.bottomMargin: 3*Devices.density
                color: {
                    var result = "#00000000"
                    if(marea.pressed || selected) {
                        result = Cutegram.highlightColor
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

                ContactImage {
                    id: img
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: height
                    anchors.margins: 4*Devices.density
                    circleMode: false
                    user: ditem.user
                    isChat: false
                }

                Text {
                    anchors.left: img.right
                    anchors.right: parent.right
                    anchors.margins: 8*Devices.density
                    anchors.verticalCenter: parent.verticalCenter
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: message.message
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#eeeeee"
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
                width: 16*Devices.density
                height: width
                color: "#E4E9EC"
                visible: selected
            }
        }
    }

    NormalWheelScroll {
        flick: listv
    }

    PhysicalScrollBar {
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.right: listv.left; anchors.top: listv.top; color: "#777777"
    }
}

