import QtQuick 2.0

Column {
    id: rf_phone
    width: 100
    height: 62
    spacing: 10

    property string country

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        visible: rf_phone.country.length != 0
        color: "#55ffffff"

        Text {
            anchors.fill: phone_line
            verticalAlignment: Text.AlignVCenter
            font: phone_line.font
            text: qsTr("Your mobile phone")
            color: "#aaaaaa"
            visible: !phone_line.focus && phone_line.text.length == 0
        }

        Text {
            id: country_code
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 6
            verticalAlignment: Text.AlignVCenter
            text: "+" + Countries.phoneCode(rf_phone.country)
            font.pointSize: 11
            font.family: globalNormalFontFamily
            font.weight: Font.Bold
        }

        TextInput {
            id: phone_line
            anchors.left: country_code.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
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
        visible: rf_phone.country.length != 0
        onClicked: go()
    }

    CountryFrame {
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        visible: rf_phone.country.length == 0
        onSelected: rf_phone.country = country
    }

    function go() {
        if( phone_line.text.length == 0 )
            return

        Telegram.waitAndGetPhoneCallBack( country_code.text + phone_line.text )
    }
}
