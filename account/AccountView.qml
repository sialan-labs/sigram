import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../sidebar" as Sidebar
import "../messages" as Messages
import "../configure" as Configure
import "../globals"

Rectangle {
    id: accMain
    color: "#f7f7f7"

    property alias engine: home.engine
    property alias currentPeer: home.currentPeer
    property alias categoriesSettings: home.categoriesSettings
    property alias detailMode: home.detailMode

    onCurrentPeerChanged: if(!currentPeer) home.closeDetails()

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
}

