import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
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

    readonly property bool refreshing: item? item.refreshing : false

    signal peerSelected(variant peer)
    signal clearHistoryRequest(variant inputPeer)
    signal deleteDialogRequest(variant inputPeer)

    delegate: Item {
        anchors.fill: parent

        NullMouseArea { anchors.fill: parent }

        readonly property bool refreshing: mlmodel.refreshing || (mbrlist.headerItem? mbrlist.headerItem.refreshing : false)

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
                onClearHistoryRequest: dialog.clearHistoryRequest(inputPeer)
                onDeleteDialogRequest: dialog.deleteDialogRequest(inputPeer)
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

