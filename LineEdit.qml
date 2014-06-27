import QtQuick 2.0

Item {
    id: line_edit
    width: txt.width + (readOnly? 0 : pad)
    height: txt.height + (readOnly? 0 : pad)

    property real pad: 10

    property color color: "#66ffffff"
    property alias font: txt.font
    property alias text: txt.text
    property alias textColor: txt.color
    property alias horizontalAlignment: txt.horizontalAlignment
    property alias readOnly: txt.readOnly
    property string placeholderText: placeholder.text
    property alias validator: txt.validator

    Rectangle {
        id: back
        anchors.fill: parent
        color: txt.readOnly? "#00000000" : line_edit.color
    }

    Text {
        id: placeholder
        anchors.fill: parent
        anchors.margins: line_edit.pad/2
        verticalAlignment: txt.verticalAlignment
        horizontalAlignment: txt.horizontalAlignment
        color: "#888888"
        font: txt.font
        visible: txt.text.length == 0
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onPressed: {
            txt.focus = true
        }
    }

    TextInput {
        id: txt
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: line_edit.pad/2
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: "#333333"
        readOnly: true
        clip: true
    }

    MouseArea {
        anchors.fill: parent
        visible: readOnly
        cursorShape: Qt.IBeamCursor
        onPressed: {
            readOnly = false
            txt.focus = true
        }
    }
}
