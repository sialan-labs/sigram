import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Rectangle {
    id: dialog
    color: "#fefefe"

    property alias engine: mlmodel.engine
    property alias currentPeer: mlmodel.currentPeer
    property Settings categoriesSettings

    signal peerSelected(variant peer)

    NullMouseArea { anchors.fill: parent }

    Telegram.MembersListModel {
        id: mlmodel
        engine: dialog.engine
        currentPeer: dialog.currentPeer
    }

    UserList {
        id: mbrlist
        anchors.fill: parent
        anchors.leftMargin: 28*Devices.density
        anchors.rightMargin: anchors.leftMargin
        model: mlmodel
        engine: dialog.engine
        onPeerSelected: dialog.peerSelected(peer)

        header: ToolKit.DialogDetailsHeader {
            id: ddheader
            width: mbrlist.width
            engine: dialog.engine
            currentPeer: dialog.currentPeer
            categoriesSettings: dialog.categoriesSettings
        }
    }

    NormalWheelScroll {
        flick: mbrlist
    }

    PhysicalScrollBar {
        anchors.right: parent.right
        height: mbrlist.height
        width: 6*Devices.density
        color: CutegramGlobals.baseColor
        scrollArea: mbrlist
    }
}

