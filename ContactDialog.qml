import QtQuick 2.0

Rectangle {
    id: contact_dialog
    width: 100
    height: 62

    signal selected( int uid )

    ListView {
        id: clist
        anchors.fill: parent
        model: ListModel{}
        clip: true

        delegate: Rectangle {
            id: item
            height: 57
            width: clist.width
            color: marea.pressed? "#E65245" : "#ffffff"

            ContactImage {
                id: contact_image
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 4
                uid: user_id
                width: height
                borderColor: "#ffffff"
                onlineState: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: contact_image.right
                anchors.leftMargin: 8
                font.pointSize: 10
                font.family: globalNormalFontFamily
                text: Telegram.contactTitle(user_id)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    if( forwarding != 0 ) {
                        forwardTo = user_id
                        return
                    }

                    contact_dialog.selected(user_id)
                }
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
                var cIndex = contacts.indexOf(dialogs[i])
                if( cIndex != -1 )
                    contacts.splice(cIndex,1)
            }
            for( var i=0; i<contacts.length; i++ ) {
                model.append( {"user_id":contacts[i]} )
                Telegram.loadUserInfo(contacts[i])
            }
        }

        Component.onCompleted: refresh()
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#333333"
    }
}
