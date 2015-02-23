import QtQuick 2.0
import QtQuick.Controls.Styles 1.3
import QtGraphicalEffects 1.0
import AsemanTools 1.0

ButtonStyle {
    property color buttonColor: masterPalette.highlight
    property color buttonTextColor: masterPalette.highlightedText

    SystemPalette {
        id: masterPalette
    }

    background: Item {
        implicitWidth: 100*Devices.density
        implicitHeight: 32*Devices.density

        Item {
            id: frame
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1*Devices.density
                radius: 5*Devices.density
                color: control.pressed? Qt.darker(buttonColor,1.02) : buttonColor
            }
        }

        InnerShadow {
            anchors.fill: source
            source: frame
            radius: 4*Devices.density
            samples: 16
            horizontalOffset: 0
            verticalOffset: 1*Devices.density
            opacity: control.pressed? 0.5 : 0.2
            color: "#000000"
        }
    }

    label: Item {
        Row {
            anchors.centerIn: parent

            Image {
                height: control.height-10*Devices.density
                width: height
                source: control.iconSource
                sourceSize: Qt.size(width,height)
                visible: status == Image.Ready
            }

            Text {
                color: buttonTextColor
                text: control.text
            }
        }
    }
}

