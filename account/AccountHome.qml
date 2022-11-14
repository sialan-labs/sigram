import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../sidebar" as Sidebar
import "../messages" as Messages
import "../globals"
import "../medias" as Medias

ToolKit.AccountPageItem {
    id: accHome

    property alias engine: sidebar.engine
    property alias currentPeer: sidebar.currentPeer
    property alias categoriesSettings: sidebar.categoriesSettings

    property alias currentPage: messagesFrame.currentType

    readonly property bool detailMode: currentPage != CutegramEnums.homeTypeMessages
    readonly property bool refreshing: sidebar.refreshing || messagesFrame.refreshing || details.refreshing || medias.refreshing

    onCurrentPageChanged: {
        if(currentPage != CutegramEnums.homeTypeMessages)
            BackHandler.pushHandler(accHome, function(){ backToMessages() })
        else
            BackHandler.removeHandler(accHome)
    }

    Sidebar.Sidebar {
        id: sidebar
        height: parent.height
        width: CutegramSettings.sideBarWidth * Devices.density
        z: 10
        onLoadMessageRequest: messagesFrame.loadFrom(message)
        onCurrentPeerChanged: {
            if(currentPeer) {
                BackHandler.removeHandler(sidebar)
                BackHandler.pushHandler(sidebar, function(){sidebar.currentPeer = null})
                if(currentPage != CutegramEnums.homeTypeMessages) {
                    BackHandler.removeHandler(accHome)
                    BackHandler.pushHandler(accHome, function(){ backToMessages() })
                }
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

    Item {
        id: homeScene
        anchors.left: splitter.right
        anchors.right: parent.right
        height: parent.height
        clip: true

        Messages.MessagesFrame {
            id: messagesFrame
            width: parent.width
            height: parent.height
            engine: accHome.engine
            currentPeer: accHome.currentPeer
            type: CutegramEnums.homeTypeMessages
        }

        ToolKit.DialogDetails {
            id: details
            height: messagesFrame.height
            width: messagesFrame.width
            engine: accHome.engine
            currentPeer: visible? accHome.currentPeer : null
            categoriesSettings: sidebar.categoriesSettings
            type: CutegramEnums.homeTypeDetails
            currentType: currentPage
            onPeerSelected: {
                accHome.currentPeer = peer
                BackHandler.removeHandler(details)
                BackHandler.pushHandler(details, backToMessages)
            }
            onClearHistoryRequest: sidebar.clearHistory(inputPeer, true)
            onDeleteDialogRequest: sidebar.clearHistory(inputPeer, false)
        }

        Medias.PeerMedias {
            id: medias
            type: CutegramEnums.homeTypeMedias
            currentType: currentPage
            engine: accHome.engine
            currentPeer: visible? accHome.currentPeer : null
            onForwardRequest: {
                backToMessages()
                messagesFrame.forwardDialog(msgIds)
            }
        }
    }

    function backToMessages() {
        currentPage = CutegramEnums.homeTypeMessages
    }

    function toggleDetails() {
        if(!currentPeer)
            return

        switch(currentPage)
        {
        case CutegramEnums.homeTypeDetails:
            currentPage = CutegramEnums.homeTypeMessages
            break
        case CutegramEnums.homeTypeMessages:
        case CutegramEnums.homeTypeMedias:
            currentPage = CutegramEnums.homeTypeDetails
            break
        }
    }

    function toggleMedias() {
        if(!currentPeer)
            return

        switch(currentPage)
        {
        case CutegramEnums.homeTypeMedias:
            currentPage = CutegramEnums.homeTypeMessages
            break
        case CutegramEnums.homeTypeMessages:
        case CutegramEnums.homeTypeDetails:
            currentPage = CutegramEnums.homeTypeMedias
            break
        }
    }

    function searchRequest(peer) {
        sidebar.searchRequest(peer)
    }

    function focusOnSearch() {
        sidebar.focusOnSearch()
    }
}

