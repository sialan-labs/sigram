import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

CheckBoxStyle {

    property color backgroundColor: masterPalette.base

    SystemPalette {
        id: masterPalette
    }

    indicator: Item {
        implicitWidth: 24
        implicitHeight: 24

        Item {
            id: frame
            anchors.fill: parent
            anchors.margins: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 5
                color: backgroundColor
            }
        }

        InnerShadow {
            anchors.fill: source
            source: frame
            radius: 4.0
            samples: 16
            horizontalOffset: 0
            verticalOffset: 1
            opacity: control.pressed? 0.6 : 0.4
            color: "#000000"
        }

        Image {
            anchors.fill: parent
            anchors.margins: 5
            source: "images/yes.png"
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectCrop
            visible: control.checked
        }
    }

    label: Text {
        color: masterPalette.windowText
        text: control.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}

