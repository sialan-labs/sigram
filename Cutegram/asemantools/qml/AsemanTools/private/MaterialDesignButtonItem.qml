import QtQuick 2.0
import AsemanTools 1.0
import QtGraphicalEffects 1.0

Item {
    id: mdb_item
    width: row.width

    property alias buttonHeight: button_frame.height
    property alias text: txt.text
    property alias icon: img.source

    signal clicked()

    Row {
        id: row
        height: parent.height
        layoutDirection: View.layoutDirection

        Rectangle {
            color: "#00ffffff"
            radius: 4*Devices.density
            width: txt.width + 12*Devices.density
            height: txt.height + 12*Devices.density
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: txt
                anchors.centerIn: parent
                color: "#333333"
                font.pixelSize: 10*Devices.fontDensity
                font.bold: false
                font.family: AsemanApp.globalFont.family
            }
        }

        Item {
            id: button_frame
            width: height
            height: 64*Devices.density
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: btn_rect
                anchors.fill: parent
                visible: false

                Behavior on y {
                    NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8*Devices.density
                    color: "#ffffff"
                    radius: width/2

                    Behavior on color {
                        ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
                    }
                }
            }

            DropShadow {
                anchors.fill: btn_rect
                horizontalOffset: 0
                verticalOffset: 1
                radius: 8.0
                samples: 16
                color: "#66000000"
                source: btn_rect
            }

            Image {
                id: img
                anchors.fill: parent
                anchors.margins: 18*Devices.density
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width, height)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mdb_item.clicked()
    }
}

