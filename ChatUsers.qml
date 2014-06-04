import QtQuick 2.0

Rectangle {
    id: chat_users
    width: 100
    height: 62
    clip: true

    property int chatId
    signal selected( int uid )

    onChatIdChanged: clist.refresh()

    ListView {
        id: clist
        anchors.fill: parent
        anchors.margins: 4
        model: ListModel{}
        clip: true

        delegate: Rectangle {
            id: item
            height: 57
            width: clist.width
            color: marea.pressed? "#E65245" : "#00000000"

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

            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 4
                normalColor: "#00000000"
                highlightColor: "#00000000"
                textColor: press? "#D04528" : "#ff5532"
                visible: Telegram.dialogChatUsersInviter(chat_users.chatId,user_id) == Telegram.me
                text: qsTr("Delete")
                onClicked: Telegram.chatDelUser(chat_users.chatId,user_id)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    if( !Telegram.contactContains(user_id) )
                        return

                    chat_users.selected(user_id)
                }
            }
        }

        function refresh() {
            indicator.stop()
            model.clear()
            var contacts = Telegram.dialogChatUsers(chat_users.chatId)
            for( var i=0; i<contacts.length; i++ ) {
                model.append( {"user_id":contacts[i]} )
                Telegram.loadUserInfo(contacts[i])
            }
        }

        Component.onCompleted: refresh()
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#ffffff"
    }
}
