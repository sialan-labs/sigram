import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {

    property alias engine: searchModel.engine
    property alias currentPeer: searchModel.currentPeer
    property alias keyword: searchModel.keyword
    property alias count: listv.count

    Telegram.MessageSearchModel {
        id: searchModel
    }

    AsemanListView {
        id: listv
        anchors.fill: parent
        clip: true
        model: searchModel
        delegate: Item {
            id: item
            height: 64*Devices.density
            width: listv.width

            Row {
                width: parent.width - 20*Devices.density
                anchors.centerIn: parent

                ToolKit.ProfileImage {
                    height: 42*Devices.density
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    engine: searchModel.engine
                    source: model.fromUserItem
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        font.pixelSize: 10*Devices.fontDensity
                        color: "#333333"
                        text: (model.fromUserItem.firstName + " " + model.fromUserItem.lastName).trim()
                    }

                    Text {
                        font.pixelSize: 10*Devices.fontDensity
                        color: "#666666"
                        text: model.message
                    }
                }
            }
        }
    }

    NormalWheelScroll {
        flick: listv
    }

    PhysicalScrollBar {
        anchors.right: listv.right
        height: listv.height
        width: 6*Devices.density
        color: "#888888"
        scrollArea: listv
    }

    Indicator {
        id: indicator
        running: keyword.length && count==0
        anchors.centerIn: parent
        modern: true
        light: false
        indicatorSize: 18*Devices.density
    }
}

