import QtQuick 2.0

Rectangle {
    id: contact_list
    width: 100
    height: 62

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
        delegate: Rectangle {
            id: item
            height: 40
            width: clist.width
            color: marea.pressed? "#0d80ec" : "#00000000"

            Text {
                id: txt
                text: user_id != 0 ? Telegram.contactTitle(user_id) : Telegram.dialogTitle(dialog_id)
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 20
                font.pointSize: 10
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: contact_list.current = user_id != 0? user_id : dialog_id
            }
        }

        section.property: "itemMode"
        section.criteria: ViewSection.FullString
        section.delegate: Rectangle {
            id: sect
            height: 30
            width: clist.width
            color: "#dddddd"

            Text {
                id: sect_txt
                text: section
                anchors.centerIn: parent
                font.pointSize: 11
            }
        }

        function refresh() {
            if( !privates.contacts_refreshed || !privates.dialogs_refreshed )
                return

            indicator.stop()
            model.clear()
            var contacts = Telegram.contactListUsers()
            var dialogs = Telegram.dialogListIds()

            for( var i=0; i<dialogs.length; i++ )
                model.append( {"user_id": 0, "dialog_id": dialogs[i], "itemMode": qsTr("Chats")} )
            for( var i=0; i<contacts.length; i++ )
                model.append( {"user_id":contacts[i], "dialog_id": 0, "itemMode": qsTr("Users")} )
        }

        Component.onCompleted: refresh()
    }
}
