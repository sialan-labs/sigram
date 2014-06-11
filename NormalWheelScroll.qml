import QtQuick 2.0

MouseArea {
    anchors.fill: parent

    property Flickable flick

    onPressed: mouse.accepted = false
    onWheel: {
        wheel.accepted = true
        flick.contentY -= wheel.angleDelta.y/2
        flick.returnToBounds()
    }
}
