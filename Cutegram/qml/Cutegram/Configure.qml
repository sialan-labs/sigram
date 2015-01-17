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

    Flickable {
        anchors.fill: parent
        contentWidth: column.width
        contentHeight: column.height
        flickableDirection: Flickable.VerticalFlick

        Item {
            id: conf_frame
            width: configure.width
            height: logicalHeight>configure.height? logicalHeight : configure.height

            property real logicalHeight: column.height + logout_btn.height + 30*Devices.density

            Column {
                id: column
                width: parent.width

                Item { width: 10; height: 30*Devices.density }

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: img.height

                    ClickableContactImage {
                        id: img
                        anchors.left: parent.left
                        anchors.margins: 20*Devices.density
                        width: 148*Devices.density
                        height: 148
                        user: configure.user
                        isChat: false
                        telegram: configure.telegram
                    }

                    Indicator {
                        anchors.fill: img
                        light: true
                        modern: true
                        indicatorSize: 22*Devices.density
                        property bool active: telegram.uploadingProfilePhoto

                        onActiveChanged: {
                            if( active )
                                start()
                            else
                                stop()
                        }
                    }

                    Button {
                        anchors.bottom: parent.bottom
                        anchors.left: img.right
                        anchors.margins: 20*Devices.density
                        normalColor: Cutegram.highlightColor
                        highlightColor: Qt.darker(Cutegram.highlightColor)
                        textColor: masterPalette.highlightedText
                        width: 100*Devices.density
                        height: 36*Devices.density
                        text: qsTr("Change Photo")
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var newImg = Desktop.getOpenFileName(View, qsTr("Select photo"), "*.jpg *.png *.jpeg")
                            if(newImg.length == 0)
                                return

                            telegram.setProfilePhoto(newImg)
                        }
                    }
                }

                Item { width: 10; height: 20*Devices.density }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: name_column.height + 10*Devices.density
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
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 18*Devices.fontDensity
                            color: "#333333"
                            text: user.firstName + " " + user.lastName
                        }

                        Item { width: 10; height: 4*Devices.density }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20*Devices.density
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.family: AsemanApp.globalFont.family
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
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Notifications")
                        }

                        Text {
                            id: aseman_nl_text
                            height: aseman_nl_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Cutegram Newsletter")
                        }

                        Text {
                            id: startup_text
                            height: startup_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("On Start")
                        }

                        Text {
                            id: languages_text
                            height: languages_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Languages")
                        }

                        Text {
                            id: last_msg_text
                            height: last_msg_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Detailed List")
                        }

                        Text {
                            id: background_text
                            height: background_btn.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Background")
                        }

                        Text {
                            id: notify_sound_text
                            height: notify_sound_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Notify Sound")
                        }

                        Text {
                            id: color_text
                            height: color_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Master Color")
                        }

                        Text {
                            id: font_text
                            height: font_btn.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 9*Devices.fontDensity
                            color: "#333333"
                            text: qsTr("Font")
                        }
                    }

                    Column {
                        spacing: 6*Devices.density

                        QtControls.CheckBox {
                            id: notify_checkbox
                            checked: Cutegram.notification
                            onCheckedChanged: Cutegram.notification = checked
                        }

                        QtControls.CheckBox {
                            id: aseman_nl_checkbox
                            checked: Cutegram.asemanSubscribe
                            onCheckedChanged: Cutegram.asemanSubscribe = checked
                        }

                        QtControls.ComboBox {
                            id: startup_combo
                            model: [ qsTr("Automatic"), qsTr("Always visible"), qsTr("Minimize to system tray") ]
                            currentIndex: Cutegram.startupOption
                            onCurrentIndexChanged: if(init_timer.inited) Cutegram.startupOption = currentIndex
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

                            onCurrentTextChanged: if(init_timer.inited) Cutegram.language = currentText
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

                        QtControls.ComboBox {
                            id: notify_sound_combo
                            model: [qsTr("None"), qsTr("Default"), qsTr("Custom")]
                            currentIndex: {
                                if(Cutegram.messageAudio.length == 0)
                                    return 0
                                if(Cutegram.messageAudio == "files/new_msg.ogg")
                                    return 1
                                else
                                    return 2
                            }

                            onCurrentIndexChanged: {
                                if(!init_timer.inited)
                                    return

                                switch(currentIndex)
                                {
                                case 0:
                                    Cutegram.messageAudio = ""
                                    break;

                                case 1:
                                    Cutegram.messageAudio = "files/new_msg.ogg"
                                    break;

                                case 2:
                                {
                                    var file = Desktop.getOpenFileName(View, qsTr("Select Sound"), "*.ogg *.mp3 *.wav")
                                    if(file.length != 0)
                                        Cutegram.messageAudio = "file://" + file
                                    else
                                        Cutegram.messageAudio = ""
                                }
                                    break;
                                }
                            }
                        }

                        QtControls.ComboBox {
                            id: color_combo
                            model: ["System Color", "Custom"]
                            currentIndex: {
                                if(Cutegram.masterColor.length == 0)
                                    return 0
                                else
                                    return 1
                            }
                            onCurrentIndexChanged: {
                                if(!init_timer.inited)
                                    return

                                var color = ""
                                if(currentIndex != 0)
                                    color = Desktop.getColor(Cutegram.highlightColor)

                                Cutegram.masterColor = color
                            }
                        }

                        QtControls.Button {
                            id: font_btn
                            text: qsTr("Select")
                            onClicked: {
                                Cutegram.font = Desktop.getFont(View, qsTr("Select Font"), Cutegram.font)
                            }
                        }
                    }
                }
            }

            Button {
                id: logout_btn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20*Devices.density
                textFont.family: AsemanApp.globalFont.family
                textFont.pixelSize: 9*Devices.fontDensity
                highlightColor: Qt.darker(normalColor)
                normalColor: "#C81414"
                textColor: "#ffffff"
                height: 40*Devices.density
                text: qsTr("Logout")
                onClicked: Cutegram.logout()
            }
        }
    }

    Timer {
        id: init_timer
        interval: 500
        Component.onCompleted: start()
        onTriggered: inited = true

        property bool inited: false
    }
}
