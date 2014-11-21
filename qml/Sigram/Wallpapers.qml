import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Rectangle {
    width: 100
    height: 62

    property alias telegramObject: wallpapers_model.telegram

    WallpapersModel {
        id: wallpapers_model
        onIntializingChanged: {
            if( intializing )
                indicator.start()
            else
                indicator.stop()
        }
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: false
        modern: true
        indicatorSize: 20*physicalPlatformScale
    }

    GridView {
        id: grid
        anchors.fill: parent
        model: wallpapers_model
        cellWidth: 128*physicalPlatformScale
        cellHeight: cellWidth
        clip: true
        delegate: Item {
            id: ditem
            width: grid.cellWidth
            height: grid.cellHeight

            property WallPaper wallpaper: item

            Image {
                anchors.fill: parent
                anchors.margins: 4*physicalPlatformScale
                sourceSize: Qt.size(width,height)
                smooth: true
                source: ditem.wallpaper.sizes.first.location.download.location
            }
        }
    }

    NormalWheelScroll {
        flick: grid
    }

    PhysicalScrollBar {
        scrollArea: grid; height: grid.height; width: 6*physicalPlatformScale
        anchors.left: grid.right; anchors.top: grid.top; color: textColor0
    }
}
