import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    width: 300*Devices.density
    height: 400*Devices.density

    property alias currentDialog: cp_model.dialog

    ChatParticipantsModel {
        id: cp_model
        telegram: telegramObject
        onRefreshingChanged: {
            if( refreshing )
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

    GridView {
        id: list
        anchors.fill: parent
        model: cp_model
        cellWidth: width/Math.floor(width/(70*Devices.density))
        cellHeight: 70*Devices.density
        clip: true
        delegate: Item {
            id: glist_item
            width: list.cellWidth
            height: list.cellHeight

            property ChatParticipant cpItem: item
            property User user: telegramObject.user(cpItem.userId)

            ContactImage {
                id: contact_img
                anchors.top: parent.top
                anchors.bottom: txt.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: height
                user: glist_item.user
                isChat: false

                Image {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    source: "files/online.png"
                    sourceSize: Qt.size(width,height)
                    width: 14*Devices.density
                    height: 14*Devices.density
                    visible: (user.status.classType == contact_img.typeUserStatusOnline)
                }
            }

            Text {
                id: txt
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 1
                color: Desktop.titleBarTextColor
                text: user.firstName + " " + user.lastName
            }
        }
    }

    NormalWheelScroll {
        flick: list
        animated: Cutegram.smoothScroll
    }

    ScrollBar {
        scrollArea: list; height: list.height; width: 6*Devices.density
        anchors.right: list.right; anchors.top: list.top; color: textColor0; forceVisible: true
    }

    Indicator {
        anchors.centerIn: parent
    }
}
