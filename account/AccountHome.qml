import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../sidebar" as Sidebar
import "../messages" as Messages
import "../globals"

ToolKit.AccountPageItem {
    id: accHome

    property alias engine: sidebar.engine
    property alias currentPeer: sidebar.currentPeer
    property alias categoriesSettings: sidebar.categoriesSettings

    readonly property bool detailMode: details.opened

    Sidebar.Sidebar {
        id: sidebar
        height: parent.height
        width: CutegramSettings.sideBarWidth
        z: 10
        onLoadMessageRequest: messagesFrame.loadFrom(message)
        onCurrentPeerChanged: {
            if(currentPeer) {
                BackHandler.removeHandler(sidebar)
                BackHandler.pushHandler(sidebar, function(){sidebar.currentPeer = null})
            } else {
                BackHandler.removeHandler(sidebar)
            }
        }
        onForwardRequest: messagesFrame.forwardRequest(inputPeer, [msgId])
    }

    Rectangle {
        id: splitter
        anchors.left: sidebar.right
        width: 1*Devices.density
        height: parent.height
        color: CutegramGlobals.foregroundColor
        z: 5
    }

    Messages.MessagesFrame {
        id: messagesFrame
        x: splitter.x + splitter.width - details.opacity*50*Devices.density
        width: parent.width - (splitter.x + splitter.width)
        height: parent.height
        engine: accHome.engine
        currentPeer: accHome.currentPeer
    }

    ToolKit.DialogDetails {
        id: details
        height: messagesFrame.height
        width: messagesFrame.width
        x: splitter.x + splitter.width + (1-opacity)*100*Devices.density
        opacity: opened? 1 : 0
        visible: opacity != 0
        engine: accHome.engine
        currentPeer: visible? accHome.currentPeer : null
        categoriesSettings: sidebar.categoriesSettings

        property bool opened: false

        onOpenedChanged: {
            if(opened)
                BackHandler.pushHandler(details, function(){details.opened = false})
            else
                BackHandler.removeHandler(details)
        }

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
        }
    }

    function closeDetails() {
        details.opened = false
    }

    function toggleDetails() {
        if(!currentPeer)
            return
        details.opened = !details.opened
    }

    function searchRequest(peer) {
        sidebar.searchRequest(peer)
    }

    function focusOnSearch() {
        sidebar.focusOnSearch()
    }
}

