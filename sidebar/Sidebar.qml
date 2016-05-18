import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Rectangle {
    id: sidebar
    color: "#fefefe"

    property alias engine: dlist.engine
    property alias currentPeer: dlist.currentPeer

    property alias categoriesSettings: categories_settings
    property bool signalBlocker: false

    signal forwardRequest(variant inputPeer, int msgId)
    signal loadMessageRequest(variant message)

    Settings {
        id: categories_settings
        source: CutegramGlobals.profilePath + "/" + engine.phoneNumber + "/categories.ini"
        category: "Categories"

        onValueChanged: refresh()
        Component.onCompleted: refresh()

        function refresh() {
            if(signalBlocker)
                return

            signalBlocker = true
            var list = keys()
            var cats = {"0":0}
            for(var i=0; i<list.length; i++) {
                var key = list[i]
                cats[key] = value(key)
            }
            dlist.categories = cats
            signalBlocker = false
        }
    }
    Settings {
        id: account_settings
        source: CutegramGlobals.profilePath + "/" + engine.phoneNumber + "/settings.ini"
        category: "General"

        property int dialogsFilter: 0
        property int dialogsSort: 0
    }

    SearchBar {
        id: searchbar
        anchors.top: parent.top
        width: parent.width
        engine: sidebar.engine
    }

    Rectangle {
        id: comboLists
        anchors.top: searchbar.bottom
        width: parent.width
        height: 33*Devices.density
        color: "#e6e6e6"
        visible: !searchList.visible
        z: 10

        ToolKit.ComboBox {
            anchors.left: parent.left
            anchors.leftMargin: 0.5*Devices.density
            width: parent.width/2 - 1*Devices.density
            currentIndex: account_settings.dialogsFilter
            onCurrentIndexChanged: account_settings.dialogsFilter = currentIndex
            modelArray: [
                {"name":qsTr("All")          , "icon": Awesome.fa_user},
                {"name":qsTr("Users")        , "icon": Awesome.fa_user},
                {"name":qsTr("Conversations"), "icon": Awesome.fa_user},
                {"name":qsTr("Onlines")      , "icon": Awesome.fa_user},
                {"name":qsTr("Groups")       , "icon": Awesome.fa_user},
                {"name":qsTr("Channels")     , "icon": Awesome.fa_user},
                {"name":qsTr("Bots")         , "icon": Awesome.fa_user},
                {"name":qsTr("Secret Chats") , "icon": Awesome.fa_user}
            ]
        }

        ToolKit.ComboBox {
            anchors.right: parent.right
            anchors.rightMargin: 0.5*Devices.density
            width: parent.width/2 - 1*Devices.density
            currentIndex: account_settings.dialogsSort
            onCurrentIndexChanged: account_settings.dialogsSort = currentIndex
            modelArray: [
                {"name":qsTr("Last Message"), "icon": Awesome.fa_filter},
                {"name":qsTr("Last Online") , "icon": Awesome.fa_filter},
                {"name":qsTr("Name")        , "icon": Awesome.fa_filter},
                {"name":qsTr("Unreads")     , "icon": Awesome.fa_filter},
                {"name":qsTr("Type")        , "icon": Awesome.fa_filter}
            ]
        }
    }

    ToolKit.DialogList {
        id: dlist
        width: parent.width
        visible: !searchList.visible
        anchors.top: comboLists.bottom
        anchors.bottom: parent.bottom
        onCategoriesChanged: {
            if(signalBlocker)
                return

            signalBlocker = true
            var list = categories_settings.keys()
            for(var i=0; i<list.length; i++)
                categories_settings.remove(list[i])
            for(var cat in categories)
                categories_settings.setValue(cat, categories[cat])
            lastCategories = categories
            signalBlocker = false
        }
        onForwardRequest: sidebar.forwardRequest(inputPeer, msgId)

        property variant lastCategories: new Array

        sortFlag: {
            var flag = Telegram.DialogListModel.SortByDate
            switch(account_settings.dialogsSort)
            {
            case 0:
                flag = Telegram.DialogListModel.SortByDate
                break
            case 1:
                flag = Telegram.DialogListModel.SortByOnline
                break
            case 2:
                flag = Telegram.DialogListModel.SortByName
                break
            case 3:
                flag = Telegram.DialogListModel.SortByUnreads
                break
            case 4:
                flag = Telegram.DialogListModel.SortByType
                break
            }
            return [Telegram.DialogListModel.SortByCategories, flag]
        }
        visibility: {
            switch(account_settings.dialogsFilter)
            {
            case 0:
                return Telegram.DialogListModel.VisibilityAll
            case 1:
                return Telegram.DialogListModel.VisibilityUsers
            case 2:
                return Telegram.DialogListModel.VisibilityUsers | Telegram.DialogListModel.VisibilityChats
            case 3:
                return Telegram.DialogListModel.VisibilityOnlineUsersOnly | Telegram.DialogListModel.VisibilityUsers
            case 4:
                return Telegram.DialogListModel.VisibilityChats
            case 5:
                return Telegram.DialogListModel.VisibilityChannels
            case 6:
                return Telegram.DialogListModel.VisibilityBots
            case 7:
                return Telegram.DialogListModel.VisibilitySecretChats
            }
            return Telegram.DialogListModel.VisibilityAll
        }
    }

    SearchList {
        id: searchList
        width: parent.width
        anchors.top: comboLists.top
        anchors.bottom: dlist.bottom
        engine: sidebar.engine
        keyword: searchbar.keyword
        currentPeer: searchbar.currentPeer
        visible: keyword.length
        onLoadRequest: {
            sidebar.currentPeer = peer
            if(message)
                loadMessageRequest(message)
        }
    }

    function searchRequest(peer) {
        searchbar.currentPeer = peer
    }

    function focusOnSearch() {
        searchbar.focusOnSearch()
    }
}

