import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Item {
    id: viewer

    property alias engine: lmodel.engine
    property alias shortName: lmodel.shortName
    property alias inputStickerSet: lmodel.stickerSet
    property alias documents: lmodel.documents

    onDocumentsChanged: gview.positionViewAtBeginning()

    signal stickerSelected(variant document)

    Telegram.StickersModel {
        id: lmodel
    }

    AsemanGridView {
        id: gview
        anchors.fill: parent
        model: lmodel
        cellWidth: width/Math.floor(width/proximateCellSize)
        cellHeight: cellWidth
        clip: true

        property real proximateCellSize: 64*Devices.density

        delegate: Item {
            width: gview.cellWidth
            height: gview.cellHeight

            Telegram.Image {
                engine: viewer.engine
                source: model.document
                anchors.fill: parent
                anchors.margins: 8*Devices.density
                sourceSize: Qt.size(width*2, height*2)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: stickerSelected(model.document)
            }
        }
    }

    NormalWheelScroll {
        flick: gview
    }

    PhysicalScrollBar {
        anchors.right: gview.right
        height: gview.height
        width: 6*Devices.density
        color: "#888888"
        scrollArea: gview
    }
}

