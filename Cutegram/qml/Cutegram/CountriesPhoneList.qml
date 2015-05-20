import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: cp_list
    width: 100
    height: 62

    property string number

    onNumberChanged: {
        if( number.length == 0 )
            countries_list.currentIndex = -1
    }

    ListView {
        id: countries_list
        anchors.fill: parent
        currentIndex: -1
        clip: true
        model: CountriesModel{}

        delegate: Rectangle {
            id: item
            height: 40*Devices.density
            width: countries_list.width
            color: marea.pressed || countries_list.currentItem==item? "#88FF5532" : "#00000000"

            Text {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 8*Devices.density
                font.family: AsemanApp.globalFont.family
                font.pixelSize: Math.floor(10*Devices.fontDensity)
                color: textColor0
                text: name
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    countries_list.currentIndex = index
                    cp_list.number = callingCode
                }
            }
        }
    }

    NormalWheelScroll {
        flick: countries_list
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: countries_list; height: countries_list.height; width: 6*Devices.density
        anchors.right: countries_list.right; anchors.top: countries_list.top; color: textColor0
    }
}
