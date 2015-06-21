import QtQuick 2.0
import QtGraphicalEffects 1.0
import AsemanTools.Controls 1.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    width: 100
    height: 62

    property alias telegram: contact.telegram
    property alias dialog: contact.dialog
    property alias isChat: contact.isChat
    property alias user: contact.user
    property alias chat: contact.chat

    Frame {
        id: item
        width: parent.width*2
        height: parent.height*2
        visible: false
        shadowSize: 0.8
        radius: 10*Devices.density
        scale: 2

        ContactImage {
            id: contact
            anchors.fill: parent
            circleMode: false
        }
    }

    Item {
        id: mask
        anchors.fill: item
        visible: false

        Rectangle {
            radius: item.radius
            anchors.fill: parent
            anchors.margins: 1*Devices.density
        }
    }

    OpacityMask {
        anchors.fill: item
        transformOrigin: Item.TopLeft
        source: item
        maskSource: mask
        smooth: true
        scale: 0.5
    }
}

