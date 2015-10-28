import QtQuick 2.0
import AsemanTools 1.0

AsemanGridView {
    id: grid
    model: fsmodel
    clip: true

    property alias root: fsmodel.folder
    property alias filters: fsmodel.nameFilters
    property alias showDotAndDotDot: fsmodel.showDotAndDotDot

    signal clickedOnFile(variant fileUrl)

    FileSystemModel {
        id: fsmodel
    }

    SystemPalette {
        id: palette
    }

    property real gridWidth: 92*Devices.density

    cellWidth: width/Math.floor(width/gridWidth)
    cellHeight: gridWidth

    delegate: Item {
        width: grid.cellWidth
        height: grid.cellHeight

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1*Devices.density
            radius: 3*Devices.density
            color: palette.highlight
            opacity: marea.pressed? 0.2 : 0
        }

        Column {
            height: parent.height - 10*Devices.density
            anchors.centerIn: parent
            spacing: 4*Devices.density

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: height
                height: parent.height - txt.height - 10*Devices.density
                asynchronous: true
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectCrop
                clip: true
                source: {
                    if(model.fileIsDir)
                        return "files/folder.png"
                    else
                    if(model.fileMime.indexOf("image") >= 0)
                        return model.fileUrl
                    else
                        return "files/unknown.png"
                }
            }

            Text {
                id: txt
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: model.fileName
                color: "#333333"
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                font.pixelSize: 9*Devices.fontDensity
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            onClicked: {
                if(model.fileIsDir)
                    fsmodel.folder = model.filePath
                else
                    clickedOnFile(model.fileUrl)
            }
        }
    }
}

