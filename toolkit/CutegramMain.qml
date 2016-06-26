import QtQuick 2.3
import AsemanTools 1.0
import TelegramQml 2.0
import TelegramQml 2.0 as Telegram
import "../account" as Account
import "../toolkit" as ToolKit
import "../globals"

ToolKit.TgRectangle {
    id: cutegramMain
    focus: true
    engine: {
        if(listv.currentItem)
            return listv.currentItem.engine
        else
            return null
    }
    currentPeer: {
        if(listv.currentItem)
            return listv.currentItem.currentPeer
        else
            return null
    }

    property ProfileManagerModel profilesModel

    Keys.onEscapePressed: BackHandler.back()
    Keys.onPressed: {
        if (event.modifiers == Qt.ControlModifier) {
            switch(event.key) {
            case Qt.Key_Q:
                AsemanApp.exit(0)
                break;
            case Qt.Key_K:
            case Qt.Key_F:
                if(listv.currentItem) listv.currentItem.focusOnSearch()
                break;
            }
        }
    }

    ListView {
        id: listv
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        displayMarginBeginning: 100000
        displayMarginEnd: 100000
        width: parent.width
        clip: true
        interactive: false
        orientation: ListView.Horizontal
        highlightMoveDuration: 0
        highlightMoveVelocity: -1
        highlightRangeMode: ListView.StrictlyEnforceRange
        model: profilesModel
        currentIndex: toolbar.currentProfileIndex
        delegate: Account.AccountMain {
            width: listv.width
            height: listv.height
            engine: model.engine
        }
    }

    ToolKit.MainToolBar {
        id: toolbar
        y: profilesModel.count!=1 || !profilesModel.initializing? 0 : -height
        width: parent.width
        engine: cutegramMain.engine
        currentPeer: cutegramMain.currentPeer
        profileManager: profilesModel
        detailMode: listv.currentItem? listv.currentItem.detailMode : false
        onDetailRequest: if(listv.currentItem) listv.currentItem.toggleDetails()
        onMediaRequest: if(listv.currentItem) listv.currentItem.toggleMedias()
        onSearchRequest: if(listv.currentItem) listv.currentItem.searchRequest(peer)

        Behavior on y {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
        }
    }
}

