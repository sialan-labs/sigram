import QtQuick 2.0

Column {
    id: rf_code
    width: 100
    height: 62
    spacing: 10

    Connections {
        target: Telegram
        onRegisteringInvalidCode: {
            rf_code.error = true
            auth_code_line.text = ""
            auth_code_line.focus = false
        }
    }

    property bool error: false

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        color: "#55ffffff"
        border.width: rf_code.error? 1 : 0
        border.color: "#ff5532"

        Text {
            anchors.fill: auth_code_line
            verticalAlignment: Text.AlignVCenter
            font: auth_code_line.font
            text: qsTr("Authenticate Code")
            color: "#aaaaaa"
            visible: !auth_code_line.focus && auth_code_line.text.length == 0
        }

        TextInput {
            id: auth_code_line
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
        text: qsTr("Send")
        onClicked: go()
    }

    Button {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        normalColor: "#00000000"
        highlightColor: "#00000000"
        textColor: press? "#D04528" : "#ff5532"
        textFont.pointSize: 10
        textFont.family: globalNormalFontFamily
        textFont.underline: true
        text: qsTr("Call Request")
        onClicked: Telegram.waitAndGetAuthCodeCallBack( "", true )
    }

    function go() {
        if( auth_code_line.text.length == 0 )
            return

        Telegram.waitAndGetAuthCodeCallBack( auth_code_line.text, false )
    }
}
