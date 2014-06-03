import QtQuick 2.0
import QtQuick.Controls 1.0

Item {
    id: line_edit
    width: 100

    property alias color: txt.color
    property alias text: txt.text
    property alias textInput: txt

    signal accepted();

    Flickable {
        id: txt_flickable
        anchors.fill: parent
        contentWidth: txt.width
        contentHeight: txt.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        function ensureVisible(r)
        {
            var hg = height
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+hg <= r.y+r.height+15*physicalPlatformScale)
                contentY = r.y+r.height-hg + 15*physicalPlatformScale;
        }

        TextEdit {
            id: txt
            width: txt_flickable.width
            height: contentHeight<txt_flickable.height? txt_flickable.height : contentHeight
            selectionColor: "#0d80ec"
            selectedTextColor: "#ffffff"
            wrapMode: Text.WordWrap
            font.family: globalTextFontFamily
            selectByMouse: true

            onCursorRectangleChanged: txt_flickable.ensureVisible(cursorRectangle)
            onTextChanged: if( text.trim().length == 0 ) text = ""

            Keys.onPressed: {
                if( event.key == Qt.Key_Return || event.key == Qt.Key_Enter )
                    if( event.modifiers == Qt.NoModifier )
                        line_edit.accepted()
            }
        }
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            line_edit.showMenu()
        }
    }

    PhysicalScrollBar {
        scrollArea: txt_flickable; width: 8; anchors.right: parent.right; anchors.top: txt_flickable.top;
        anchors.bottom: txt_flickable.bottom; color: "#ffffff"
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
