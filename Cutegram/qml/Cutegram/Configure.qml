import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls
import TelegramQml 1.0
// import CutegramTypes 1.0

Rectangle {
    id: configure
    width: 100
    height: 62

    property Telegram telegram
    property User user: telegram.user(telegram.me)

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: column.width
        contentHeight: conf_frame.height
        flickableDirection: Flickable.VerticalFlick

        Item {
            id: conf_frame
            width: configure.width
            height: logicalHeight>configure.height? logicalHeight : configure.height

            property real logicalHeight: column.height + buttons_column.height + 30*Devices.density

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

                    Controls.Button {
                        anchors.bottom: parent.bottom
                        anchors.left: img.right
                        anchors.margins: 20*Devices.density
                        width: 100*Devices.density
                        height: 36*Devices.density
                        text: qsTr("Change Photo")
                        style: Cutegram.currentTheme.buttonStyle
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
                    color: Cutegram.currentTheme.sidebarPhoneBackground

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
                            font.family: Cutegram.currentTheme.sidebarPhoneFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarPhoneFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarPhoneColor
                            text: user.firstName + " " + user.lastName
                        }

                        Item { width: 10; height: 4*Devices.density }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20*Devices.density
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: Math.floor(12*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarPhoneColor
                            text: telegram.phoneNumber
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20*Devices.density
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: Math.floor(12*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarPhoneColor
                            text: "@" + user.username
                            visible: user.username.length != 0
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
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Notifications")
                        }

                        Text {
                            id: aseman_nl_text
                            height: aseman_nl_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Cutegram Newsletter")
                        }

                        Text {
                            id: autostart_text
                            height: autostart_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            visible: autostart_checkbox.visible
                            text: qsTr("Auto Start")
                        }

                        Text {
                            id: startup_text
                            height: startup_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("On Start")
                        }

                        Text {
                            id: systray_style_text
                            height: systray_style_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Tray icon style")
                        }

                        Text {
                            id: languages_text
                            height: languages_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Languages")
                        }

                        Text {
                            id: minimum_list_text
                            height: minimum_list_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Minimum List")
                        }

                        Text {
                            id: smooth_scroll_text
                            height: smooth_scroll_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Smooth Scroll")
                        }

                        Text {
                            id: last_msg_text
                            height: last_msg_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Detailed List")
                        }

                        Text {
                            id: auto_emoji_text
                            height: auto_emojis_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Convert smilies to emojis")
                        }

                        Text {
                            id: hover_emoji_text
                            height: hover_emojis_checkbox.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Show Emojis on hover")
                        }

                        Text {
                            id: theme_text
                            height: theme_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Theme")
                        }

                        Text {
                            id: background_text
                            height: background_btn.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Background")
                        }

                        Text {
                            id: search_text
                            height: search_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Search Engine")
                        }

                        Text {
                            id: proxy_text
                            height: proxy_btn.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Proxy Settings")
                        }

                        Text {
                            id: notify_sound_text
                            height: notify_sound_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Notify Sound")
                        }

                        Text {
                            id: color_text
                            height: color_combo.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Master Color")
                        }

                        Text {
                            id: font_text
                            height: font_btn.height
                            verticalAlignment: Text.AlignVCenter
                            font.family: Cutegram.currentTheme.sidebarFont.family
                            font.pixelSize: Math.floor(Cutegram.currentTheme.sidebarFont.pointSize*Devices.fontDensity)
                            color: Cutegram.currentTheme.sidebarFontColor
                            text: qsTr("Font")
                        }
                    }

                    Column {
                        spacing: 6*Devices.density

                        Controls.Switch {
                            id: notify_checkbox
                            checked: Cutegram.notification
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.notification = checked
                        }

                        Controls.Switch {
                            id: aseman_nl_checkbox
                            checked: Cutegram.cutegramSubscribe
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.cutegramSubscribe = checked
                        }

                        Controls.Switch {
                            id: autostart_checkbox
                            visible: Devices.isLinux || Devices.isWindows || Devices.isMacX
                            checked: autostart_mngr.active
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: autostart_mngr.active = checked
                        }

                        Controls.ComboBox {
                            id: startup_combo
                            style: Cutegram.currentTheme.comboBoxStyle
                            model: [ qsTr("Automatic"), qsTr("Always visible"), qsTr("Minimize to system tray") ]
                            currentIndex: Cutegram.startupOption
                            onCurrentIndexChanged: if(init_timer.inited) Cutegram.startupOption = currentIndex
                        }

                        Controls.ComboBox {
                            id: systray_style_combo
                            style: Cutegram.currentTheme.comboBoxStyle
                            model: [ qsTr("Automatic"), qsTr("Dark"), qsTr("Light") ]
                            currentIndex: Cutegram.statusIconStyle
                            onCurrentIndexChanged: if(init_timer.inited) Cutegram.statusIconStyle = currentIndex
                        }

                        Controls.ComboBox {
                            id: languages_combo
                            style: Cutegram.currentTheme.comboBoxStyle
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

                        Controls.Switch {
                            id: minimum_list_checkbox
                            checked: Cutegram.minimumDialogs
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.minimumDialogs = checked
                        }

                        Controls.Switch {
                            id: smooth_scroll_checkbox
                            checked: Cutegram.smoothScroll
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.smoothScroll = checked
                        }

                        Controls.Switch {
                            id: last_msg_checkbox
                            checked: Cutegram.showLastMessage
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.showLastMessage = checked
                        }

                        Controls.Switch {
                            id: auto_emojis_checkbox
                            checked: Cutegram.autoEmojis
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.autoEmojis = checked
                        }

                        Controls.Switch {
                            id: hover_emojis_checkbox
                            checked: Cutegram.emojiOnHover
                            style: Cutegram.currentTheme.switchStyle
                            onCheckedChanged: Cutegram.emojiOnHover = checked
                        }

                        Controls.ComboBox {
                            id: theme_combo
                            style: Cutegram.currentTheme.comboBoxStyle
                            model: {
                                var result = new Array
                                var themes = Cutegram.themes
                                for(var i=0; i<themes.length; i++)
                                    result[i] = Tools.fileName(themes[i])
                                return result
                            }
                            currentIndex: {
                                var themes = Cutegram.themes
                                for(var i=0; i<themes.length; i++)
                                    if(themes[i] == Cutegram.theme)
                                        return i

                                return 0
                            }

                            onCurrentIndexChanged: if(init_timer.inited) Cutegram.theme = currentText + ".qml"
                        }

                        Controls.Button {
                            id: background_btn
                            style: Cutegram.currentTheme.buttonStyle
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

                        Controls.ComboBox {
                            id: search_combo
                            style: Cutegram.currentTheme.comboBoxStyle
                            model: Cutegram.searchEngines
                            currentIndex: {
                                var engines = Cutegram.searchEngines
                                for(var i=0; i<engines.length; i++)
                                    if(engines[i] == Cutegram.searchEngine)
                                        return i

                                return 0
                            }
                            onCurrentIndexChanged: if(init_timer.inited) Cutegram.searchEngine = currentText
                        }

                        Controls.Button {
                            id: proxy_btn
                            text: qsTr("Change")
                            style: Cutegram.currentTheme.buttonStyle
                            onClicked: {
                                proxy_component.createObject(configure)
                            }
                        }

                        Controls.ComboBox {
                            id: notify_sound_combo
                            style: Cutegram.currentTheme.comboBoxStyle
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

                                select_sound_timer.stop()
                                switch(currentIndex)
                                {
                                case 0:
                                    Cutegram.messageAudio = ""
                                    break;

                                case 1:
                                    Cutegram.messageAudio = "files/new_msg.ogg"
                                    break;

                                case 2:
                                    select_sound_timer.start()
                                    break;
                                }
                            }

                            Timer {
                                id: select_sound_timer
                                interval: 300
                                onTriggered: {
                                    var file = Desktop.getOpenFileName(View, qsTr("Select Sound"), "*.ogg *.mp3 *.wav")
                                    if(file.length != 0)
                                        Cutegram.messageAudio = Devices.localFilesPrePath + file
                                    else
                                        Cutegram.messageAudio = ""
                                }
                            }
                        }

                        Controls.ComboBox {
                            id: color_combo
                            style: Cutegram.currentTheme.comboBoxStyle
                            model: [qsTr("System Color"), qsTr("Custom")]
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

                        Controls.Button {
                            id: font_btn
                            text: qsTr("Select")
                            style: Cutegram.currentTheme.buttonStyle
                            onClicked: {
                                Cutegram.font = Desktop.getFont(View, qsTr("Select Font"), Cutegram.font)
                            }
                        }
                    }
                }
            }

            Column {
                id: buttons_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20*Devices.density
                spacing: 4*Devices.density

                Button {
                    width: parent.width
                    textFont.family: AsemanApp.globalFont.family
                    textFont.pixelSize: Math.floor(9*Devices.fontDensity)
                    highlightColor: Qt.darker(normalColor)
                    normalColor: "#C81414"
                    textColor: "#ffffff"
                    height: 40*Devices.density
                    text: qsTr("Logout")
                    radius: 4*Devices.density
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Desktop.showMessage(View, qsTr("Logout"), qsTr("Cutegram will restart after this operation."))
                        if( profiles.remove(telegram.phoneNumber) )
                            Cutegram.logout(telegram.phoneNumber)
                    }
                }

                Button {
                    width: parent.width
                    textFont.family: AsemanApp.globalFont.family
                    textFont.pixelSize: Math.floor(9*Devices.fontDensity)
                    highlightColor: Qt.darker(normalColor)
                    normalColor: "#333333"
                    textColor: "#ffffff"
                    height: 40*Devices.density
                    text: qsTr("About Cutegram")
                    radius: 4*Devices.density
                    cursorShape: Qt.PointingHandCursor
                    visible: false
                    onClicked: Cutegram.about()
                }

                Button {
                    width: parent.width
                    textFont.family: AsemanApp.globalFont.family
                    textFont.pixelSize: Math.floor(9*Devices.fontDensity)
                    highlightColor: Qt.darker(normalColor)
                    normalColor: "#26263E"
                    textColor: "#ffffff"
                    height: 40*Devices.density
                    text: qsTr("About Aseman")
                    radius: 4*Devices.density
                    visible: false
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Cutegram.aboutAseman()
                }
            }
        }
    }

    NormalWheelScroll {
        flick: flickable
        animated: Cutegram.smoothScroll
        reverse: true
    }

    PhysicalScrollBar {
        scrollArea: flickable; height: flickable.height; width: 6*Devices.density
        anchors.right: flickable.right; anchors.top: flickable.top; color: "#777777"
    }

    Timer {
        id: init_timer
        interval: 500
        Component.onCompleted: start()
        onTriggered: inited = true

        property bool inited: false
    }

    AutoStartManager {
        id: autostart_mngr
        source: "cutegram"
        command: AsemanApp.appFilePath
        comment: "Cutegram auto-start item"
        name: "Cutegram"
    }

    Component {
        id: proxy_component
        ProxySettings {
            visible: true
            onVisibleChanged: if(!visible) destroy()
        }
    }
}
