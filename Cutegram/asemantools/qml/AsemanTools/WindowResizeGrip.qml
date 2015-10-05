import QtQuick 2.0
import AsemanTools 1.0

Item {
    width: 32*Devices.density
    height: 32*Devices.density

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeFDiagCursor
        onPressed: {
            moved = false
            pin = Qt.point(mouseX, mouseY)
        }
        onPositionChanged: {
            var dx = mouseX - pin.x
            var dy = mouseY - pin.y
            if(!moved && Math.abs(dx)<5*Devices.density && Math.abs(dy)<5*Devices.density)
                return

            moved = true
            View.resize(View.window.width+dx, View.window.height+dy)
        }
        property bool moved
        property point pin
    }
}

