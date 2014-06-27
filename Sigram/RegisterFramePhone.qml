/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
        onSelected: {
            rf_phone.country = country
            Gui.country = country
        }
    }

    function go() {
        if( phone_line.text.length == 0 )
            return

        Telegram.waitAndGetPhoneCallBack( country_code.text + phone_line.text )
    }
}
