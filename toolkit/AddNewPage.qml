import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

AccountPageItem {
    id: addNewPage

    property variant engine
    readonly property bool refreshing: item? item.refreshing : false

    delegate: Item {
        anchors.fill: parent
    }
}

