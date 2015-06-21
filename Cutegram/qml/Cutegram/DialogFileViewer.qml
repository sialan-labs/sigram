import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    id: df_viewer
    width: 100
    height: 62

    property alias telegram: dmodel.telegram
    property alias dialog: dmodel.dialog

    property real cellWidth: 100*Devices.density

    DialogFilesModel {
        id: dmodel
    }

    GridView {
        id: grid
        anchors.fill: parent
        anchors.rightMargin: 6*Devices.density
        clip: true
        model: dmodel
        cellWidth: width/Math.floor(width/df_viewer.cellWidth)
        cellHeight: cellWidth

        delegate: Rectangle {
            width: grid.cellWidth
            height: width

            Image {
                anchors.fill: parent
                source: Devices.localFilesPrePath + path
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize: {
                    var ratio = imageSize.width/imageSize.height
                    if(ratio>1)
                        return Qt.size( height*ratio, height)
                    else
                        return Qt.size( width, width/ratio)
                }

                property size imageSize: Cutegram.imageSize(source)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(Devices.localFilesPrePath + path)
            }
        }
    }

    PhysicalScrollBar {
        scrollArea: grid; height: grid.height; width: 6*Devices.density
        anchors.right: parent.right; anchors.top: grid.top; color: textColor0
    }
}

