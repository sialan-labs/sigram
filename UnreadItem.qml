import QtQuick 2.0

Rectangle {
    id: uread_item
    width: txt.width<height? height : txt.width
    height: 20
    radius: height/2
    color: "#ff1111"
    visible: unread != 0

    property int unread: 0

    Text {
        id: txt
        anchors.centerIn: parent
        color: "#ffffff"
        text: uread_item.unread
    }
}
