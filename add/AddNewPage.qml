import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"
import "../toolkit"

AccountPageItem {
    id: addNewPage

    property variant engine
    readonly property bool refreshing: item? item.refreshing : false

    delegate: Item {
        anchors.fill: parent

        property bool refreshing: false

        Row {
            x: parent.width/2 - width/2 + addFrame.x/2 - 50*Devices.density
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
                onClicked: addFrame.item = add_group_component.createObject(addFrame)
            }
            AddButton {
                text: qsTr("New Channel")
                icon: Awesome.fa_bullhorn
                onClicked: selectContact = true
            }
        }

        Item {
            id: addFrame
            width: parent.width
            height: parent.height
            x: (1-opacity)*100*Devices.density
            opacity: item? 1 : 0
            visible: opacity != 0

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
            }

            property variant item

            onItemChanged: {
                if(item)
                    BackHandler.pushHandler(addFrame, function(){Tools.deleteItemDelay(addFrame.item,250); addFrame.item = null})
                else
                    BackHandler.removeHandler(addFrame)
            }
        }
    }

    Component {
        id: add_group_component
        AddGroup {
            anchors.fill: parent
        }
    }
}

