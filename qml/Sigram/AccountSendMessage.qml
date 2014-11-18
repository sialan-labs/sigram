import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Rectangle {
    id: smsg
    width: 100
    height: txt.height<minimumHeight? minimumHeight : txt.height
    color: backColor2

    property Dialog currentDialog
    property real minimumHeight: 40*physicalPlatformScale

    signal accepted( string text )

    SystemPalette { id: palette; colorGroup: SystemPalette.Active }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: txt.focus = true
    }

    TextAreaCore {
        id: txt
        anchors.left: parent.left
        anchors.right: send_btn.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4*physicalPlatformScale
        selectByMouse: true
        selectionColor: palette.highlight
        selectedTextColor: palette.highlightedText
        pickerEnable: false
        color: textColor0

        onTextChanged: if( text.trim().length == 0 ) text = ""
        Keys.onPressed: {
            if( event.key == Qt.Key_Return || event.key == Qt.Key_Enter )
                if( event.modifiers == Qt.NoModifier )
                {
                    smsg.accepted(text)
                    text = ""
                }
        }
    }

    Button {
        id: send_btn
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        textColor: "#0d80ec"
        normalColor: "#00000000"
        highlightColor: "#0f000000"
        width: 70*physicalPlatformScale
        cursorShape: Qt.PointingHandCursor
        textFont.pixelSize: 12*fontsScale
        text: qsTr("Send")
    }
}
