import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"
import "../toolkit"

Item {
    id: clist

    property alias engine: dmodel.engine
    property alias filter: dmodel.filter
    property alias model: dmodel

    signal contactActivated(variant peer)

    Telegram.DialogListModel {
        id: dmodel
        visibility: Telegram.DialogListModel.VisibilityContacts | Telegram.DialogListModel.VisibilityEmptyDialogs
        sortFlag: Telegram.DialogListModel.SortByName
    }

    AsemanGridView {
        id: gview
        clip: true
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        model: dmodel
        cellWidth: width/Math.floor(width/proximateCellWidth)
        cellHeight: 60*Devices.density

        property real proximateCellWidth: 240*Devices.density

        delegate: Rectangle {
            width: gview.cellWidth
            height: gview.cellHeight
            color: marea.pressed? "#11000000" : "#00000000"
            radius: 5*Devices.density

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
                id: marea
                anchors.fill: parent
                onClicked: clist.contactActivated(model.peer)
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
