import QtQuick 2.0
import QtQuick.Controls.Styles 1.3
import QtGraphicalEffects 1.0

ScrollViewStyle {
    property color backgroundColor: masterPalette.window

    SystemPalette {
        id: masterPalette
    }

    frame: Item {

        Item {
            id: fframe
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
            source: fframe
            radius: 4.0
            samples: 16
            horizontalOffset: 0
            verticalOffset: 1
            opacity: 0.3
            color: control.focus? masterPalette.highlight : "#000000"
        }
    }
}
