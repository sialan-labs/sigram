import QtQuick 2.0
import AsemanTools 1.0

Item {
    width: 100
    height: 62

    property alias model: tabs_list.model
    property real minimumTabSize: 40*Devices.density
    property real maximumTabSize: width - 40*Devices.density
    property real tabsHeight: 50*Devices.density

    AsemanListView {
        id: tabs_list
        width: parent.width
        height: tabsHeight
        orientation: ListView.Horizontal
        currentIndex: 0
        delegate: Item {
            clip: true
            height: tabs_list.height
            width: {
                var result = tabs_list.width/tabs_list.count
                if(result < minimumTabSize)
                    result = minimumTabSize
                if(result > maximumTabSize)
                    result = maximumTabSize
                return result
            }

            Text {
                anchors.centerIn: parent
                text: model.text
                font.pixelSize: 13*Devices.fontDensity
                color: "#ffffff"
            }
        }
        highlight: Item {
            clip: true
            height: tabs_list.height
            width: {
                var result = tabs_list.width/tabs_list.count
                if(result < minimumTabSize)
                    result = minimumTabSize
                if(result > maximumTabSize)
                    result = maximumTabSize
                return result
            }

            Rectangle {
                anchors.verticalCenter: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 16*Devices.density
                height: width
                rotation: 45
                transformOrigin: Item.Center
            }
        }
    }

    Rectangle {
        width: parent.width
        anchors.top: tabs_list.bottom
        anchors.bottom: parent.bottom
    }
}

