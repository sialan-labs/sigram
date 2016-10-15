import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

AccountPageItem {
    id: addNewPage

    property variant engine
    readonly property bool refreshing: item? item.refreshing : false

    delegate: Item {
        anchors.fill: parent

        property bool refreshing: false
        property bool selectContact: false

        onSelectContactChanged: {
            if(selectContact)
                BackHandler.pushHandler(contactFrame, function(){selectContact = false})
            else
                BackHandler.removeHandler(contactFrame)
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            spacing: 80*Devices.density

            AddButton {
                text: qsTr("New Secret Chat")
                icon: Awesome.fa_user_secret
                onClicked: selectContact = true
            }
            AddButton {
                text: qsTr("New Group")
                icon: Awesome.fa_users
                onClicked: selectContact = true
            }
            AddButton {
                text: qsTr("New Channel")
                icon: Awesome.fa_bullhorn
                onClicked: selectContact = true
            }
        }

        Rectangle {
            id: contactFrame
            width: parent.width
            height: parent.height
            opacity: selectContact? 1 : 0
            x: selectContact? 0 : 100*Devices.density
            visible: opacity != 0

            Behavior on x {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 250}
            }
            Behavior on opacity {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 250}
            }

            ContactGrid {
                anchors.fill: parent
                engine: addNewPage.engine
            }
        }
    }
}

