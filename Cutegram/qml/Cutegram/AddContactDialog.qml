import QtQuick 2.0
import QtQuick.Window 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0
import AsemanTools.Controls 1.0 as Controls

Window {
    id: add_dialog
    width: 350*Devices.density
    height: 240*Devices.density
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    x: View.x + View.width/2 - width/2
    y: View.y + View.height/2 - height/2

    property Telegram telegram

    Rectangle {
        anchors.fill: parent
        color: masterPalette.window
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14*Devices.density
        spacing: 4*Devices.density

        Text {
            width: parent.width
            font: AsemanApp.globalFont
            color: "#333333"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Fill below form to add new contact.")
        }

        Controls.TextField {
            id: first_name_txt
            style: Cutegram.currentTheme.textFieldStyle
            width: parent.width
            placeholderText: qsTr("First Name")
        }

        Controls.TextField {
            id: last_name_txt
            style: Cutegram.currentTheme.textFieldStyle
            width: parent.width
            placeholderText: qsTr("Last Name")
        }

        Item { width: 10; height: 10*Devices.density }

        Controls.TextField {
            id: phone_number_txt
            style: Cutegram.currentTheme.textFieldStyle
            width: parent.width
            placeholderText: qsTr("Phone Number")
            validator: RegExpValidator{regExp: /(?!0)\d*/}
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8*Devices.density
        spacing: 4*Devices.density

        Controls.Button {
            text: qsTr("Cancel")
            style: Cutegram.currentTheme.buttonStyle
            onClicked: add_dialog.visible = false
        }

        Controls.Button {
            text: qsTr("OK")
            style: Cutegram.currentTheme.buttonStyle
            enabled: {
                if(first_name_txt.text.trim().length == 0)
                    return false
                if(last_name_txt.text.trim().length == 0)
                    return false
                if(phone_number_txt.length < 7)
                    return false

                return true
            }
            onClicked: {
                telegram.addContact(first_name_txt.text, last_name_txt.text, phone_number_txt.text)
                add_dialog.visible = false
            }
        }
    }

    Component.onCompleted: {
        x = View.x + View.width/2 - width/2
        y = View.y + View.height/2 - height/2
    }
}

