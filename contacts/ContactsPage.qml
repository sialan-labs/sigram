import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"
import "../contacts" as Contacts
import "../toolkit"

AccountPageItem {
    id: contactsPage

    property variant engine
    readonly property bool refreshing: item? item.refreshing : false

    property bool addButton: false

    signal contactActivated(variant peer)

    delegate: Item {
        anchors.fill: parent

        property bool refreshing: gview.model.refreshing
        property bool addingContact: false

        onAddingContactChanged: {
            if(addingContact)
                BackHandler.pushHandler(addContact, function(){addingContact = false})
            else
                BackHandler.removeHandler(addContact)
            addContact.clear()
        }

        Item {
            id: header
            height: 90*Devices.density
            width: parent.width

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: gview.x + 10*Devices.density
                width: 220*Devices.density
                height: 38*Devices.density
                radius: 5*Devices.density
                color: CutegramGlobals.foregroundColor

                Text {
                    id: search_icon
                    height: parent.height
                    width: height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 13*Devices.fontDensity
                    font.family: Awesome.family
                    color: "#666666"
                    text: Awesome.fa_search
                }

                TextInput {
                    id: searchTxt
                    anchors.left: search_icon.right
                    anchors.right: parent.right
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignLeft
                    selectByMouse: true
                    selectionColor: CutegramGlobals.baseColor
                    selectedTextColor: "#ffffff"
                    color: "#333333"
                    font.pixelSize: 9*Devices.fontDensity

                    property bool isEmpty: text.length == 0
                    onIsEmptyChanged: {
                        if(isEmpty)
                            BackHandler.removeHandler(searchTxt)
                        else
                            BackHandler.pushHandler(searchTxt, function(){searchTxt.text = ""})
                    }

                    Text {
                        anchors.fill: parent
                        font: parent.font
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        color: "#999999"
                        text: qsTr("Search")
                        visible: parent.text.length == 0
                    }
                }

                MouseArea {
                    anchors.fill: searchTxt
                    cursorShape: Qt.IBeamCursor
                    onPressed: mouse.accepted = false
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: gview.x + 10*Devices.density
                width: 220*Devices.density
                height: 38*Devices.density
                radius: 5*Devices.density
                color: addBtnMArea.pressed? Qt.darker(CutegramGlobals.baseColor, 1.1) : CutegramGlobals.baseColor
                visible: addButton

                Row {
                    anchors.centerIn: parent
                    spacing: 4*Devices.density

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 13*Devices.fontDensity
                        font.family: Awesome.family
                        color: "#ffffff"
                        text: Awesome.fa_user_plus
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 10*Devices.fontDensity
                        color: "#ffffff"
                        text: qsTr("Add new contact")
                    }
                }

                MouseArea {
                    id: addBtnMArea
                    anchors.fill: parent
                    onClicked: addingContact = !addingContact
                }
            }
        }

        Contacts.ContactGrid {
            id: gview
            clip: true
            engine: contactsPage.engine
            filter: searchTxt.text
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            width: parent.width - 60*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            onContactActivated: contactsPage.contactActivated(peer)
        }

        AddContactPage {
            id: addContact
            width: parent.width
            height: parent.height
            opacity: addingContact? 1 : 0
            x: addingContact? 0 : 100*Devices.density
            model: gview.model
            visible: opacity != 0

            Behavior on x {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 250}
            }
            Behavior on opacity {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 250}
            }

            onFinished: if(result) addingContact = false
        }
    }
}

