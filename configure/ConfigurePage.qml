import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

ToolKit.AccountPageItem {
    id: confPage

    property variant engine
    readonly property bool refreshing: item? item.refreshing : false

    delegate: Item {
        anchors.fill: parent

        property alias refreshing: inner.refreshing

        Flickable {
            id: flick
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: inner.height

            ConfigurePageInner {
                id: inner
                width: flick.width
                engine: confPage.engine
            }
        }

        NormalWheelScroll {
            flick: flick
        }

        PhysicalScrollBar {
            anchors.right: flick.right
            height: flick.height
            width: 6*Devices.density
            color: CutegramGlobals.baseColor
            scrollArea: flick
        }
    }
}

