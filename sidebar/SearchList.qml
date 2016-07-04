import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    id: searchList

    property alias engine: searchModel.engine
    property alias currentPeer: searchModel.currentPeer
    property string keyword
    property alias count: listv.count

    readonly property bool refreshing: searchModel.refreshing || dialogModel.refreshing || details.refreshing

    onKeywordChanged: {
        refreshTimer.stop()
        if(keyword.length)
            refreshTimer.start()
        else
            searchModel.keyword = ""

        listv.currentIndex = -1
    }

    signal loadRequest(variant peer, variant message)

    Timer {
        id: refreshTimer
        interval: 500
        repeat: false
        onTriggered: searchModel.keyword = keyword
    }

    Telegram.PeerDetails {
        id: details
        engine: searchModel.engine
        username: searchModel.keyword
        onDisplayNameChanged: {
            lookupModel.clear()
            if(displayName.length) {
                lookupModel.append({"details": details})
            }
        }
    }

    Telegram.MessageSearchModel {
        id: searchModel
        objectName: "Messages"
    }

    Telegram.DialogListModel {
        id: dialogModel
        objectName: "Dialogs"
        engine: searchModel.keyword.length? searchModel.engine : null
        filter: searchModel.keyword
    }

    ListModel {
        id: lookupModel
        objectName: "Users"
    }

    MixedListModel {
        id: mixModel
        models: currentPeer? [searchModel] : [lookupModel, dialogModel, searchModel]
    }

    AsemanListView {
        id: listv
        anchors.fill: parent
        clip: true
        currentIndex: -1
        highlightMoveDuration: 0
        highlightMoveVelocity: -1
        model: mixModel
        delegate: Item {
            id: item
            width: listv.width
            height: searchItem? searchItem.height : 64*Devices.density

            property Item searchItem

            Component {
                id: lookup_item_component
                SearchListLookupItem {
                    width: listv.width
                    onLoadRequest: {
                        searchList.loadRequest(peer, null)
                        listv.currentIndex = model.index
                    }
                }
            }

            Component {
                id: message_item_component
                SearchListMessageItem {
                    width: listv.width
                    engine: searchModel.engine
                    onLoadRequest: {
                        searchList.loadRequest(peer, message)
                        listv.currentIndex = model.index
                    }
                }
            }

            Component {
                id: dialogs_item_component
                ToolKit.DialogListItem {
                    width: listv.width
                    height: 64*Devices.density
                    engine: searchModel.engine
                    showButtons: false
                    onActive: {
                        searchList.loadRequest(model.peer, null)
                        listv.currentIndex = model.index
                    }
                }
            }

            Component.onCompleted: {
                if(model.modelObject == searchModel)
                    searchItem = message_item_component.createObject(item)
                else
                if(model.modelObject == lookupModel)
                    searchItem = lookup_item_component.createObject(item)
                else
                if(model.modelObject == dialogModel)
                    searchItem = dialogs_item_component.createObject(item)
            }
        }

        highlight: Rectangle {
            width: listv.width
            height: 64*Devices.density
            color: CutegramGlobals.foregroundColor
        }

        section.property: "modelName"
        section.delegate: Rectangle {
            width: listv.width
            height: 30*Devices.density

            Text {
                text: section
                font.pixelSize: 10*Devices.fontDensity
                color: CutegramGlobals.baseColor
                x: y
                anchors.verticalCenter: parent.verticalCenter
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
        color: CutegramGlobals.baseColor
        scrollArea: listv
    }

    Indicator {
        id: indicator
        running: keyword.length && searchModel.refreshing
        anchors.centerIn: parent
        modern: true
        light: false
        indicatorSize: 18*Devices.density
    }
}

