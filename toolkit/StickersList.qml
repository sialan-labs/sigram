import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Rectangle {
    id: stckList
    color: "#fefefe"

    property alias engine: scmodel.engine

    signal stickerSelected(variant document)

    Telegram.StickersCategoriesModel {
        id: scmodel
    }

    ListModel {
        id: listModel
        ListElement {
            fakeDocumentItems: 0
        }
    }

    MixedListModel {
        id: mixModel
        models: [listModel, scmodel]
    }

    Rectangle {
        anchors.fill: clistv
        color: "#f3f3f3"
        radius: parent.radius

        Rectangle {
            width: parent.width
            height: parent.radius
            color: parent.color
        }
    }

    StickerViewer {
        id: viewer
        width: parent.width
        height: parent.height - clistv.height
        engine: scmodel.engine
        onStickerSelected: stckList.stickerSelected(document)
        onEngineChanged: showRecents()
    }

    AsemanListView {
        id: clistv
        width: parent.width
        height: 46*Devices.density
        anchors.bottom: parent.bottom
        model: mixModel
        orientation: Qt.Horizontal
        currentIndex: 0
        clip: true
        delegate: Item {
            width: height
            height: clistv.height

            property variant docs: model.modelObject==scmodel? model.documentItems : model.fakeDocumentItems
            onDocsChanged: {
                if(clistv.currentIndex == index && docs)
                    viewer.documents = docs
            }

            Telegram.Image {
                engine: scmodel.engine
                source: docs && docs.length? docs[0] : null
                anchors.fill: parent
                sourceSize: Qt.size(width*2, height*2)
                anchors.margins: 8*Devices.density
            }

            Text {
                anchors.centerIn: parent
                font.family: Awesome.family
                font.pixelSize: 14*Devices.fontDensity
                color: "#666666"
                visible: !docs
                text: Awesome.fa_clock_o
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clistv.currentIndex = index
                    if(docs)
                        viewer.documents = docs
                    if(index == 0)
                        viewer.showRecents()
                }
            }
        }

        highlightMoveDuration: 250
        highlightMoveVelocity: -1
        highlight: Item {
            width: height
            height: clistv.height

            Rectangle {
                width: parent.width
                height: 2*Devices.density
                anchors.bottom: parent.bottom
                color: CutegramGlobals.highlightColors
            }
        }
    }

    NormalWheelScroll {
        flick: clistv
        animated: false
    }
}

