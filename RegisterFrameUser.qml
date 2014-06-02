import QtQuick 2.0

Column {
    width: 100
    height: 62
    spacing: 10

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        color: "#55ffffff"

        Text {
            anchors.fill: firstname_line
            verticalAlignment: Text.AlignVCenter
            font: firstname_line.font
            text: qsTr("First Name")
            color: "#aaaaaa"
            visible: !firstname_line.focus && firstname_line.text.length == 0
        }

        TextInput {
            id: firstname_line
            anchors.fill: parent
            anchors.margins: 6
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 11
            font.family: globalNormalFontFamily
            font.weight: Font.Normal
            onAccepted: lastname_line.focus = true
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        color: "#55ffffff"

        Text {
            anchors.fill: lastname_line
            verticalAlignment: Text.AlignVCenter
            font: lastname_line.font
            text: qsTr("Last Name")
            color: "#aaaaaa"
            visible: !lastname_line.focus && lastname_line.text.length == 0
        }

        TextInput {
            id: lastname_line
            anchors.fill: parent
            anchors.margins: 6
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 11
            font.family: globalNormalFontFamily
            font.weight: Font.Normal
            onAccepted: go()
        }
    }

    Button {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        normalColor: "#33CCAD"
        highlightColor: "#3AE9C6"
        textColor: "#ffffff"
        textFont.pointSize: 11
        textFont.family: globalNormalFontFamily
        text: qsTr("Submit")
        onClicked: go()
    }

    function go() {
        if( firstname_line.text.length == 0 )
            return

        Telegram.waitAndGetUserInfoCallBack( firstname_line.text, lastname_line.text )
    }
}
