import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Rectangle {
    color: CutegramGlobals.foregroundColor
    height: column.height

    property alias keyword: txt.text
    property alias currentPeer: details.peer
    property alias engine: details.engine

    readonly property bool isEmpty: keyword.length == 0
    readonly property bool globalSearch: currentPeer == null

    onCurrentPeerChanged: {
        if(currentPeer) {
            txt.forceActiveFocus()
            txt.text = ""
        }
    }
    onIsEmptyChanged: {
        if(isEmpty)
            BackHandler.removeHandler(txt)
        else
            BackHandler.pushHandler(txt, function(){txt.text = ""})
    }
    onGlobalSearchChanged: {
        if(globalSearch)
            BackHandler.removeHandler(details)
        else
            BackHandler.pushHandler(details, function(){currentPeer = null})
    }

    Telegram.PeerDetails {
        id: details
    }

    Column {
        id: column
        width: parent.width

        Item {
            width: parent.width
            height: 36*Devices.density

            TextInput {
                id: txt
                anchors.fill: parent
                anchors.margins: 10*Devices.density
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignLeft
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                color: "#333333"
                font.pixelSize: 9*Devices.fontDensity

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

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10*Devices.density
                font.family: Awesome.family
                font.pixelSize: 10*Devices.fontDensity
                color: "#959595"
                text: Awesome.fa_search
            }

            MouseArea {
                anchors.fill: txt
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.IBeamCursor
                onPressed: {
                    switch(mouse.button)
                    {
                    case Qt.LeftButton:
                        mouse.accepted = false
                        break
                    }
                }
                onClicked: {
                    switch(mouse.button)
                    {
                    case Qt.RightButton:
                        var act = Desktop.showMenu([qsTr("Copy"), qsTr("Cut"), qsTr("Paste"), "", qsTr("Select all"), "", qsTr("Delete")])
                        switch(act)
                        {
                        case 0:
                            txt.copy()
                            break;
                        case 1:
                            txt.cut()
                            break;
                        case 2:
                            txt.paste()
                            break;
                        case 4:
                            txt.selectAll()
                            break;
                        case 6:
                            txt.remove(txt.selectionStart, txt.selectionEnd)
                            break;
                        }

                        break
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: details.peer? 36*Devices.density : 0
            visible: details.peer

            Text {
                id: name_txt
                anchors.verticalCenter: parent.verticalCenter
                x: y
                color: "#333333"
                font.pixelSize: 9*Devices.fontDensity
                text: details.displayName
            }

            Button {
                anchors.right: parent.right
                height: parent.height
                width: height
                normalColor: "#00000000"
                highlightColor: "#11000000"
                textColor: "#888888"
                textFont.pixelSize: 11*Devices.fontDensity
                textFont.family: Awesome.family
                text: Awesome.fa_close
                onClicked: {
                    txt.text = ""
                    currentPeer = null
                }
            }

            Rectangle {
                width: parent.width
                height: 1*Devices.density
                anchors.bottom: parent.bottom
                color: CutegramGlobals.foregroundColor
            }
        }
    }

    function focusOnSearch() {
        txt.focus = true
        txt.forceActiveFocus()
    }
}

