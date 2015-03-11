import QtQuick 2.2
import QtQuick.Controls.Styles 1.1

BusyIndicatorStyle {
    property bool light: false

    indicator: Item{
        implicitWidth: 22
        implicitHeight: 22

        Image {
            anchors.fill: parent
            sourceSize: Qt.size(width, height)
            visible: control.running
            source: light? "images/indicator_light.png" : "images/indicator.png"
            RotationAnimator on rotation {
                running: control.running
                loops: Animation.Infinite
                duration: 1000
                from: 0 ; to: 360
            }
        }
    }
}
