import QtQuick 2.0

Rectangle {
    id: contact_list
    width: 100
    height: 62
    color: "#dddddd"

    property int current

    Connections {
        target: Telegram
        onContactsChanged: {
            privates.contacts_refreshed = true
            clist.refresh()
        }
        onDialogsChanged: {
            privates.dialogs_refreshed = true
            clist.refresh()
        }
        onStarted: {
            Telegram.updateDialogList()
            Telegram.updateContactList()
        }
        onIncomingMsg: {
            Telegram.updateDialogListUsingTimer()
        }
        onUserStatusChanged: {
            clist.refresh()
        }
        onMsgChanged: {
            Telegram.updateDialogListUsingTimer()
        }
    }

    QtObject {
        id: privates
        property bool contacts_refreshed: false
        property bool dialogs_refreshed: false
    }

    Indicator {
        id: indicator
        anchors.fill: parent
        Component.onCompleted: start()
    }

    ListView {
        id: clist
        anchors.fill: parent
        clip: true
        model: ListModel{}
        delegate: ContactListItem {
            id: item
            height: 57
            width: clist.width
            uid: user_id
            realId: item.isDialog? dialog_id : user_id
            selected: realId == contact_list.current
        }

        section.property: "itemMode"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels
        section.delegate: Rectangle {
            id: sect
            height: 53
            width: clist.width
            color: "#dddddd"

            Text {
                id: sect_txt
                text: section
                anchors.centerIn: parent
                font.pointSize: 10
                color: "#333333"
            }
        }

        function refresh() {
            if( !privates.contacts_refreshed || !privates.dialogs_refreshed )
                return

            indicator.stop()
            model.clear()
            var contacts = Telegram.contactListUsers()
            var dialogs = Telegram.dialogListIds()

            for( var i=0; i<dialogs.length; i++ ) {
                model.append( {"user_id": 0, "dialog_id": dialogs[i], "itemMode": qsTr("Chats")} )
                if( Telegram.dialogIsChat(dialogs[i]) )
                    Telegram.loadChatInfo(dialogs[i])
                else
                    Telegram.loadUserInfo(dialogs[i])
                var cIndex = contacts.indexOf(dialogs[i])
                if( cIndex != -1 )
                    contacts.splice(cIndex,1)
            }
            for( var i=0; i<contacts.length; i++ ) {
                model.append( {"user_id":contacts[i], "dialog_id": 0, "itemMode": qsTr("Users")} )
                Telegram.loadUserInfo(contacts[i])
            }
        }

        Component.onCompleted: refresh()
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height-53; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#333333"
        anchors.topMargin: 53
    }
}
