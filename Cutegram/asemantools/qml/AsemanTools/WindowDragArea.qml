import QtQuick 2.0
import AsemanTools 1.0

Item {
    width: 100
    height: 62

    MouseArea {
        anchors.fill: parent
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
            View.move(View.window.x+dx, View.window.y+dy)
        }
        property bool moved
        property point pin
    }
}

