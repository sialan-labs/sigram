import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

ToolBarStyle {

    padding {
        left: 4*Devices.density
        right: 4*Devices.density
        top: 4*Devices.density
        bottom: 4*Devices.density
    }

    background: Rectangle {
        color: Desktop.titleBarColor

        Rectangle {
            width: parent.width
            anchors.top: parent.bottom
            height: 3*Devices.density
            opacity: 0.3
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }
    }
}

