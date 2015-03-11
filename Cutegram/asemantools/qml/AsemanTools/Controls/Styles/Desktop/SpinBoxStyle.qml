import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

SpinBoxStyle {
    property color backgroundColor: masterPalette.base

    SystemPalette {
        id: masterPalette
    }

    background: Item {
        implicitWidth: 60
        implicitHeight: 28

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
            verticalOffset: 1
            opacity: 0.4
            color: "#000000"
        }
    }
}
