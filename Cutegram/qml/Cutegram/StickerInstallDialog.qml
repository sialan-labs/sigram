import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls
import TelegramQmlLib 1.0
import QtGraphicalEffects 1.0

Item {
    width: 100
    height: 62

    property alias telegram: smodel.telegram
    property alias stickerSet: smodel.currentStickerSet

    Rectangle {
        anchors.fill: parent
        color: "#88000000"
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel.accepted = true
        onClicked: close()
    }

    StickersModel {
        id: smodel
    }

    Connections {
        target: telegram
        onStickerInstalled: {
            if(shortName != stickerSet)
                return
            if(ok)
                close()
        }
    }

    DropShadow {
        anchors.fill: scene
        horizontalOffset: 3
        verticalOffset: 3
        radius: 32.0
        samples: 16
        color: "#80000000"
        source: scene
    }

    Item {
        id: scene
        anchors.fill: parent

        Rectangle {
            id: back_rect
            width: 600*Devices.density
            height: 400*Devices.density
            radius: 6*Devices.density
            anchors.centerIn: parent

            MouseArea {
                anchors.fill: parent
            }

            Indicator {
                id: indicator
                anchors.top: parent.top
                anchors.left: parent.left
                height: title.height + 20*Devices.density
                width: height
                indicatorSize: 18*Devices.density
                light: false
                modern: true
            }

            Text {
                id: title
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10*Devices.density
                text: stickerSet
                font.pixelSize: 13*Devices.fontDensity
                color: "#333333"
            }

            Button {
                anchors.top: parent.top
                anchors.right: parent.right
                height: title.height + 20*Devices.density
                width: height
                icon: "files/close-dark.png"
                iconHeight: 22*Devices.density
                normalColor: "#00000000"
                highlightColor: "#22000000"
                onClicked: close()
            }

            AsemanGridView {
                id: gridView
                anchors.top: title.bottom
                anchors.bottom: install_btn.top
                anchors.margins: 10*Devices.density
                width: parent.width
                clip: true
                model: smodel
                cellWidth: width/splitCount
                cellHeight: cellWidth

                property real splitCount: Math.floor(gridView.width/80*Devices.density)

                delegate: Item {
                    id: item
                    width: gridView.cellWidth
                    height: gridView.cellHeight

                    property Document document: model.document

                    FileHandler {
                        id: handler
                        target: item.document
                        telegram: smodel.telegram
                        Component.onCompleted: download()
                    }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(width, height)
                        source: handler.downloaded? handler.filePath : handler.thumbPath
                    }
                }
            }

            Controls.Button {
                id: install_btn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10*Devices.density
                text: qsTr("Install")
                onClicked: {
                    telegram.installStickerSet(stickerSet)
                    indicator.start()
                }
            }

            PhysicalScrollBar {
                scrollArea: gridView; height: gridView.height; width: 6*Devices.density
                anchors.right: gridView.right; anchors.top: gridView.top; color: "#333333"
            }
        }
    }

    function close() {
        destroy()
    }
}

