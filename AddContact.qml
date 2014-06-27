import QtQuick 2.0

Item {
    id: add_contact
    width: 100
    height: column.height + pad

    property real pad: 12
    property real itemSpaces: 10

    signal close()

    MouseArea {
        anchors.fill: parent
    }

    Column {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: add_contact.pad/2
        spacing: 2

        Text {
            font.family: globalNormalFontFamily
            font.weight: Font.Light
            font.pointSize: 18
            text: qsTr("Add Contact")
        }

        Item {
            width: 20
            height: itemSpaces
        }

        Text {
            font.bold: true
            font.family: globalNormalFontFamily
            font.weight: Font.Light
            font.pointSize: 9
            text: qsTr("Phone number")
        }

        LineEdit {
            id: phone
            anchors.left: parent.left
            anchors.right: parent.right
            validator: RegExpValidator{regExp: /\d*/}
            height: 30
            color: "#66aaaaaa"
            readOnly: false
        }

        Item {
            width: 20
            height: itemSpaces
        }

        Text {
            font.bold: true
            font.family: globalNormalFontFamily
            font.weight: Font.Light
            font.pointSize: 9
            text: qsTr("First name")
        }

        LineEdit {
            id: fname
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: "#66aaaaaa"
            readOnly: false
        }

        Item {
            width: 20
            height: itemSpaces
        }

        Text {
            font.bold: true
            font.family: globalNormalFontFamily
            font.weight: Font.Light
            font.pointSize: 9
            text: qsTr("Last name")
        }

        LineEdit {
            id: lname
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: "#66aaaaaa"
            readOnly: false
        }

        Item {
            width: 20
            height: itemSpaces
        }

        Button {
            anchors.left: parent.left
            anchors.right: parent.right
            textColor: "#ffffff"
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            text: qsTr("Add")
            onClicked: {
                if( phone.text.length < 8 )
                    return

                Telegram.addContact( Gui.fixPhoneNumber(phone.text), fname.text, lname.text, false )
                add_contact.close()
            }
        }
    }
}
