import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

AccountPageItem {
    id: contactsPage

    property variant engine

    signal contactActivated(variant peer)

    delegate: Item {
        anchors.fill: parent

        Telegram.DialogListModel {
            id: dmodel
            visibility: Telegram.DialogListModel.VisibilityContacts | Telegram.DialogListModel.VisibilityEmptyDialogs
            sortFlag: Telegram.DialogListModel.SortByName
            engine: contactsPage.engine
            filter: searchTxt.text
        }

        Item {
            id: header
            height: 90*Devices.density
            width: parent.width

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: gview.x + 10*Devices.density
                width: gview.cellWidth - 20*Devices.density
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
                width: gview.cellWidth - 20*Devices.density
                height: 38*Devices.density
                radius: 5*Devices.density
                color: addBtnMArea.pressed? Qt.darker(CutegramGlobals.baseColor, 1.1) : CutegramGlobals.baseColor

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
                }
            }
        }

        AsemanGridView {
            id: gview
            clip: true
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            width: parent.width - 60*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter
            model: dmodel
            cellWidth: width/Math.floor(width/proximateCellWidth)
            cellHeight: 60*Devices.density

            property real proximateCellWidth: 240*Devices.density

            delegate: Item {
                width: gview.cellWidth
                height: gview.cellHeight

                Row {
                    id: row
                    anchors.centerIn: parent
                    width: parent.width - 20*Devices.density
                    spacing: 8*Devices.density

                    ProfileImage {
                        id: img
                        engine: dmodel.engine
                        source: model.user? model.user : model.chat
                        anchors.verticalCenter: parent.verticalCenter
                        height: 42*Devices.density
                        width: height
                    }

                    Text {
                        width: row.width - img.width - row.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 10*Devices.fontDensity
                        color: "#333333"
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        text: CutegramEmojis.parse(model.title)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: contactsPage.contactActivated(model.peer)
                }
            }
        }

        NormalWheelScroll {
            flick: gview
            anchors.fill: null
            width: parent.width
            anchors.top: gview.top
            anchors.bottom: gview.bottom
        }

        PhysicalScrollBar {
            anchors.right: parent.right
            anchors.top: gview.top
            height: gview.height
            width: 6*Devices.density
            color: CutegramGlobals.baseColor
            scrollArea: gview
        }
    }

}

