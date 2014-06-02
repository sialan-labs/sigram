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
            anchors.fill: phone_line
            verticalAlignment: Text.AlignVCenter
            font: phone_line.font
            text: qsTr("Your mobile phone")
            color: "#aaaaaa"
            visible: !phone_line.focus && phone_line.text.length == 0
        }

        TextInput {
            id: phone_line
            anchors.fill: parent
            anchors.margins: 6
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 11
            font.family: globalNormalFontFamily
            font.weight: Font.Normal
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator{regExp: /(?!0)\d*/}
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
        text: qsTr("Lets Go!")
        onClicked: go()
    }

    function go() {
        if( phone_line.text.length == 0 )
            return

        Telegram.waitAndGetPhoneCallBack( "+" + phone_line.text )
    }
}
