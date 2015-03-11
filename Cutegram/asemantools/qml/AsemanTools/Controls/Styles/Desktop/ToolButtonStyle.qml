import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

ButtonStyle {
    SystemPalette {
        id: masterPalette
    }

    background: Item {
        implicitWidth: 100
        implicitHeight: 32

        Item {
            id: frame
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 5
                color: control.pressed? masterPalette.window : "#00000000"
                border.width: control.hovered && !control.pressed? 1 : 0
                border.color: control.hovered && !control.pressed? Qt.lighter(masterPalette.highlight, 1.2) : "#00000000"
            }
        }

        InnerShadow {
            anchors.fill: source
            source: frame
            radius: 4.0
            samples: 16
            horizontalOffset: 0
            verticalOffset: 1
            opacity: control.pressed? 0.3 : 0
            color: "#000000"
        }
    }

    label: Item {
        Row {
            anchors.centerIn: parent

            Image {
                height: control.height/2
                width: height
                source: control.iconSource
                sourceSize: Qt.size(width,height)
                visible: status == Image.Ready
            }

            Text {
                color: masterPalette.windowText
                text: control.text
            }
        }
    }
}

