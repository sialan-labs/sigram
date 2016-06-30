import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0
import TelegramQml 2.0 as Telegram
import "../authenticating" as Authenticating
import "../toolkit" as ToolKit
import "../globals"

ToolKit.TgRectangle {
    id: account
    currentPeer: {
        if(accountView)
            return accountView.currentPeer
        else
            return null
    }

    property Item authPage
    property AccountView accountView
    readonly property bool detailMode: accountView? accountView.detailMode : false
    readonly property bool refreshing: accountView? accountView.refreshing : false

    signal signedIn()

    Connections {
        target: engine
        onStateChanged: {
            console.debug("Engine state changed: %1".arg(engine.state))
            checkAuth(false)
        }
    }

    Component {
        id: auth_component
        Authenticating.AuthPage {
            anchors.fill: parent
            engine: account.engine
        }
    }

    Component {
        id: account_component
        AccountView {
            anchors.fill: parent
            engine: account.engine
        }
    }

    function checkAuth(firstInitialize) {
        if(phoneNumber.length == 0 || engine.state == Telegram.Engine.AuthNeeded) {
            if(!authPage) authPage = auth_component.createObject(account)
            if(accountView) accountView.destroy()
        } else
        if(engine.state == Telegram.Engine.AuthLoggedIn || firstInitialize)
        {
            if(authPage) authPage.destroy()
            if(!accountView) {
                accountView = account_component.createObject(account)
            }
            if(!firstInitialize) signedIn()
        }
    }

    function toggleDetails() {
        if(accountView)
            accountView.toggleDetails()
    }

    function toggleMedias() {
        if(accountView)
            accountView.toggleMedias()
    }

    function searchRequest(peer) {
        if(accountView)
            accountView.searchRequest(peer)
    }

    function focusOnSearch() {
        if(accountView)
            accountView.focusOnSearch()
    }

    Component.onCompleted: checkAuth(true)
}

