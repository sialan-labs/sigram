import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtQuick.Controls 1.0 as QtControls

Rectangle {
    id: configure
    width: 100
    height: 62

    property Telegram telegram
    property User user: telegram.user(telegram.me)

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Item { width: 10; height: 30*Devices.density }

        ContactImage {
            id: img
            anchors.left: parent.left
            anchors.margins: 20*Devices.density
            width: 148*Devices.density
            height: 148
            user: configure.user
            isChat: false
            telegram: configure.telegram
        }

        Item { width: 10; height: 20*Devices.density }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: name_column.height
            color: "#dddddd"

            Column {
                id: name_column
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20*Devices.density
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 18*Devices.fontDensity
                    color: "#333333"
                    text: user.firstName + " " + user.lastName
                }

                Item { width: 10; height: -10*Devices.density }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20*Devices.density
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 12*Devices.fontDensity
                    color: "#333333"
                    text: user.phone
                }
            }
        }

        Item { width: 10; height: 20*Devices.density }

        Row {
            spacing: 10*Devices.density
            anchors.left: parent.left
            anchors.margins: 20*Devices.density

            Column {
                spacing: 6*Devices.density

                Text {
                    id: notify_text
                    height: notify_checkbox.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("Notifications")
                }

                Text {
                    id: startup_text
                    height: startup_combo.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("On Start")
                }

                Text {
                    id: languages_text
                    height: languages_combo.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("Languages")
                }

                Text {
                    id: last_msg_text
                    height: last_msg_checkbox.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("Detailed List")
                }

                Text {
                    id: background_text
                    height: background_btn.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFontFamily
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("Background")
                }
            }

            Column {
                spacing: 6*Devices.density

                QtControls.CheckBox {
                    id: notify_checkbox
                    checked: Cutegram.notification
                    onCheckedChanged: Cutegram.notification = checked
                }

                QtControls.ComboBox {
                    id: startup_combo
                    model: [ qsTr("Automatic"), qsTr("Always visible"), qsTr("Minimize to system tray") ]
                    currentIndex: Cutegram.startupOption
                    onCurrentIndexChanged: if(!init_timer.running) Cutegram.startupOption = currentIndex
                }

                QtControls.ComboBox {
                    id: languages_combo
                    model: Cutegram.languages
                    currentIndex: {
                        var langs = Cutegram.languages
                        for(var i=0; i<langs.length; i++)
                            if(langs[i] == Cutegram.language)
                                return i

                        return 0
                    }

                    onCurrentTextChanged: if(!init_timer.running) Cutegram.language = currentText
                }

                QtControls.CheckBox {
                    id: last_msg_checkbox
                    checked: Cutegram.showLastMessage
                    onCheckedChanged: Cutegram.showLastMessage = checked
                }

                QtControls.Button {
                    id: background_btn
                    text: Cutegram.background.length==0? qsTr("Change") : qsTr("Remove")
                    onClicked: {
                        if(Cutegram.background.length==0) {
                            var path = Desktop.getOpenFileName(View, qsTr("Select Image"), "*.png *.jpg *.jpeg")
                            if(path.length == 0)
                                return

                            Cutegram.background = path
                        } else {
                            Cutegram.background = ""
                        }
                    }
                }
            }
        }
    }

    Button {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20*Devices.density
        textFont.family: AsemanApp.globalFontFamily
        textFont.pixelSize: 9*Devices.fontDensity
        highlightColor: Qt.darker(normalColor)
        normalColor: "#C81414"
        textColor: "#ffffff"
        height: 40*Devices.density
        text: qsTr("Logout")
        onClicked: Cutegram.logout()
    }

    Timer {
        id: init_timer
        interval: 500
        Component.onCompleted: start()
    }
}
