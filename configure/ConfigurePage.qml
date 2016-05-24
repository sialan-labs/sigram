import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

ToolKit.AccountPageItem {
    id: confPage

    property variant engine

    delegate: Item {
        anchors.fill: parent

        Flickable {
            id: flick
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: inner.height

            ConfigurePageInner {
                id: inner
                width: flick.width
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

