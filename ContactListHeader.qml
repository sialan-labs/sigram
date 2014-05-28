import QtQuick 2.0

Rectangle {
    width: 100
    height: 62
    color: "#cccccc"

    MouseArea {
        anchors.fill: parent
    }

    Button {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 42
        icon: "files/add.png"
        iconHeight: 12
        highlightColor: "#33B7CC"
        normalColor: "#bbbbbb"
    }
}
