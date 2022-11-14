import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../sidebar" as Sidebar
import "../messages" as Messages
import "../configure" as Configure
import "../contacts" as Contacts
import "../add" as Add
import "../globals"

Rectangle {
    id: accMain
    color: "#f7f7f7"

    property alias engine: home.engine
    property alias currentPeer: home.currentPeer
    property alias categoriesSettings: home.categoriesSettings
    property alias detailMode: home.detailMode
    readonly property bool refreshing: home.refreshing || addPage.refreshing || contactPage.refreshing || configure.refreshing

    onCurrentPeerChanged: if(!currentPeer) home.backToMessages()

    PanelBar {
        id: panel
        height: parent.height
    }

    Item {
        id: pages
        anchors.left: panel.right
        anchors.right: parent.right
        height: parent.height

        AccountHome {
            id: home
            type: CutegramEnums.pageTypeHome
            currentType: panel.currentPage
            onOpenedChanged: {
                if(!opened)
                    BackHandler.pushHandler(home, function(){panel.currentPage = CutegramEnums.pageTypeHome})
                else
                    BackHandler.removeHandler(home)
            }
        }

        Add.AddNewPage {
            id: addPage
            engine: accMain.engine
            type: CutegramEnums.pageTypeAdd
            currentType: panel.currentPage
        }

        Contacts.ContactsPage {
            id: contactPage
            engine: accMain.engine
            type: CutegramEnums.pageTypeContacts
            currentType: panel.currentPage
            addButton: true
            onContactActivated: {
                home.currentPeer = peer
                panel.currentPage = CutegramEnums.pageTypeHome
            }
        }

        Configure.ConfigurePage {
            id: configure
            engine: accMain.engine
            type: CutegramEnums.pageTypeConfigure
            currentType: panel.currentPage
        }
    }

    function toggleDetails() {
        home.toggleDetails()
    }

    function toggleMedias() {
        home.toggleMedias()
    }

    function searchRequest(peer) {
        home.searchRequest(peer)
    }

    function focusOnSearch() {
        home.focusOnSearch()
    }
}

