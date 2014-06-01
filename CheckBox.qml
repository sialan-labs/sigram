import QtQuick 2.0

Rectangle {
    id: check_box
    width: 16
    height: 16
    color: "#00000000"
    border.width: 1
    border.color: "#333333"

    property bool checked: false

    Image {
        anchors.fill: parent
        anchors.margins: 2
        sourceSize: Qt.size(width,height)
        source: "files/sent.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: check_box.checked
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: check_box.checked = !check_box.checked
    }
}
