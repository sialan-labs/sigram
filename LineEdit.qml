import QtQuick 2.0
import QtQuick.Controls 1.0

TextEdit {
    id: txt
    width: 100
    selectionColor: "#0d80ec"
    selectedTextColor: "#ffffff"
    wrapMode: Text.WordWrap

    onTextChanged: if( text.trim().length == 0 ) text = text.trim()

    signal accepted();

    Keys.onPressed: {
        if( event.key == Qt.Key_Return || event.key == Qt.Key_Enter )
            if( event.modifiers == Qt.NoModifier )
                txt.accepted()
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            txt.showMenu()
        }
    }

    function showMenu() {
        var acts = [ qsTr("Copy"), qsTr("Cut"), qsTr("Paste"), "", qsTr("Remove"), "", qsTr("Select All"),
                 "", qsTr("Undo"), qsTr("Redo") ]

        var res = Gui.showMenu( acts )
        switch( res ) {
        case 0:
            txt.copy()
            break;
        case 1:
            txt.cut()
            break;
        case 2:
            txt.paste()
            break;
        case 4:
            txt.remove(txt.selectionStart,txt.selectionEnd)
            txt.deselect()
            break;
        case 6:
            txt.selectAll()
            break;
        case 8:
            txt.undo()
            break;
        case 9:
            txt.redo()
            break;
        }
    }
}
