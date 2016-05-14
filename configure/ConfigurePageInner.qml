import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    height: column.height

    property real splitterWidth: 26*Devices.density
    property real panelsWidth: 328*Devices.density

    Telegram.PeerDetails {
        id: cgram_channel
        engine: confPage.engine
        username: "cgram"
    }

    Column {
        id: column
        width: 500*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: splitterWidth

        Item {width: 1; height: splitterWidth}

        Row {
            width: parent.width
            spacing: splitterWidth

            ToolKit.ProfileImage {
                id: profile_img
                width: 120*Devices.density
                height: 120*Devices.density
                anchors.verticalCenter: parent.verticalCenter
                source: engine.our? engine.our.user : null
                engine: confPage.engine
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - profile_img.width - parent.spacing

                Column {
                    spacing: splitterWidth/2

                    Text {
                        color: "#555555"
                        font.pixelSize: 16*Devices.fontDensity
                        text: engine.our? engine.our.user.firstName + " " + engine.our.user.lastName : "null"
                    }

                    Text {
                        color: "#666666"
                        font.pixelSize: 11*Devices.fontDensity
                        text: engine.our? engine.our.user.phone : "null"
                    }

                    Text {
                        color: "#666666"
                        font.pixelSize: 11*Devices.fontDensity
                        text: engine.our? "@" + engine.our.user.username : "null"
                    }
                }

                Button {
                    height: 34*Devices.density
                    width: height
                    anchors.right: parent.right
                    text: Awesome.fa_sign_out
                    textColor: "#db2424"
                    highlightColor: "#eeeeee"
                    radius: 3*Devices.density
                    textFont.family: Awesome.family
                    textFont.pixelSize: 24*Devices.fontDensity
                    onClicked: {
                        if(Desktop.yesOrNo(CutegramGlobals.mainWindow, qsTr("Logout"), qsTr("Are you realy want to logout from this account?")))
                            engine.logout()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1*Devices.density
            color: "#e6e6e6"
        }

        Column {
            width: 326*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12*Devices.density
            z: 1000

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Notifications")
                checked: CutegramSettings.notifications
                onCheckedChanged: if(inited) CutegramSettings.notifications = checked
            }

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Cutegram newsletter")
                checked: cgram_channel.joined
                onCheckedChanged: if(inited) cgram_channel.joined = checked
            }

            ToolKit.ComboBoxItem {
                width: parent.width
                text: qsTr("Notification sound")
                modelArray: [
                    {"name":qsTr("Default"), "icon": Awesome.fa_angle_down},
                    {"name":qsTr("Other")  , "icon": Awesome.fa_angle_down},
                ]
                onCurrentIndexChanged: {
                    if(!inited)
                        return
                    switch(currentIndex) {
                    case 0:
                        CutegramSettings.notifySound = CutegramSettings.defaultNotifySound
                        break
                    case 1:
                        Tools.jsDelayCall(100, function(){
                            var path = Desktop.getOpenFileName(CutegramGlobals.mainWindow, qsTr("Select file"))
                            if(path.length == 0) {
                                currentIndex = 0
                                return
                            }

                            CutegramSettings.notifySound = path
                        })
                        break
                    }
                }
                Component.onCompleted: {
                    if(CutegramSettings.notifySound == CutegramSettings.defaultNotifySound)
                        currentIndex = 0
                    else
                        currentIndex = 1
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1*Devices.density
            color: "#e6e6e6"
        }

        Column {
            width: 326*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12*Devices.density
            z: 999

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Launch on system start")
            }

            ToolKit.ComboBoxItem {
                width: parent.width
                text: qsTr("On start")
                z: 1000
                modelArray: [
                    {"name":qsTr("Automatic"), "icon": Awesome.fa_angle_down},
                    {"name":qsTr("Visible")  , "icon": Awesome.fa_angle_down},
                    {"name":qsTr("Hidden")   , "icon": Awesome.fa_angle_down},
                ]
                onCurrentIndexChanged: if(inited) CutegramSettings.windowStateOnStart = currentIndex
                Component.onCompleted: currentIndex = CutegramSettings.windowStateOnStart
            }

            ToolKit.ComboBoxItem {
                width: parent.width
                text: qsTr("Tray icon style")
                z: 999
                modelArray: [
                    {"name":qsTr("Automatic"), "icon": Awesome.fa_angle_down},
                    {"name":qsTr("Dark")     , "icon": Awesome.fa_angle_down},
                    {"name":qsTr("Light")    , "icon": Awesome.fa_angle_down},
                ]
                onCurrentIndexChanged: if(inited) CutegramSettings.trayIconStyle = currentIndex
                Component.onCompleted: currentIndex = CutegramSettings.trayIconStyle
            }
        }

        Item {width: 1; height: splitterWidth}

        Column {
            width: 326*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12*Devices.density
            z: 998

            ToolKit.ComboBoxItem {
                width: parent.width
                text: qsTr("Emoji")
                z: 1000
                modelArray: [
                    {"name":qsTr("Twitter")  , "icon": Awesome.fa_angle_down},
                    {"name":qsTr("Emoji One"), "icon": Awesome.fa_angle_down},
                ]
                onCurrentIndexChanged: {
                    if(!inited)
                        return
                    switch(currentIndex) {
                    case 1:
                        CutegramSettings.defaultEmoji = "emojione"
                        break
                    default:
                        CutegramSettings.defaultEmoji = "twemoji"
                        break
                    }
                }
                Component.onCompleted: {
                    if(CutegramSettings.defaultEmoji == "emojione") {
                        currentIndex = 1
                    } else {
                        currentIndex = 0
                    }
                }
            }

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Convert smilies to emojis")
            }

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Send by Ctrl + Enter")
            }
        }

        Item {width: 1; height: splitterWidth}

        Column {
            width: 326*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12*Devices.density
            z: 998

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Master Color")
                onCheckedChanged: {
                    if(!inited)
                        return
                    if(!checked) {
                        CutegramSettings.masterColor = ""
                        return
                    }

                    Tools.jsDelayCall(100, function(){
                        var newColor = Desktop.getColor()
                        if(newColor == "#000000") {
                            checked = false
                            return
                        }

                        CutegramSettings.masterColor = newColor
                    })
                }
                Component.onCompleted: checked = (CutegramSettings.masterColor.length != 0)
            }

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Background")
            }

            ToolKit.CheckBox {
                width: parent.width
                text: qsTr("Minimal UI")
                onCheckedChanged: if(inited) CutegramSettings.minimalMode = checked
                Component.onCompleted: checked = CutegramSettings.minimalMode
            }
        }

        Item {width: 1; height: splitterWidth}
    }

    property bool inited: false
    Component.onCompleted: Tools.jsDelayCall(100, function(){inited = true})
}

