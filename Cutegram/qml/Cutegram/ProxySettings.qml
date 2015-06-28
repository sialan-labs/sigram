import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import AsemanTools.Controls 1.0 as Controls
import QtQuick.Window 2.0
import AsemanTools 1.0
import TelegramQml 1.0
import Cutegram 1.0

Window {
    id: proxy_window
    width: column.width + 20*Devices.density
    height: column.height + 20*Devices.density
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    x: View.x + View.width/2 - width/2
    y: View.y + View.height/2 - height/2
    title: qsTr("Proxy Settings")

    Rectangle {
        anchors.fill: parent
        color: masterPalette.window
    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 8*Devices.density

        QtControls.Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("This changes needs to restart application.")
        }

        Row {
            spacing: 10*Devices.density

            Column {
                spacing: 6*Devices.density

                Text {
                    id: proxy_type_text
                    height: proxy_type_combo.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(9*Devices.fontDensity)
                    color: "#333333"
                    text: qsTr("Proxy Type")
                }

                Text {
                    id: proxy_host_text
                    height: proxy_host_line.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(9*Devices.fontDensity)
                    color: "#333333"
                    text: qsTr("Hostname")
                }

                Text {
                    id: proxy_port_text
                    height: proxy_port_spin.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(9*Devices.fontDensity)
                    color: "#333333"
                    text: qsTr("Port")
                }

                Text {
                    id: proxy_user_text
                    height: proxy_user_line.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(9*Devices.fontDensity)
                    color: "#333333"
                    visible: Devices.isLinux
                    text: qsTr("Username")
                }

                Text {
                    id: proxy_pass_text
                    height: proxy_pass_line.height
                    verticalAlignment: Text.AlignVCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: Math.floor(9*Devices.fontDensity)
                    color: "#333333"
                    text: qsTr("Password")
                }
            }

            Column {
                spacing: 6*Devices.density

                Controls.ComboBox {
                    id: proxy_type_combo
                    style: Cutegram.currentTheme.comboBoxStyle
                    model: [ "No Proxy", "Http Proxy", "Socks5 Proxy" ]
                    Component.onCompleted: {
                        var type = AsemanApp.readSetting("Proxy/type", CutegramEnums.ProxyNoProxy)
                        if(type == CutegramEnums.ProxyNoProxy)
                            currentIndex = 0
                        else
                        if(type == CutegramEnums.ProxyHttpProxy)
                            currentIndex = 1
                        else
                        if(type == CutegramEnums.ProxySocks5Proxy)
                            currentIndex = 2
                    }
                }

                Controls.TextField {
                    id: proxy_host_line
                    style: Cutegram.currentTheme.textFieldStyle
                    width: 200*Devices.density
                    placeholderText: qsTr("Ex: 127.0.0.1")
                    text: AsemanApp.readSetting("Proxy/host","")
                }

                Controls.SpinBox {
                    id: proxy_port_spin
                    maximumValue: 99999
                    minimumValue: 0
                    style: Cutegram.currentTheme.spinBoxStyle
                    value: AsemanApp.readSetting("Proxy/port", 0)
                }

                Controls.TextField {
                    id: proxy_user_line
                    style: Cutegram.currentTheme.textFieldStyle
                    width: 200*Devices.density
                    text: AsemanApp.readSetting("Proxy/user", "")
                }

                Controls.TextField {
                    id: proxy_pass_line
                    style: Cutegram.currentTheme.textFieldStyle
                    width: 200*Devices.density
                    echoMode: TextInput.Password
                    text: AsemanApp.readSetting("Proxy/pass", "")
                }
            }
        }

        Row {
            spacing: 2*Devices.density
            anchors.right: parent.right

            Controls.Button {
                text: qsTr("Cancel")
                style: Cutegram.currentTheme.buttonStyle
                onClicked: proxy_window.visible = false
            }

            Controls.Button {
                text: qsTr("Ok")
                style: Cutegram.currentTheme.buttonStyle
                onClicked: {
                    var host = proxy_host_line.text
                    var port = proxy_port_spin.value
                    var user = proxy_user_line.text
                    var pass = proxy_pass_line.text

                    var enable = false
                    var type = CutegramEnums.ProxyNoProxy
                    switch(proxy_type_combo.currentIndex) {
                    case 0:
                        type = CutegramEnums.ProxyNoProxy
                        enable = false
                        break
                    case 1:
                        type = CutegramEnums.ProxyHttpProxy
                        enable = true
                        break
                    case 2:
                        type = CutegramEnums.ProxySocks5Proxy
                        enable = true
                        break
                    }

                    AsemanApp.setSetting("Proxy/host", host)
                    AsemanApp.setSetting("Proxy/port", port)
                    AsemanApp.setSetting("Proxy/user", user)
                    AsemanApp.setSetting("Proxy/pass", pass)
                    AsemanApp.setSetting("Proxy/enable", enable)
                    AsemanApp.setSetting("Proxy/type", type)

                    proxy_window.visible = false
                }
            }
        }
    }

    Component.onCompleted: {
        width = column.width + 40*Devices.density
        height = column.height + 40*Devices.density
        x = View.x + View.width/2 - width/2
        y = View.y + View.height/2 - height/2
    }
}

