import QtQuick 2.2

Rectangle {
    id: progress_bar
    width: 100
    height: 30
    color: "#0d7080"
    smooth: true

    property real frameSize: 4
    property real percent: 0
    property alias progressColor: top.color

    Rectangle {
        id: top
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: frameSize
        width: (progress_bar.width-2*frameSize)*progress_bar.percent/100
        color: "#33b7cc"
        radius: progress_bar.radius
        visible: width >= radius*2

        Behavior on width {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 500 }
        }
    }

    function setValue( p ){
        percent = p
    }
}
