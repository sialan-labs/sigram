import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    width: sourceSize.width
    height: sourceSize.height

    property alias radius: mask.radius
    property alias asynchronous: img.asynchronous
    property alias cache: img.cache
    property alias fillMode: img.fillMode
    property alias horizontalAlignment: img.horizontalAlignment
    property alias mirror: img.mirror
    property alias paintedHeight: img.paintedHeight
    property alias paintedWidth: img.paintedWidth
    property alias progress: img.progress
    property alias smooth: img.smooth
    property alias source: img.source
    property alias sourceSize: img.sourceSize
    property alias status: img.status
    property alias verticalAlignment: img.verticalAlignment

    Rectangle {
        id: mask
        anchors.fill: parent
        visible: false
    }

    Image {
        id: img
        anchors.fill: parent
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: img
        maskSource: mask
    }
}

