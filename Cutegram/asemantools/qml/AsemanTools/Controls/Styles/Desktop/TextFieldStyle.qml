import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

TextFieldStyle {
    property color backgroundColor: masterPalette.base

    SystemPalette {
        id: masterPalette
    }

    background: Item {
        implicitWidth: 100
        implicitHeight: 34

        Item {
            id: frame
            anchors.fill: parent

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
            verticalOffset: 2
            opacity: control.focus? 1 : 0.5
            fast: true
            color: control.focus? masterPalette.highlight : "#000000"
        }
    }
}

