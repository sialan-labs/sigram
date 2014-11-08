import QtQuick 2.0

Rectangle {
    id: auth_dialog
    color: "#333333"

    Image {
        anchors.fill: parent
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectCrop
        source: "files/auth_back.jpg"
    }
}
