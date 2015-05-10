import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0
import AsemanTools 1.0

TextFieldStyle {
    property color backgroundColor: masterPalette.base

    SystemPalette {
        id: masterPalette
    }

    background: Item {
        implicitWidth: 100*Devices.density
        implicitHeight: 34*Devices.density

        Item {
            id: frame
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1*Devices.density
                radius: 5*Devices.density
                color: backgroundColor
            }
        }

        InnerShadow {
            anchors.fill: source
            source: frame
            radius: 4.0
            samples: 16
            horizontalOffset: 0
            verticalOffset: 2*Devices.density
            opacity: control.focus? 1 : 0.5
            fast: true
            color: control.focus? masterPalette.highlight : "#000000"
        }
    }
}

