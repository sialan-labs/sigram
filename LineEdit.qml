import QtQuick 2.0
import QtQuick.Controls 1.0

TextInput {
    id: txt
    width: 100
    selectionColor: "#0d80ec"
    selectedTextColor: "#ffffff"

    Menu {
        id: menu

        property variant item

        MenuItem {
            text: qsTr("Copy")
            onTriggered: txt.copy()
            shortcut: "Ctrl+C"
        }

        MenuItem {
            text: qsTr("Cut")
            enabled: !txt.readOnly
            onTriggered: txt.cut()
            shortcut: "Ctrl+X"
        }

        MenuItem {
            text: qsTr("Paste")
            enabled: !txt.readOnly
            onTriggered: txt.paste()
            shortcut: "Ctrl+V"
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Remove")
            shortcut: "Delete"
            enabled: !txt.readOnly
            onTriggered: {
                txt.remove(txt.selectionStart,txt.selectionEnd)
                txt.deselect()
            }
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Select All")
            shortcut: "Ctrl+A"
            onTriggered: txt.selectAll()
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Undo")
            enabled: !txt.readOnly
            shortcut: "Ctrl+Z"
            onTriggered: txt.undo()
        }

        MenuItem {
            text: qsTr("Redo")
            enabled: !txt.readOnly
            shortcut: "Ctrl+Shift+Z"
            onTriggered: txt.redo()
        }

        function show(){
            menu.popup()
        }
    }
    MouseArea {
        id: marea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            menu.show()
        }
    }
}
