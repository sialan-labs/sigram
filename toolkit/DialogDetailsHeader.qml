import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    height: mainColumn.height + firstRow.spacing*2

    property alias engine: details.engine
    property alias currentPeer: details.peer
    property Settings categoriesSettings

    property alias refreshing: details.refreshing

    onCurrentPeerChanged: refresh()

    Connections {
        target: categoriesSettings
        onValueChanged: refresh()
    }

    Telegram.PeerDetails {
        id: details
    }

    Column {
        id: mainColumn
        spacing: 28*Devices.density
        width: parent.width
        anchors.centerIn: parent

        Row {
            id: firstRow
            width: parent.width
            spacing: mainColumn.spacing

            ToolKit.ProfileImage {
                anchors.verticalCenter: parent.verticalCenter
                width: 120*Devices.density
                height: width
                engine: details.engine
                source: details.peer
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8*Devices.density

                Text {
                    font.pixelSize: 20*Devices.fontDensity
                    color: "#555555"
                    text: details.displayName
                }

                Text {
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#888888"
                    text: {
                        var res = ""
                        if(details.isUser)
                            res = details.phoneNumber
                        if(res.length != 0)
                            res = "+" + res
                        return res
                    }
                }

                Text {
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#888888"
                    text: {
                        var res = details.username
                        if(res.length != 0)
                            res = "@" + res
                        return res
                    }
                }
            }
        }

        Row {
            width: parent.width

            Button {
                id: love_btn
                height: width
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                radius: 3*Devices.density
                textColor: "#db2424"
                textFont.family: Awesome.family
                textFont.pixelSize: 20*Devices.fontDensity
                tooltipText: qsTr("Love")
                tooltipPosition: Qt.BottomEdge
                onClicked: {
                    var value = categoriesSettings.value(details.key)
                    if(value == CutegramEnums.dialogsCategoryLove)
                        categoriesSettings.setValue(details.key, CutegramEnums.dialogsCategoryEmpty)
                    else
                        categoriesSettings.setValue(details.key, CutegramEnums.dialogsCategoryLove)
                }

                function refresh() {
                    var value = categoriesSettings.value(details.key)
                    if(value == CutegramEnums.dialogsCategoryLove)
                        text = Awesome.fa_heart
                    else
                        text = Awesome.fa_heart_o
                }
            }
            Button {
                id: fav_btn
                height: width
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                radius: 3*Devices.density
                textColor: "#e3cf2a"
                textFont.family: Awesome.family
                textFont.pixelSize: 20*Devices.fontDensity
                tooltipText: qsTr("Favorite")
                tooltipPosition: Qt.BottomEdge
                onClicked: {
                    var value = categoriesSettings.value(details.key)
                    if(value == CutegramEnums.dialogsCategoryFavorite)
                        categoriesSettings.setValue(details.key, CutegramEnums.dialogsCategoryEmpty)
                    else
                        categoriesSettings.setValue(details.key, CutegramEnums.dialogsCategoryFavorite)
                }

                function refresh() {
                    var value = categoriesSettings.value(details.key)
                    if(value == CutegramEnums.dialogsCategoryFavorite)
                        text = Awesome.fa_star
                    else
                        text = Awesome.fa_star_o
                }
            }
            Button {
                id: mute_btn
                height: width
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                radius: 3*Devices.density
                textColor: "#333333"
                textFont.family: Awesome.family
                textFont.pixelSize: 20*Devices.fontDensity
                tooltipText: qsTr("Mute")
                tooltipPosition: Qt.BottomEdge
                text: details.mute? Awesome.fa_bell_slash_o : Awesome.fa_bell_o
                onClicked: details.mute = !details.mute
            }
            Button {
                id: block_btn
                height: width
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                radius: 3*Devices.density
                textColor: "#333333"
                textFont.family: Awesome.family
                textFont.pixelSize: 20*Devices.fontDensity
                tooltipText: qsTr("Block")
                tooltipPosition: Qt.BottomEdge
                visible: currentPeer && currentPeer.userId
                text: details.blocked? Awesome.fa_ban : Awesome.fa_circle_o
                onClicked: details.blocked = !details.blocked
            }
        }
    }

    function refresh() {
        love_btn.refresh()
        fav_btn.refresh()
    }
}
