import QtQuick 2.4
import AsemanTools 1.0
import "../globals"

Rectangle {
    property alias innerScale: scene.scale
    signal startRequest()

    NullMouseArea { anchors.fill: parent }

    Item {
        id: scene
        anchors.centerIn: parent

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: column.top
            anchors.bottomMargin: 50*Devices.density
            font.pixelSize: 28*Devices.fontDensity
            color: "#333333"
            text: "Cutegram"
        }

        Column {
            id: column
            anchors.centerIn: parent
            spacing: 20*Devices.density

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 160*Devices.density
                height: 160*Devices.density
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width*2, height*2)
                source: "../images/icon.png"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 20*Devices.fontDensity
                color: "#777777"
                text: qsTr("Different, Handy, Powerful")
            }
        }

        Button {
            id: btn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: column.bottom
            anchors.topMargin: 60*Devices.density
            width: 160*Devices.density
            height: 35*Devices.density
            radius: 5*Devices.density
            normalColor: CutegramGlobals.baseColor
            highlightColor: Qt.darker(normalColor, 1.1)
            textColor: "#ffffff"
            text: qsTr("Start Messaging")
            textFont.bold: false
            textFont.pixelSize: 10*Devices.fontDensity
            onClicked: startRequest()
        }
    }

    function forceActiveFocus() {
        btn.forceActiveFocus()
    }
}

