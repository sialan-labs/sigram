import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Rectangle {

    property DialogListModel model

    signal finished(bool result)

    NullMouseArea {
        anchors.fill: parent
    }

    Button {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 30*Devices.density
        width: 150*Devices.density
        height: 38*Devices.density
        radius: 5*Devices.density
        normalColor: "#E5E5E5"
        highlightColor: Qt.darker(normalColor, 1.1)
        textColor: "#666666"
        text: qsTr("Back to Contacts")
        textFont.bold: false
        textFont.pixelSize: 10*Devices.fontDensity
        Keys.onEscapePressed: BackHandler.back()
        onClicked: BackHandler.back()
    }

    Column {
        id: addBox
        width: 239*Devices.density
        anchors.centerIn: parent
        spacing: 4*Devices.density

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#E5E5E5"

            TextInput {
                id: nameTxt
                anchors.left: parent.left
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 12*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                Keys.onTabPressed: familyTxt.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                onAccepted: signin_btn.clicked()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 0
                    text: qsTr("First Name")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#E5E5E5"

            TextInput {
                id: familyTxt
                anchors.left: parent.left
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 12*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                Keys.onTabPressed: phoneTxt.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                onAccepted: signin_btn.clicked()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 0
                    text: qsTr("Last Name")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            color: "#E5E5E5"

            TextInput {
                id: phoneTxt
                anchors.left: parent.left
                anchors.leftMargin: 8*Devices.density
                anchors.right: parent.right
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 12*Devices.fontDensity
                color: "#333333"
                selectByMouse: true
                selectionColor: CutegramGlobals.baseColor
                selectedTextColor: "#ffffff"
                validator: RegExpValidator{ regExp: /\+\d*/ }
                Keys.onTabPressed: signin_btn.forceActiveFocus()
                Keys.onEscapePressed: BackHandler.back()
                text: "+"
                onAccepted: signin_btn.clicked()

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12*Devices.density
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#aaaaaa"
                    visible: parent.text.length == 1
                    text: qsTr("Phone Number")
                }

                CursorShapeArea {
                    cursorShape: Qt.IBeamCursor
                    anchors.fill: parent
                }
            }
        }

        Button {
            id: signin_btn
            width: parent.width
            height: 35*Devices.density
            radius: 5*Devices.density
            normalColor: CutegramGlobals.baseColor
            highlightColor: Qt.darker(normalColor, 1.1)
            textColor: "#ffffff"
            text: qsTr("Add")
            textFont.bold: false
            textFont.pixelSize: 10*Devices.fontDensity
            Keys.onTabPressed: nameTxt.forceActiveFocus()
            Keys.onEscapePressed: BackHandler.back()
            onClicked: {
                model.addContact(nameTxt.text, familyTxt.text, phoneTxt.text, function(result){
                    finished(result)
                })
            }
        }
    }

    Text {
        id: error_txt
        anchors.top: addBox.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20*Devices.density
        color: "#db2424"
        font.pixelSize: 9*Devices.fontDensity
        text: model? model.errorText : ""
    }

    function clear() {
        nameTxt.forceActiveFocus()
        nameTxt.text = ""
        familyTxt.text = ""
        phoneTxt.text = "+"
    }
}
