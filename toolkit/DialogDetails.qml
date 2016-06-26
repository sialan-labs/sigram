import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

AccountHomeItem {
    id: dialog
    color: "#fefefe"

    property Engine engine
    property InputPeer currentPeer
    property Settings categoriesSettings

    signal peerSelected(variant peer)

    delegate: Item {
        anchors.fill: parent

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

            header: DialogDetailsHeader {
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
}

