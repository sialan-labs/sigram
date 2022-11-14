import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
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

    signal clearHistoryRequest(variant inputPeer)
    signal deleteDialogRequest(variant inputPeer)

    onCurrentPeerChanged: refresh()

    Connections {
        target: categoriesSettings
        onValueChanged: refresh()
    }

    Telegram.PeerDetails {
        id: details
        onEditableChanged: nameTxt.readOnly = true
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
                id: img
                anchors.verticalCenter: parent.verticalCenter
                width: 120*Devices.density
                height: width
                engine: details.engine
                source: details.peer

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(img.downloaded)
                            img.open()
                        else
                        if(!img.downloading) {
                            img.download()
                            img.downloadedChanged.connect(img.open)
                        }
                    }
                }

                function open() {
                    engine.openFile(destination)
                    img.downloadedChanged.disconnect(img.open)
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8*Devices.density

                TextInput {
                    id: nameTxt
                    font.pixelSize: 20*Devices.fontDensity
                    color: "#555555"
                    selectByMouse: true
                    readOnly: true
                    selectionColor: CutegramGlobals.baseColor
                    text: details.displayName

                    onReadOnlyChanged: {
                        if(readOnly)
                            BackHandler.removeHandler(nameTxt)
                        else
                            BackHandler.pushHandler(nameTxt, function(){nameTxt.readOnly = true})
                    }

                    Rectangle {
                        width: parent.width
                        height: 2*Devices.density
                        anchors.top: parent.bottom
                        color: CutegramGlobals.baseColor
                        visible: !nameTxt.readOnly
                    }

                    Text {
                        anchors.left: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10*Devices.density
                        font.family: Awesome.family
                        font.pixelSize: 16*Devices.density
                        text: nameTxt.readOnly? Awesome.fa_edit : Awesome.fa_check
                        color: nameTxt.readOnly? "#666666" : CutegramGlobals.baseColor
                        visible: details.editable

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10*Devices.density
                            onClicked: {
                                if(nameTxt.readOnly) {
                                    nameTxt.readOnly = false
                                    return
                                }

                                var callback = function(res){
                                    if(res) nameTxt.readOnly = !nameTxt.readOnly
                                }

                                if(details.isUser) {
                                    var name = nameTxt.text
                                    var idx = name.indexOf(" ")
                                    var firstName = (idx!=-1? name.slice(0,idx) : name)
                                    var lastName = (idx!=-1? name.slice(idx+1) : "")
                                    details.renameUser(firstName, lastName, callback)
                                } else {
                                    details.renameChat(nameTxt.text, callback)
                                }
                            }
                        }
                    }
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
                tooltipText: qsTr("Badge")
                tooltipPosition: Qt.BottomEdge
//                visible: currentPeer && currentPeer.userId
                visible: false
                text: details.blocked? Awesome.fa_ban : Awesome.fa_circle_o
            }
        }

        Column {
            spacing: 2*Devices.density

            Button {
                text: qsTr("Clear History")
                textColor: "#666666"
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                textFont.pixelSize: 9*Devices.fontDensity
                textFont.bold: false
                onClicked: {
                    if(Desktop.yesOrNo(CutegramGlobals.mainWindow, qsTr("Clear History?"), qsTr("Are you sure about clear history?")))
                        clearHistoryRequest(currentPeer)
                }
            }

            Button {
                text: qsTr("Delete Conversation")
                textColor: "#666666"
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                textFont.pixelSize: 9*Devices.fontDensity
                textFont.bold: false
                onClicked: {
                    if(Desktop.yesOrNo(CutegramGlobals.mainWindow, qsTr("Delete Conversation?"), qsTr("Are you sure about delete conversation?")))
                        deleteDialogRequest(currentPeer)
                }
            }

            Button {
                text: details.blocked? qsTr("Unblock") : qsTr("Block")
                textColor: "#B01818"
                highlightColor: CutegramGlobals.foregroundColor
                hoverColor: "#f0f0f0"
                textFont.pixelSize: 9*Devices.fontDensity
                textFont.bold: false
                onClicked: details.blocked = !details.blocked
            }
        }
    }

    function refresh() {
        love_btn.refresh()
        fav_btn.refresh()
        nameTxt.readOnly = true
    }
}
