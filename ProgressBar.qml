import QtQuick 2.2

Rectangle {
    id: progress_bar
    width: 100
    height: 30
    color: "#333333"
    radius: 3*physicalPlatformScale
    smooth: true

    property real percent: 0

    Rectangle {
        id: top
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: progress_bar.width*progress_bar.percent/100
        color: "#3B97EC"
        radius: progress_bar.radius
        visible: width >= radius*2

        Behavior on width {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 100 }
        }
    }

    function setValue( p ){
        percent = p
    }
}
